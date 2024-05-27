import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:spry/spry.dart' as spry;

import '../dependency_injection/container.dart';
import '../event/event.dart';
import '../mvc/exception.dart';
import '../mvc/interception.dart';
import '../pubsub/event.dart';
import 'mvc.dart';

class _DebugExceptionFilter implements spry.ExceptionFilter<Exception> {
  @override
  Future<void> process(
    spry.ExceptionSource source,
    HttpRequest request,
  ) async {
    throw spry.RethrowException();
  }
}

class _HttpExceptionFilter implements spry.ExceptionFilter<HttpException> {
  @override
  Future<void> process(
    spry.ExceptionSource source,
    HttpRequest request,
  ) async {
    request.response.statusCode = source.exception.statusCode;
    request.response.write(json.encode(source.exception.message));
  }
}

class Application {
  Application(this._delegate);

  final ApplicationDelegate _delegate;

  final DIContainer _container = DIContainer();

  final List<Type> _interceptors = [];

  Future<void> run(HttpServer httpServer) async {
    registerKuminoComponents();
    registerUserComponents();
    await startServer(httpServer);
  }

  void registerKuminoComponents() {
    _container.bindInstanceT<EventPublisher>(EventPublisherImpl(this));
  }

  void registerUserComponents() {
    _delegate.registerComponents(_container);
  }

  void addInterceptor<T>() {
    _container.add(T);
    _interceptors.add(T);
  }

  Future<void> startServer(HttpServer httpServer) async {
    final spryServer = spry.Application(httpServer);
    spryServer.exceptions.addFilter<HttpException>(_HttpExceptionFilter());
    spryServer.exceptions.addFilter<Exception>(_DebugExceptionFilter());

    for (final controller in _delegate.controllers) {
      for (final action in controller.actions) {
        FutureOr finalCall(HttpRequest request) async {
          // instantiate controller
          final controllerInstance =
              await _container.resolve(controller.classType);
          // call method
          final result = action.invoke(controllerInstance, request);
          // transform result

          // return result
          return result;
        }

        spryServer.on(
          method: action.method,
          path: action.path,
          buildCallChain(finalCall),
        );
      }
    }
    await spryServer.listen().asFuture();
  }

  FutureOr Function(HttpRequest) buildCallChain(
    FutureOr Function(HttpRequest) finalCall,
  ) {
    return _interceptors.reversed.fold(finalCall, buildNextCall);
  }

  FutureOr Function(HttpRequest) buildNextCall(
    NextCall next,
    Type interceptorType,
  ) {
    FutureOr nextCall(HttpRequest request) async {
      final interceptor =
          await _container.resolve(interceptorType) as Interceptor;
      return interceptor.intercept(request, next);
    }

    return nextCall;
  }
}

abstract interface class ApplicationDelegate {
  List<MvcController> get controllers;

  List<EventListener> get eventListeners;

  void registerComponents(DIContainer container);
}

class EventPublisherImpl implements EventPublisher {
  EventPublisherImpl(this._application);

  final Application _application;

  @override
  FutureOr<void> publishEvent<T extends Object>(T event) async {
    final listener = _application._delegate.eventListeners
        .where((x) => x.subscribeTo == T)
        .firstOrNull;
    if (listener == null) {
      return;
    }
    final instance = await _application._container.resolve(listener.classType);
    await listener.invoke(instance, event);
  }
}
