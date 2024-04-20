import 'dart:io';

import 'package:kumino/src/di/container.dart';
import 'package:kumino/src/di/resolve.dart';
import 'package:kumino/src/mvc/annotations.dart';
import 'package:kumino/src/reflect/mirrors.dart';
import 'package:spry/spry.dart' as spry;

void addControllers(spry.Application app) {
  final container = ServiceContainer();

  final controllers = _scanControllers();
  for (final controller in controllers) {
    _registerController(container, controller);
    final actions = _scanRouteActions(controller);
    for (final action in actions) {
      _registerRoute(app, container, action);
    }
  }
}

void _registerController(ServiceContainer container, ClassMirror controller) {
  container.addService(
    type: controller.reflectedType,
    lifetime: ServiceLifetime.request,
  );
}

List<ClassMirror> _scanControllers() {
  return findClassesAnnotatedWithExactType<Controller>();
}

List<RouteAction> _scanRouteActions(ClassMirror controller) {
  final actions = <RouteAction>[];
  for (final method in controller.methods) {
    final annotation = method.findAnnotation<HttpEndpoint>();
    if (annotation == null) {
      continue;
    }
    actions.add(RouteAction(annotation, controller, method));
  }
  return actions;
}

void _registerRoute(
  spry.Application app,
  ServiceContainer container,
  RouteAction action,
) {
  app.on(
    (req) => action.invoke(req, container),
    method: _mapToMethod(action.annotation.method),
    path: action.annotation.path,
  );
}

class RouteAction {
  final HttpEndpoint annotation;

  final ClassMirror controller;

  final MethodMirror method;

  RouteAction(this.annotation, this.controller, this.method);

  invoke(HttpRequest request, ServiceContainer container) {
    final controllerInstance = container.getService(controller.reflectedType);
    return reflect(controllerInstance)
        .invoke(method.simpleName, [request], {}).reflectee;
  }
}

String _mapToMethod(HttpMethod method) => switch (method) {
      HttpMethod.get => "GET",
      HttpMethod.post => "POST",
      HttpMethod.put => "PUT",
      HttpMethod.delete => "DELETE",
      HttpMethod.patch => "PATCH",
    };
