//
// DANGERIOUS!!! THIS FILE CAN ONLY BE USED ON JIT MODE.

import 'mirrors.stub.dart' if (dart.library.mirrors) 'dart:mirrors';
export 'mirrors.stub.dart' if (dart.library.mirrors) 'dart:mirrors';

List<ClassMirror> findClassesAnnotatedWithExactType<T>([Type? type]) {
  final result = <ClassMirror>[];
  for (final library in currentMirrorSystem().libraries.values) {
    result.addAll(library.findClassesAnnotatedWithExactType(type ?? T));
  }
  return result;
}

extension LibraryMirrorFinderExtensions on LibraryMirror {
  List<ClassMirror> findClassesAnnotatedWithExactType<T>([Type? type]) {
    final result = <ClassMirror>[];
    for (final declaration in declarations.values) {
      if (declaration is ClassMirror &&
          declaration.isAnnotatedWithExactType(type ?? T)) {
        result.add(declaration);
      }
    }
    return result;
  }
}

extension ClassMirrorFinderExtensions on ClassMirror {
  List<MethodMirror> get constructors => declarations.values
      .whereType<MethodMirror>()
      .where((mirror) => mirror.isConstructor)
      .toList();

  List<MethodMirror> get constConstructors =>
      constructors.where((mirror) => mirror.isConstConstructor).toList();

  List<MethodMirror> get factoryConstructors =>
      constructors.where((mirror) => mirror.isFactoryConstructor).toList();

  List<MethodMirror> get methods => instanceMembers.values
      .where((element) => element.isRegularMethod)
      .toList();
}

extension DeclarationMirrorFinderExtensions on DeclarationMirror {
  bool isAnnotatedWith(Type type) {
    return metadata
        .any((element) => element.type.isAssignableTo(reflectType(type)));
  }

  bool isAnnotatedWithExactType(Type type) {
    return metadata.any((element) => element.type.reflectedType == type);
  }

  T? findAnnotation<T>([Type? type]) => metadata
      .where((element) => element.type.isAssignableTo(reflectType(type ?? T)))
      .map((element) => element.reflectee)
      .firstOrNull as T?;
}
