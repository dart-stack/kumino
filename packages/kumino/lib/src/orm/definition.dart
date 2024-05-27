import 'dart:collection';
import 'dart:mirrors';

import 'package:meta/meta.dart';

import '../utils/dart_mirrors/enhanced.dart';
import 'annotations.dart';

typedef ValueGetter = Object? Function(Object entity);
typedef ElementGetter = Object? Function(Object entity, Object index);

class Orm {
  @protected
  @visibleForTesting
  EntityDefinition? tryParseEntity(Type classType) {
    return ModelParser().tryParseEntity(classType);
  }
}

class ModelParser {
  final Map<Type, EntityDefinition> _entities = {};

  int entityId = 0;

  int propertyId = 0;

  EntityDefinition? tryParseEntity(Type classType) {
    final clazz = reflectClass(classType);
    if (!clazz.hasAnnotationOfSubtypeT<EntityAnnotation>()) {
      return null;
    }
    final entity = EntityDefinition()
      .._localId = entityId++
      ..classType = classType
      ..properties = [];
    // avoid dead-lock
    _entities[classType] = entity;
    for (final field in clazz.instanceFields.values) {
      entity.properties.add(parsePropertyFromField(classType, field));
    }
    return entity;
  }

  PropertyDefinition parsePropertyFromField(
    Type entityType,
    VariableMirror field,
  ) {
    Object? valueGetter(Object instance) {
      return reflect(instance).getField(field.simpleName).reflectee;
    }

    final isPrimaryKey = field.hasAnnotationOfSubtypeT<PrimaryKeyAnnotation>();
    final (isCollection, elementType, elementGetter) =
        _parseElementType(field.type, valueGetter);

    final property = PropertyDefinition()
      .._localId = propertyId++
      ..name = field.simpleName.name
      ..isPrimaryKey = isPrimaryKey
      ..valueType = field.type.reflectedType
      ..elementType = isCollection ? elementType.reflectedType : null
      ..isCollection = isCollection
      ..valueGetter = valueGetter
      ..elementGetter = isCollection ? elementGetter : null
      ..association = null;
    if (elementType.hasAnnotationOfSubtypeT<EntityAnnotation>()) {
      property.association = _entities[elementType.reflectedType] ??
          tryParseEntity(elementType.reflectedType)!;
    }

    return property;
  }
}

(bool, TypeMirror, ElementGetter) _parseElementType(
  TypeMirror elementType,
  ValueGetter valueGetter,
) {
  if (elementType.isSubtypeOfT<Iterable>()) {
    return (
      true,
      elementType.typeArguments[0],
      (instance, index) => (valueGetter.call(instance) as Iterable)
          .elementAtOrNull(index as int),
    );
  } else if (elementType.isSubtypeOfT<Map>()) {
    return (
      true,
      elementType.typeArguments[1],
      (instance, index) => (valueGetter.call(instance) as Map)[index]
    );
  } else {
    return (
      false,
      elementType,
      (instance, index) {
        throw UnimplementedError(
          '${elementType.reflectedType} is not a collection',
        );
      }
    );
  }
}

class EntityDefinition {
  late int _localId;
  late Type classType;
  late PrimaryKey primaryKey;
  late List<PropertyDefinition> properties;
}

class PropertyDefinition {
  late int _localId;
  late String name;
  late bool isPrimaryKey;
  late Type valueType;
  late Type? elementType;
  late bool isCollection;
  late ValueGetter valueGetter;
  late ElementGetter? elementGetter;
  late EntityDefinition? association;

  bool get hasAssociation => association != null;
}

class EntityInstance<T extends Object> {
  late EntityDefinition definition;
  late T instance;
}

class PrimaryKey {}
