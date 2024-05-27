import 'dart:mirrors';

import 'package:diffutil_dart/diffutil.dart';
import 'package:meta/meta.dart';

import '../utils/dart_mirrors/enhanced.dart';

class ChangeTracker {
  final List<Snapshot> snapshots = [];

  @protected
  @visibleForTesting
  Snapshot takeSnapshot(Object currentValue) {
    return SnapshotBuilder().build(currentValue);
  }

  void track(Object entity) {}

  List<EntityChange> computeChanges(Object entity) {
    final result = <EntityChange>[];

    return result;
  }

  List<EntityChange> captureChanges<T extends Object>(
    T instance,
    void Function(T) mutator,
  ) {
    final snapshot = takeSnapshot(instance);
    mutator(instance);
    return snapshot.computeChanges(instance);
  }
}

sealed class EntityChange {
  late SnapshotNode snapshotNode;
}

class ValueUpdated extends EntityChange {
  late dynamic oldValue;
  late dynamic newValue;
}

class ElementAdded extends EntityChange {
  late dynamic newKey;
  late dynamic newValue;
}

class ElementRemoved extends EntityChange {
  late dynamic oldKey;
  late dynamic oldValue;
}

class ElementMoved extends EntityChange {
  late dynamic oldKey;
  late dynamic newKey;
}

class ElementUpdated extends EntityChange {
  late dynamic key;
  late List<EntityChange> updates;
}

C Function(A) _compose2<A, B, C>(C Function(B) f, B Function(A) g) {
  C composed2(A x) => f(g(x));
  return composed2;
}

class SnapshotBuilder {
  _asIs(source) {
    return source;
  }

  bool _isEquals(a, b) {
    return a == b;
  }

  bool _isDartPrimitive(Object value) {
    return switch (value) {
      num _ || bool _ || Symbol _ || String _ || Record _ || Function _ => true,
      _ => false,
    };
  }

  bool _isImmutableValue(Object value) {
    return _isDartPrimitive(value) ||
        reflect(value).type.hasAnnotationOfSubtypeT<Immutable>();
  }

  @internal
  SnapshotNode buildNode(
    Object? source,
    SnapshotNode? parent,
    dynamic Function(dynamic) indirectGetter, {
    String? debugName,
  }) {
    const dartGetters = [Symbol('runtimeType'), Symbol('hashCode')];
    if (source == null) {
      throw ArgumentError.notNull('currentValue');
    }
    if (_isImmutableValue(source)) {
      final node = ImmutableValueSnapshot();
      // ignore: cascade_invocations
      node
        ..parent = parent
        ..valueGetter = _compose2(_asIs, indirectGetter)
        ..snapshotValue = source
        ..snapshotValueType = reflect(source).type.reflectedType
        ..debugName = debugName
        ..equalityChecker = _isEquals;
      return node;
    } else if (source case Map sourceAsMap) {
      final node = MapSnapshot();
      // ignore: cascade_invocations
      node
        ..parent = parent
        ..valueGetter = _compose2(_asIs, indirectGetter)
        ..snapshotValue = source
        ..snapshotValueType = reflect(source).type.reflectedType
        ..debugName = debugName
        ..entries = {};
      for (final MapEntry(key: key, value: _) in sourceAsMap.entries) {
        getElementFromMap(instance) {
          return instance[key];
        }

        node.entries[key] = buildNode(
          getElementFromMap(sourceAsMap),
          node,
          getElementFromMap,
          debugName: '[\'$key\']',
        );
      }
      return node;
    } else if (source case Iterable sourceAsIterable) {
      final node = IterableSnapshot();
      // ignore: cascade_invocations
      node
        ..parent = parent
        ..valueGetter = _compose2(_asIs, indirectGetter)
        ..snapshotValue = source
        ..snapshotValueType = reflect(source).type.reflectedType
        ..debugName = debugName
        ..elements = {};
      for (final (index, _) in sourceAsIterable.indexed) {
        getElementFromIterable(source) {
          return source[index];
        }

        node.elements[index] = buildNode(
          getElementFromIterable(sourceAsIterable),
          node,
          getElementFromIterable,
          debugName: '[$index]',
        );
      }
      return node;
    } else {
      final clazz = reflect(source).type;
      final node = StructSnapshot()
        ..parent = parent
        ..valueGetter = _compose2(_asIs, indirectGetter)
        ..snapshotValue = source
        ..snapshotValueType = reflect(source).type.reflectedType
        ..debugName = debugName
        ..fields = {}
        ..getters = {};
      for (final field in clazz.instanceFields.values) {
        final fieldName = field.simpleName;
        getValueFromField(source) {
          return reflect(source).getField(fieldName).reflectee;
        }

        node.fields[fieldName.name] = buildNode(
          getValueFromField(source),
          node,
          getValueFromField,
          debugName: fieldName.name,
        );
      }
      for (final getter in clazz.instanceGetters.values) {
        if (dartGetters.contains(getter.simpleName)) {
          continue;
        }
        final getterName = getter.simpleName;
        getValueFromGetter(source) {
          return reflect(source).getField(getterName).reflectee;
        }

        node.getters[getterName.name] = buildNode(
          getValueFromGetter(source),
          node,
          getValueFromGetter,
          debugName: getterName.name,
        );
      }
      return node;
    }
  }

