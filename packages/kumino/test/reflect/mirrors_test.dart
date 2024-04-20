import 'package:test/test.dart';

import 'package:kumino/src/reflect/mirrors.dart';

class X {
  const X();
}

@X()
class A {}

@X()
class B {}

class C {}

class D {
  const D();

  const D.ctor1();

  D.ctor2();

  factory D.fac1() => D();
}

void main() {
  test("should find all classes annotated with specified annotation", () {
    final classes = findClassesAnnotatedWithExactType<X>();

    expect(classes.map((e) => e.reflectedType.toString()), equals(['A', 'B']));
  });

  group("finding annotation on class", () {
    test(
        "should return the annotation when the class is annotated with the specified annotation",
        () {
      final clazz = reflectClass(A);
      final annotation = clazz.findAnnotation<X>();

      expect(annotation, isA<X>());
    });
  });

  group("finding the constructors of a class", () {
    test("should list all constructors", () {
      final mirror = reflectClass(D);

      expect(
        mirror.constructors.map((e) => e.simpleName),
        equals([
          Symbol('D'),
          Symbol('D.ctor1'),
          Symbol('D.ctor2'),
          Symbol('D.fac1')
        ]),
      );
    });

    test("should list all const constructors", () {
      final mirror = reflectClass(D);

      expect(
        mirror.constConstructors.map((e) => e.simpleName),
        equals([Symbol('D'), Symbol('D.ctor1')]),
      );
    });

    test("should list all factory constructors", () {
      final mirror = reflectClass(D);

      expect(
        mirror.factoryConstructors.map((e) => e.simpleName),
        equals([Symbol('D.fac1')]),
      );
    });
  });
}
