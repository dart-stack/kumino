import 'package:test/test.dart';

import 'package:kumino/src/dependency_injection/container.dart';

class A {
  A();
}

class B {
  B(A a);
}

class C {
  C(A a, B b);
}

class X {}

void main() {
  group('DIContainer', () {
    test('.resolve()', () async {
      //
      var container = DIContainer()
        ..add(A)
        ..add(B)
        ..add(C);

      expect(await container.resolveT<C>(), isA<C>());

      //
      final x = X();
      container = DIContainer()..bindInstanceT<X>(x);

      expect(await container.resolveT<X>(), equals(x));
    });
  });
}
