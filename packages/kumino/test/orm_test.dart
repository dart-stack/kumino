import 'dart:mirrors';

import 'package:kumino/src/orm/annotations.dart';
import 'package:kumino/src/orm/change_tracker.dart';
import 'package:kumino/src/orm/definition.dart';
import 'package:kumino/src/utils/dart_mirrors/enhanced.dart';
import 'package:test/test.dart';

// TODO(mc):
//  - restore state
//  - read state
//  - cdc

@EntityAnnotation()
class Order {
  @PrimaryKeyAnnotation()
  late String orderNo;

  @IndexAnnotation()
  late String customerName;

  late List<OrderLine> orderLines;

  late Map<String, String> details;

  void addOrderLine(String productSku, int purchaseCount) {
    orderLines.add(
      OrderLine()
        ..productSku = productSku
        ..purchaseCount = purchaseCount,
    );
  }
}

@EntityAnnotation()
class OrderLine {
  late String productSku;
  late int purchaseCount;
}

abstract class Iterable1 implements Iterable {}

void main() {
  test('dart type checker', () {
    expect(Iterable.generate(1, (_) => 1) == Iterable, isFalse);
    expect(
      reflect(Iterable.generate(1, (_) => 1)).type.reflectedType == Iterable,
      isFalse,
    );
    expect(
      reflect(Iterable.generate(1, (_) => 1))
          .type
          .isSubtypeOf(reflectType(Iterable)),
      isTrue,
    );
    expect(reflectType(Iterable1).isSubtypeOf(reflectType(Iterable)), isTrue);
  });

  group('ModelParser', () {
    test('parse property from field', () {
      final parser = ModelParser();
      final order = Order()
        ..orderNo = 'S123456789'
        ..customerName = 'Banana Inc.'
        ..orderLines = [
          OrderLine()
            ..productSku = 'Chocolate'
            ..purchaseCount = 1
        ];

      var def = parser.parsePropertyFromField(
        Order,
        reflectClass(Order).findInstanceField(#orderNo)!,
      );

      expect(def.name, equals('orderNo'));
      expect(def.isPrimaryKey, isTrue);
      expect(def.valueType, equals(String));
      expect(def.elementType, isNull);
      expect(def.isCollection, isFalse);
      expect(def.valueGetter.call(order), equals('S123456789'));
      expect(def.elementGetter, isNull);
      expect(def.hasAssociation, isFalse);
      expect(def.association, isNull);

      def = parser.parsePropertyFromField(
        Order,
        reflectClass(Order).findInstanceField(#customerName)!,
      );

      expect(def.name, equals('customerName'));
      expect(def.isPrimaryKey, isFalse);
      expect(def.valueType, equals(String));
      expect(def.elementType, isNull);
      expect(def.isCollection, isFalse);
      expect(def.valueGetter.call(order), equals('Banana Inc.'));
      expect(def.elementGetter, isNull);
      expect(def.hasAssociation, isFalse);
      expect(def.association, isNull);

      def = parser.parsePropertyFromField(
        Order,
        reflectClass(Order).findInstanceField(#orderLines)!,
      );

      expect(def.name, equals('orderLines'));
      expect(def.isPrimaryKey, isFalse);
      expect(def.valueType, equals(List<OrderLine>));
      expect(def.elementType, equals(OrderLine));
      expect(def.isCollection, isTrue);
      expect(def.valueGetter.call(order), equals(order.orderLines));
      expect(def.elementGetter, isNotNull);
      expect(def.elementGetter!.call(order, 0), equals(order.orderLines[0]));
      expect(def.hasAssociation, isTrue);
      expect(def.association, isNotNull);
      expect(def.association?.classType, equals(OrderLine));
    });

    test('parse entity', () {
      final orm = Orm();

      final def = orm.tryParseEntity(Order);

      expect(def, isNotNull);
      expect(def?.classType, equals(Order));
      expect(def?.properties, hasLength(3));
      expect(def?.properties[0].name, equals('orderNo'));
      expect(def?.properties[1].name, equals('customerName'));
      expect(def?.properties[2].name, equals('orderLines'));
    });
  });

  group('ChangeTracker', () {
    test('capture changes', () {
      final tracker = ChangeTracker();
      final order = Order()
        ..orderNo = ''
        ..customerName = ''
        ..orderLines = []
        ..details = {};

      var changes = tracker.captureChanges(order, (order) {
        order.customerName = 'Banana Inc.';
      });

      expect(changes, hasLength(1));
      expect(
        changes,
        equals([
          isA<ValueUpdated>()
              .having((x) => x.snapshotNode.debugQualifiedName,
                  'debugQualifiedName', equals(r'$.customerName'))
              .having((x) => x.oldValue, 'oldValue', equals(''))
              .having((x) => x.newValue, 'newValue', equals('Banana Inc.'))
        ]),
      );

      changes = tracker.captureChanges(order, (order) {
        order.orderLines.add(
          OrderLine()
            ..productSku = 'Chocolate'
            ..purchaseCount = 1,
        );
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        isA<ElementAdded>()
            .having((x) => x.snapshotNode.debugQualifiedName,
                'debugQualifiedName', equals(r'$.orderLines'))
            .having((x) => x.newKey, 'newKey', equals(0))
            .having((x) => x.newValue, 'newValue', same(order.orderLines[0])),
      );

      changes = tracker.captureChanges(order, (order) {
        order.orderLines[0].productSku = 'Orange';
        order.orderLines[0].purchaseCount = 12;
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        isA<ElementUpdated>().having(
          (x) => x.updates,
          'updates',
          equals([
            isA<ValueUpdated>()
                .having(
                    (x) => x.snapshotNode.debugQualifiedName,
                    'debugQualifiedName',
                    equals(r'$.orderLines.[0].productSku'))
                .having((x) => x.oldValue, 'oldValue', equals('Chocolate'))
                .having((x) => x.newValue, 'newValue', equals('Orange')),
            isA<ValueUpdated>()
                .having(
                    (x) => x.snapshotNode.debugQualifiedName,
                    'debugQualifiedName',
                    equals(r'$.orderLines.[0].purchaseCount'))
                .having((x) => x.oldValue, 'oldValue', equals(1))
                .having((x) => x.newValue, 'newValue', equals(12))
          ]),
        ),
      );

      var removedOrderLine = order.orderLines[0];
      changes = tracker.captureChanges(order, (order) {
        order.orderLines.removeAt(0);
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        equals(
          isA<ElementRemoved>()
              .having((x) => x.snapshotNode.debugQualifiedName,
                  'debugQualifiedName', equals(r'$.orderLines'))
              .having((x) => x.oldKey, 'oldKey', equals(0))
              .having((x) => x.oldValue, 'oldValue', equals(removedOrderLine)),
        ),
      );

      changes = tracker.captureChanges(order, (order) {
        order.details['ext-1'] = 'hello';
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        equals(
          isA<ElementAdded>()
              .having((x) => x.snapshotNode.debugQualifiedName,
                  'debugQualifiedName', equals(r'$.details'))
              .having((x) => x.newKey, 'newKey', equals('ext-1'))
              .having((x) => x.newValue, 'newValue', equals('hello')),
        ),
      );

      changes = tracker.captureChanges(order, (order) {
        order.details['ext-1'] = 'world';
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        equals(isA<ElementUpdated>()
            .having((x) => x.snapshotNode.debugQualifiedName,
                'debugQualifiedName', equals(r'$.details'))
            .having((x) => x.key, 'key', equals('ext-1'))),
      );
      expect(
        (changes[0] as ElementUpdated).updates,
        equals([
          isA<ValueUpdated>()
              .having((x) => x.snapshotNode.debugQualifiedName,
                  'debugQualifiedName', equals(r"$.details.['ext-1']"))
              .having((x) => x.oldValue, 'oldValue', equals('hello'))
              .having((x) => x.newValue, 'newValue', equals('world')),
        ]),
      );

      changes = tracker.captureChanges(order, (order) {
        order.details.remove('ext-1');
      });

      expect(changes, hasLength(1));
      expect(
        changes[0],
        equals(
          isA<ElementRemoved>()
              .having((x) => x.snapshotNode.debugQualifiedName,
                  'debugQualifiedName', equals(r'$.details'))
              .having((x) => x.oldKey, 'oldKey', equals('ext-1'))
              .having((x) => x.oldValue, 'oldValue', equals('world')),
        ),
      );
    });
  });
}