  Snapshot build(Object source) {
    final snapshot = Snapshot()
      ..root = buildNode(source, null, _asIs, debugName: '\$');
    return snapshot;
  }
}

class Snapshot {
  late SnapshotNode root;

  List<EntityChange> computeChanges(dynamic currentValue) {
    final changes = <EntityChange>[];
    root.computeChanges(currentValue, changes);
    return changes;
  }

  void dispose() {}
}

sealed class SnapshotNode {
  late SnapshotNode? parent;
  late dynamic Function(dynamic) valueGetter;
  late Type snapshotValueType;
  late dynamic snapshotValue;
  late String? debugName;

  List<SnapshotNode> get ancestors => [...parent?.ancestors ?? [], this];

  String get debugQualifiedName =>
      ancestors.map((x) => x.debugName ?? '<unamed>').join('.');

  dynamic getValueFromSource(source) => valueGetter.call(source);

  void computeChanges(source, List<EntityChange> changes);

  bool valueIsEqualsTo(other);

  void dispose();
}

class ImmutableValueSnapshot extends SnapshotNode {
  late bool Function(dynamic, dynamic) equalityChecker;

  @override
  void computeChanges(source, List<EntityChange> changes) {
    _doComputeChanges(getValueFromSource(source), changes);
  }

  void _doComputeChanges(
    currentValue,
    List<EntityChange> changes,
  ) {
    if (!equalityChecker.call(snapshotValue, currentValue)) {
      changes.add(
        ValueUpdated()
          ..snapshotNode = this
          ..oldValue = snapshotValue
          ..newValue = currentValue,
      );
    }
  }

  @override
  bool valueIsEqualsTo(other) {
    return other.runtimeType == snapshotValueType && other == snapshotValue;
  }

  @override
  void dispose() {
    snapshotValue = null;
  }
}

class MapSnapshot extends SnapshotNode {
  late Map<dynamic, SnapshotNode> entries;

  @override
  void computeChanges(source, List<EntityChange> changes) {
    _doComputeChanges(valueGetter.call(source), changes);
  }

  void _doComputeChanges(Map currentValue, List<EntityChange> changes) {
    final added = [];
    final removed = [];
    final maybeUpdated = [];

    // if the old map doesn't contain the key from the new map,
    // we think the element was added.
    for (final key in currentValue.keys) {
      if (!entries.containsKey(key)) {
        added.add(key);
      }
    }
    // if the new map doesn't contain the key from the old map,
    // we think the element was removed.
    for (final key in entries.keys) {
      if (!currentValue.containsKey(key)) {
        removed.add(key);
      }
    }
    // the intersection we think these elements maybe were updated
    for (final key in entries.keys) {
      if (currentValue.containsKey(key)) {
        maybeUpdated.add(key);
      }
    }

    for (final key in added) {
      changes.add(
        ElementAdded()
          ..snapshotNode = this
          ..newKey = key
          ..newValue = currentValue[key],
      );
    }
    for (final key in removed) {
      changes.add(
        ElementRemoved()
          ..snapshotNode = this
          ..oldKey = key
          ..oldValue = entries[key]!.snapshotValue,
      );
    }
    for (final key in maybeUpdated) {
      final update = ElementUpdated()
        ..snapshotNode = this
        ..key = key
        ..updates = [];
      entries[key]!.computeChanges(currentValue, update.updates);
      if (update.updates.isNotEmpty) {
        changes.add(update);
      }
    }
  }

