import 'dart:mirrors';

import '../collection.dart';

extension EnhancedClassMirror on ClassMirror {
  Map<Symbol, MethodMirror> get constructors {
    return Map.fromEntries(
      declarations.entries
          .where(
            (x) =>
                x.value is MethodMirror &&
                (x.value as MethodMirror).isConstructor,
          )
          .map((x) => x.cast()),
    );
  }

  Map<Symbol, VariableMirror> get instanceFields => Map.fromEntries(
        declarations.entries
            .where((x) => x.value is VariableMirror)
            .map((x) => x.cast()),
      );

  Map<Symbol, MethodMirror> get instanceGetters => Map.fromEntries(
        instanceMembers.entries
            .where((x) => !x.value.isSynthetic && x.value.isGetter),
      );

  Map<Symbol, MethodMirror> get instanceSetters => Map.fromEntries(
        instanceMembers.entries
            .where((x) => !x.value.isSynthetic && x.value.isSetter),
      );

  Map<Symbol, MethodMirror> get instanceMethods => Map.fromEntries(
        instanceMembers.entries.where((x) => x.value.isRegularMethod),
      );

  VariableMirror? findInstanceField(Symbol fieldName) {
    return instanceFields[fieldName];
  }

  MethodMirror? findInstanceMethod(Symbol methodName) {
    return instanceMethods[methodName];
  }
}

extension EnhancedTypeMirror on TypeMirror {
  bool isSubtypeOfT<T>() {
    return isSubtypeOf(reflectType(T));
  }
}

extension EnhancedDeclarationMirror on DeclarationMirror {
  Iterable<InstanceMirror> get annotations => metadata;

  bool hasExactAnnotation(Object annotation) {
    return annotations.any((x) => x.reflectee == annotation);
  }

  bool hasAnnotationOfExactT<T>() {
    return annotations.any((x) => x.type.reflectedType == T);
  }

  bool hasAnnotationOfSubtypeT<T>() {
    return annotations.any((x) => x.type.isSubtypeOfT<T>());
  }

  T? findAnnotationWithSubtypeOfT<T>() {
    return metadata
        .where((x) => x.type.isSubtypeOfT<T>())
        .map((x) => x.reflectee as T)
        .firstOrNull;
  }
}

extension EnhancedInstanceMirror on InstanceMirror {
  bool hasSubtypeOfT<T>() {
    return type.isSubtypeOfT<T>();
  }
}

extension ReflectedSymbol on Symbol {
  String get name => MirrorSystem.getName(this);
}
