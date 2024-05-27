import 'dart:async';
import 'dart:mirrors';

import '../utils/dart_mirrors/enhanced.dart';

class DIContainer {
  final Map<Type, Type> _bindings = {};

  final Map<Type, Object> _instances = {};

  void add(Type classType) {
    _bindings[classType] = classType;
  }

  void addT<T>() {
    add(T);
  }

  void bind(Type bindingType, Type implementationType) {
    _bindings[bindingType] = implementationType;
  }

  void bindT<T, I>() {
    bind(T, I);
  }

  void bindInstance(Type interfaceType, Object instance) {
    _instances[interfaceType] = instance;
  }

  void bindInstanceT<T>(Object instance) {
    bindInstance(T, instance);
  }

  FutureOr<T> resolveT<T>() async {
    return await resolve(T) as T;
  }

  FutureOr<Object> resolve(Type bindingType) async {
    if (_instances[bindingType] != null) {
      return _instances[bindingType]!;
    }
    final clazz = reflectClass(_bindings[bindingType]!);
    final constructor = clazz.constructors.entries.first.value;
    final (posArgs, namedArgs) = await resolveDeps(constructor);
    return clazz
        .newInstance(constructor.constructorName, posArgs, namedArgs)
        .reflectee;
  }

  FutureOr<(List<Object>, Map<Symbol, Object>)> resolveDeps(
    MethodMirror constructor,
  ) async {
    final deps = constructor.parameters;
    final posArgs = <Object>[];
    final namedArgs = <Symbol, Object>{};
    for (final dep in deps) {
      final value = await resolve(dep.type.reflectedType);
      if (dep.isNamed) {
        namedArgs[dep.simpleName] = value;
      } else {
        posArgs.add(value);
      }
    }
    return (posArgs, namedArgs);
  }
}
