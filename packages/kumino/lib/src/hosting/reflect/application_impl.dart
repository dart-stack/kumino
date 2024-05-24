import 'dart:mirrors';

import '../../dependency_injection/annotations.dart';
import '../../mvc/annotations.dart';
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
      if (anno.type.isSubtypeOf(reflectType(Controllers))) {
        result.addAll(anno.reflectee.controllers);
      } else if (anno.type.isSubtypeOf(reflectType(Components))) {
        for (final componentType in anno.reflectee.imports) {
          for (final anno1 in reflectType(componentType).metadata) {
            if (anno1.type.isSubtypeOf(reflectType(Controller))) {
              result.add(componentType);
              break;
            }
          }
        }
      }
    }
    return result;
  }

  @override
  List<MvcController> get controllers {
    final List<MvcController> result; 
    for(final controllerType in importedControllers) {
      final controller = MvcController();
      for(final action in reflectClass(controllerType).declarations.values) {
        if(action is! MethodMirror) {
          continue;
        }
        for(final anno in action.metadata) {
          if(anno.type.isSubtypeOf(reflectType(RouteMapping))) {
            continue;
          }
        }
        controller.actions.add(MvcAction()..path = );
      }
    }
  }
}

ApplicationDelegate delegateTo<T>() {
  return ReflectedApplicationDelegate(T);
}
