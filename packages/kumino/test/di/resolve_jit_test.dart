import 'package:test/test.dart';

import 'package:kumino/src/di/resolve.dart';
import 'package:kumino/src/di/resolve_jit.dart';

import 'resolve.dart';

class X {}

class Y {}

class A {
  final X p1;

  A(this.p1);
}

class B {
  final Y n1;

  B({required this.n1});
}

class C {
  final X p1;
  final Y n1;

  C(this.p1, {required this.n1});
}

class D {
  final D p1;

  D(this.p1);
}

class E {
  final B p1;
  final B p2;

  E(this.p1, this.p2);
}

void main() {
  test("should resolve a class with no dependencies", () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();

    final result = resolver.resolve(X, finder);

    expect(result, isA<X>());
  });

  group("should resolve a class with dependencies", () {
    test("when the dependency is placed on a positional parameter", () {
      final resolver = ServiceResolver();
      final finder = TestingServiceConfigurationFinder();

      final result = resolver.resolve(A, finder);

      expect(result, isA<A>());
      expect(result.p1, isA<X>());
    });

    test("when the dependency is placed on a named parameter", () {
      final resolver = ServiceResolver();
      final finder = TestingServiceConfigurationFinder();

      final result = resolver.resolve(B, finder);

      expect(result, isA<B>());
      expect(result.n1, isA<Y>());
    });

    test(
        "when the dependencies is placed on both positional and named parameter",
        () {
      final resolver = ServiceResolver();
      final finder = TestingServiceConfigurationFinder();

      final result = resolver.resolve(C, finder);

      expect(result, isA<C>());
      expect(result.p1, isA<X>());
      expect(result.n1, isA<Y>());
    });
  });

  test("should throw when ring is appeared during resolution", () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();

    expect(() => resolver.resolve(D, finder), throwsException);
  });

  test("should configure a service with transient lifetime by default", () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();

    final first = resolver.resolve(A, finder);
    final second = resolver.resolve(A, finder);

    expect(first, isNot(equals(second)));
    expect(first.p1, isNot(equals(second.p1)));
  });

  test(
      "should create a new instance at any time when a service is configured with transient lifetime",
      () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();
    finder.add<X>(lifetime: ServiceLifetime.transient);
    finder.add<A>(lifetime: ServiceLifetime.transient);

    final first = resolver.resolve(A, finder);
    final second = resolver.resolve(A, finder);

    expect(first, isNot(equals(second)));
    expect(first.p1, isNot(equals(second.p1)));
  });

  test(
      "should keep the same instance at any time when a service is configured with singleton lifetime",
      () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();
    finder.add<X>(lifetime: ServiceLifetime.singleton);
    finder.add<A>(lifetime: ServiceLifetime.singleton);

    final first = resolver.resolve(A, finder);
    final second = resolver.resolve(A, finder);

    expect(first, equals(second));
    expect(first.p1, equals(second.p1));
  });

  test(
      "should keep the same instance during the current resolution when a service is configured with request lifetime",
      () {
    final resolver = ServiceResolver();
    final finder = TestingServiceConfigurationFinder();
    finder.add<B>(lifetime: ServiceLifetime.request);
    finder.add<E>(lifetime: ServiceLifetime.transient);

    final first = resolver.resolve(E, finder);
    final second = resolver.resolve(E, finder);

    expect(first, isNot(equals(second)));
    expect(first.p1, equals(first.p2));
    expect(second.p1, equals(second.p2));
    expect(first.p1, isNot(equals(second.p1)));
    expect(first.p2, isNot(equals(second.p2)));
  });
}
