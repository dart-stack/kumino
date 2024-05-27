import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import '../../utils/dart_mirrors/enhanced.dart';
import '../../utils/dart_mirrors/pretty.dart';
import '../../dependency_injection/annotations.dart';
import '../../event/annotations.dart';
import '../../mvc/annotations.dart';
import '../../dependency_injection/container.dart';
import '../../event/event.dart';
import '../application.dart';
import '../mvc.dart';

class ReflectedApplicationDelegate implements ApplicationDelegate {
  ReflectedApplicationDelegate(Type delegateClass) {
    _class = reflectClass(delegateClass);
  }

  late final ClassMirror _class;

  List<Type> get importedControllers {
    final List<Type> result = [];
    for (final anno in _class.metadata) {
      if (anno.hasSubtypeOfT<ControllersAnnotation>()) {
        result.addAll(anno.reflectee.controllers);
      }
    }
    return result;
  }

  List<Type> get importedComponents {
    final List<Type> result = [];
    for (final anno in _class.metadata) {
      if (anno.hasSubtypeOfT<ComponentsAnnotation>()) {
        result.addAll(anno.reflectee.imports);
      }
    }
    return result;
  }

  @override
  void registerComponents(DIContainer container) {
    importedComponents.forEach(container.add);
    importedControllers.forEach(container.add);
    importedEventListeners.forEach(container.add);
  }

  @override
  List<MvcController> get controllers =>
      importedControllers.map(parseController).toList();

  MvcController parseController(Type classType) {
    final controller = MvcController()
      ..classType = classType
      ..actions = [];
    final actions = _findActionsInController(classType);
    if (actions.isNotEmpty) {
      controller.actions.addAll(actions);
    }
    return controller;
  }

  List<MvcAction> _findActionsInController(Type controllerType) {
    final List<MvcAction> actions = [];
    final controller = reflectClass(controllerType);
    for (final method in controller.instanceMethods.values) {
      final action = maybeParseAction(controllerType, method);
      if (action != null) {
        actions.add(action);
      }
    }
    return actions;
  }

  MvcAction? maybeParseAction(Type classType, MethodMirror method) {
    final annotation =
        method.findAnnotationWithSubtypeOfT<RouteMappingAnnotation>();
    if (annotation == null) {
      return null;
    }
    checkMethodSignatureForAction(classType, method);

    FutureOr invoke(Object instance, Invocation invocation) async {
      assert(() {
        final instanceType = reflect(instance).type;
        if (!instanceType.isSubtypeOf(reflectType(classType))) {
          throw AssertionError(
            'expect a subtype of $classType, but got $instanceType.',
          );
        }
        return true;
      }());

      return reflect(instance)
          .invoke(
            method.simpleName,
            invocation.positionalArguments,
            invocation.namedArguments,
          )
          .reflectee;
    }

    return MvcAction()
      ..method = annotation.method
      ..path = annotation.path
      ..invoker = invoke;
  }

  void checkMethodSignatureForAction(Type classType, MethodMirror method) {
    var hasWrong = false;
    final params = method.parameters;

    final messageParts = <String>[
      'A route action must have the signature like \'FutureOr'
          ' ${method.prettySimpleName}(HttpRequest request)\'.',
      ' In \'${method.prettyQualifiedName}\','
    ];
    if (params.isEmpty) {
      messageParts.add(
        ' there must take at least 1 parameters, and the first parameter'
        ' is required to take a \'HttpRequest\' of \'dart:io\', but got empty'
        ' parameters.',
      );
      hasWrong = true;
    }
    if (params.isNotEmpty &&
        !params[0].type.isAssignableTo(reflectType(HttpRequest))) {
      messageParts.add(
        ' the first parameter is required to take a \'HttpRequest\' of'
        ' \'dart:io\', but got \'${params[0].type.prettySimpleName}\'.',
      );
      hasWrong = true;
    }
    if (hasWrong) {
      throw AssertionError(messageParts.join());
    }
  }

  List<Type> get importedEventListeners {
    final List<Type> result = [];
    for (final anno in _class.metadata) {
      if (anno.hasSubtypeOfT<EventListenersAnnotation>()) {
        result.addAll(anno.reflectee.eventListeners);
      }
    }
    return result;
  }

  @override
  List<EventListener> get eventListeners {
    final List<EventListener> result = [];
    for (final classType in importedEventListeners) {
      final clazz = reflectClass(classType);
      for (final method in clazz.instanceMethods.values) {
        final listener = maybeParseEventListener(classType, method);
        if (listener != null) {
          result.add(listener);
        }
      }
    }
    return result;
  }

  EventListener? maybeParseEventListener(Type classType, MethodMirror method) {
    final annotation =
        method.findAnnotationWithSubtypeOfT<EventListenerAnnotation>();
    if (annotation == null) {
      return null;
    }
    checkMethodSignatureForEventListener(classType, method, annotation);

    FutureOr invoke(Object instance, Invocation invocation) async {
      assert(() {
        final instanceType = reflect(instance).type;
        if (!instanceType.isSubtypeOf(reflectType(classType))) {
          throw AssertionError(
            'expect a subtype of $classType, but got $instanceType.',
          );
        }
        return true;
      }());

      return reflect(instance)
          .invoke(
            method.simpleName,
            invocation.positionalArguments,
            invocation.namedArguments,
          )
          .reflectee;
    }

    return EventListener()
      ..classType = classType
      ..subscribeTo = annotation.subscribeTo
      ..invoker = invoke;
  }

  void checkMethodSignatureForEventListener(
    Type classType,
    MethodMirror method,
    EventListenerAnnotation annotation,
  ) {
    var hasWrong = false;
    final params = method.parameters;

    final messageParts = <String>[
      'An event listener must have the signature like `FutureOr'
          ' ${method.prettySimpleName}(${annotation.subscribeTo} event)`.',
      ' In \'${method.prettyQualifiedName}\','
    ];
    if (params.isEmpty) {
      messageParts.add(
        ' there must take at least 1 parameters and the first parameter is'
        ' required to take a \'${annotation.subscribeTo}\', but got empty'
        ' parameters.',
      );
      hasWrong = true;
    }
    if (params.isNotEmpty &&
        !params[0].type.isAssignableTo(reflectType(annotation.subscribeTo))) {
      messageParts.add(
        ' the first parameter is required to take a'
        ' \'${annotation.subscribeTo}\', but got'
        ' \'${params[0].type.prettySimpleName}\'.',
      );
      hasWrong = true;
    }
    if (hasWrong) {
      throw AssertionError(messageParts.join());
    }
  }
}

ApplicationDelegate delegateTo<T>() {
  return ReflectedApplicationDelegate(T);
}
