import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:spry/spry.dart' as spry;

class A {
  hello(HttpRequest request) {
    return "Hello, World!";
  }
}

class AotRouteAction {
  final String path;
  final String method;
  final dynamic invoker;

  AotRouteAction({
    required this.path,
    required this.method,
    required this.invoker,
  });
}

void registerRouteAction(spry.Application app, AotRouteAction action) {}

void main() {
  test("should be OK", () {
    final app = spry.Application.late();
    registerRouteAction(
        app,
        AotRouteAction(
          path: '/api/v1/hello',
          method: 'GET',
          invoker: (controller, request) => controller.hello(request),
        ));
  });
}
