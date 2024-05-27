import 'dart:mirrors';

import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'package:kumino/src/utils/dart_mirrors/enhanced.dart';
import 'package:kumino/src/utils/dart_mirrors/pretty.dart';

class Foo {
  void method1() => throw UnimplementedError();
  void method2(int arg0) => throw UnimplementedError();
  void method3(int? arg0) => throw UnimplementedError();
  void method4(int arg0, [int arg1 = 0]) => throw UnimplementedError();
  void method5(int arg0, [int? arg1]) => throw UnimplementedError();
  void method6(int arg0, [int arg1 = 0, int arg2 = 0]) =>
      throw UnimplementedError();
  void method7(int arg0, {@required required int arg1}) =>
      throw UnimplementedError();
  void method8(int arg0, {int arg1 = 0}) => throw UnimplementedError();
}

void main() {
  test('.prettySimpleName', () {
    final method1 = reflectClass(Foo).findInstanceMethod(#method1)!;
    expect(method1.prettySimpleName, equals('method1'));

    final method2 = reflectClass(Foo).findInstanceMethod(#method2)!;
    expect(method2.prettySimpleName, equals('method2'));

    final method3 = reflectClass(Foo).findInstanceMethod(#method3)!;
    expect(method3.prettySimpleName, equals('method3'));
  });

  test('.prettyQualifiedName', () {
    final method1 = reflectClass(Foo).findInstanceMethod(#method1)!;
    expect(method1.prettyQualifiedName, equals('Foo.method1'));

    final method2 = reflectClass(Foo).findInstanceMethod(#method2)!;
    expect(method2.prettyQualifiedName, equals('Foo.method2'));

    final method3 = reflectClass(Foo).findInstanceMethod(#method3)!;
    expect(method3.prettyQualifiedName, equals('Foo.method3'));
  });

  test('.prettyMethodSignature', () {
    expect(
      reflectClass(Foo).findInstanceMethod(#method1)!.prettyMethodSignature,
      equals('void method1()'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method2)!.prettyMethodSignature,
      equals('void method2(int arg0)'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method3)!.prettyMethodSignature,
      equals('void method3(int arg0)'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method4)!.prettyMethodSignature,
      equals('void method4(int arg0, [int arg1])'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method5)!.prettyMethodSignature,
      equals('void method5(int arg0, [int arg1])'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method6)!.prettyMethodSignature,
      equals('void method6(int arg0, [int arg1, int arg2])'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method7)!.prettyMethodSignature,
      equals('void method7(int arg0, {required int arg1})'),
    );

    expect(
      reflectClass(Foo).findInstanceMethod(#method8)!.prettyMethodSignature,
      equals('void method8(int arg0, {int arg1})'),
    );
  });
}