  @override
  bool valueIsEqualsTo(other) {
    if (other.runtimeType != snapshotValueType) {
      return false;
    }
    final keysCount = <dynamic, int>{};
    for (final key in entries.keys) {
      keysCount[key] = (keysCount[key] ?? 0) + 1;
    }
    for (final key in other.keys) {
      keysCount[key] = (keysCount[key] ?? 0) + 1;
    }
    if (keysCount.values.any((x) => x != 2)) {
      return false;
    }
    for (final MapEntry(key: _, value: node) in entries.entries) {
      if (!node.valueIsEqualsTo(node.getValueFromSource(other))) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    for (var elem in entries.values) {
      elem.dispose();
    }
    snapshotValue = null;
  }
}

class _IterableDiff implements DiffDelegate {
  _IterableDiff(this.snapshot, this.source);

  final IterableSnapshot snapshot;
  final Iterable source;

  @override
  bool areContentsTheSame(int oldItemPosition, int newItemPosition) {
    final node = snapshot.elements[oldItemPosition]!;
    final currentValue = source.elementAt(newItemPosition);
    return node.valueIsEqualsTo(currentValue);
  }

  @override
  bool areItemsTheSame(int oldItemPosition, int newItemPosition) {
    final node = snapshot.elements[oldItemPosition]!;
    final currentValue = source.elementAt(newItemPosition);
    return node.snapshotValue == currentValue;
  }

  @override
  int getNewListSize() => source.length;

  @override
  int getOldListSize() => snapshot.elements.length;

  @override
  Object? getChangePayload(int oldItemPosition, int newItemPosition) {
    return null;
  }
}

class IterableSnapshot extends SnapshotNode {
  late Map<int, SnapshotNode> elements;

  @override
  void computeChanges(source, List<EntityChange> changes) {
    _doComputeChanges(getValueFromSource(source), changes);
  }

  void _doComputeChanges(List currentValue, List<EntityChange> changes) {
    final delegate = _IterableDiff(this, currentValue);
    final result = calculateDiff(delegate);
    final updates = result.getUpdates();
    for (final update in updates) {
      final result = update.when<List<EntityChange>>(
        insert: (index, count) {
          return List.generate(
            count,
            (i) => ElementAdded()
              ..snapshotNode = this
              ..newKey = index + i
              ..newValue = currentValue[index + i],
          );
        },
        remove: (index, count) {
          return List.generate(
            count,
            (i) => ElementRemoved()
              ..snapshotNode = this
              ..oldKey = index + i
              ..oldValue = elements[index + i]!.snapshotValue,
          );
        },
        change: (index, _) {
          final update = ElementUpdated()
            ..snapshotNode = this
            ..key = index
            ..updates = [];
          elements[index]!.computeChanges(currentValue, update.updates);
          return [update];
        },
        move: (oldIndex, newIndex) {
          return [
            ElementMoved()
              ..snapshotNode = this
              ..oldKey = oldIndex
              ..newKey = newIndex,
          ];
        },
      );
      changes.addAll(result);
    }
  }

  @override
  bool valueIsEqualsTo(other) {
    if (other.runtimeType != snapshotValueType) {
      return false;
    }
    if (other.length != elements.length) {
      return false;
    }
    for (final node in elements.values) {
      if (!node.valueIsEqualsTo(node.getValueFromSource(other))) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    for (var elem in elements.values) {
      elem.dispose();
    }
    snapshotValue = null;
  }
}

class StructSnapshot extends SnapshotNode {
  late Map<String, SnapshotNode> fields;
  late Map<String, SnapshotNode> getters;

  @override
  void computeChanges(source, List<EntityChange> changes) {
    _doComputeChanges(valueGetter.call(source), changes);
  }

  void _doComputeChanges(Object currentValue, List<EntityChange> changes) {
    for (final MapEntry(key: _, value: node) in fields.entries) {
      node.computeChanges(currentValue, changes);
    }
    for (final MapEntry(key: _, value: node) in getters.entries) {
      node.computeChanges(currentValue, changes);
    }
  }

  @override
  bool valueIsEqualsTo(other) {
    if (other.runtimeType != snapshotValueType) {
      return false;
    }
    for (final node in fields.values) {
      if (!node.valueIsEqualsTo(node.getValueFromSource(other))) {
        return false;
      }
    }
    for (final node in getters.values) {
      if (!node.valueIsEqualsTo(node.getValueFromSource(other))) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    for (var elem in fields.values) {
      elem.dispose();
    }
    for (var elem in getters.values) {
      elem.dispose();
    }
    snapshotValue = null;
  }
}
