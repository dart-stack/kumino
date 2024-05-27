import 'dart:io';
import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:kumino/annotations.dart' as annotations;
import 'package:kumino/src/dependency_injection/container.dart';
import 'package:kumino/src/hosting/reflect/application_impl.dart';
import 'package:kumino/src/hosting/mvc.dart';
import 'package:kumino/src/event/event.dart';
import 'package:kumino/src/utils/dart_mirrors/enhanced.dart';

import 'kumino_test.mocks.dart';
import 'reflect_test.mocks.dart';

@annotations.Components(
  imports: [
    FooService,
    BarService,
    BazService,
  ],
)
class App1 {}

@annotations.Components(
  imports: [],
)
class App2 {}

@annotations.Controllers([
  FooController,
  BarController,
  BazController,
])
class App3 {}

@annotations.EventListeners([
  FooEventListener,
])
class App4 {}

class FooService {}

class BarService {}

class BazService {}

class Cat {
  const Cat({required this.name});

  final String name;
}

class FooController {
  static List<Cat> cats = [];

  @annotations.GetRoute(path: '/api/v1/cats')
  Future findCats(HttpRequest request) async {
    throw UnimplementedError();
  }

  @annotations.PutRoute(path: '/api/v1/cats')
  Future recordCat(HttpRequest request, Cat cat) async {
    cats.add(cat);
  }
}

@annotations.ApiController()
class BarController {
  @annotations.RouteMapping(path: '/api/v1/animals')
  Future findAnimals(HttpRequest request) {
    throw UnimplementedError();
  }
}

@annotations.ApiController()
class BazController {
  @annotations.GetRoute(path: '/api/v1/fruits')
  Future findFruits(HttpRequest request) {
    throw UnimplementedError();
  }
}

class FooEvent {}

class FooEventListener {
  static List<FooEvent> events = [];

  @annotations.EventListener(subscribeTo: FooEvent)
  Future onFooEvent(FooEvent event) async {
    events.add(event);
  }
}

@GenerateNiceMocks([
  MockSpec<DIContainer>(),
])
void main() {
  group('ReflectedApplicationDelegate', () {
    test('.importedComponents', () {
      //
      var delegate = ReflectedApplicationDelegate(App1);

      expect(
        delegate.importedComponents,
        equals([FooService, BarService, BazService]),
      );

      //
      delegate = ReflectedApplicationDelegate(App2);

      expect(
        delegate.importedComponents,
        equals([]),
      );
    });

    test('.registerComponents()', () {
      //
      var delegate = ReflectedApplicationDelegate(App1);
      var container = MockDIContainer();

      delegate.registerComponents(container);

      verifyInOrder([
        container.add(FooService),
        container.add(BarService),
        container.add(BazService),
      ]);

      //
      delegate = ReflectedApplicationDelegate(App2);
      container = MockDIContainer();

      delegate.registerComponents(container);

      verifyZeroInteractions(container);
    });

    group('mvc', () {
      test('.importedControllers', () {
        final delegate = ReflectedApplicationDelegate(App3);

        expect(
          delegate.importedControllers,
          equals([FooController, BarController, BazController]),
        );
      });

      test('.registerComponents()', () {
        final delegate = ReflectedApplicationDelegate(App3);
        final container = MockDIContainer();

        delegate.registerComponents(container);

        verifyInOrder([
          container.add(FooController),
          container.add(BarController),
          container.add(BazController),
        ]);
      });

      test('.controllers', () {
        final delegate = ReflectedApplicationDelegate(App3);

        Matcher hasClassType(Type classType) {
          return isA<MvcController>()
              .having((x) => x.classType, 'classType', equals(classType));
        }

        expect(
          delegate.controllers,
          equals([
            hasClassType(FooController),
            hasClassType(BarController),
            hasClassType(BazController),
          ]),
        );
      });

      test('.parseController()', () {
        final delegate = ReflectedApplicationDelegate(App3);

        final controller = delegate.parseController(FooController);

        expect(controller.classType, equals(FooController));
        expect(controller.actions, hasLength(2));
      });

      test('.maybeParseAction()', () async {
        final delegate = ReflectedApplicationDelegate(App3);
        final action = delegate.maybeParseAction(
          FooController,
          reflectClass(FooController).instanceMembers[Symbol('recordCat')]!,
        );

        expect(action, isNotNull);
        expect(action?.method, 'PUT');
        expect(action?.path, '/api/v1/cats');
        final cat = Cat(name: 'Doby');
        await action?.invoker.call(
          FooController(),
          Invocation.method(Symbol.empty, [MockHttpRequest(), cat]),
        );
        expect(FooController.cats[0], equals(cat));

        //
        expect(
          () => action?.invoker
              .call(Object(), Invocation.method(Symbol.empty, [])),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('event', () {
      test('.importedEventListeners', () {
        final delegate = ReflectedApplicationDelegate(App4);

        expect(
          delegate.importedEventListeners,
          equals([FooEventListener]),
        );
      });

      test('.registerComponents()', () {
        final delegate = ReflectedApplicationDelegate(App4);
        final container = MockDIContainer();

        delegate.registerComponents(container);

        verifyInOrder([
          container.add(FooEventListener),
        ]);
      });

      test('.eventListeners', () {
        final delegate = ReflectedApplicationDelegate(App4);

        Matcher hasListener(Type classType, Type subscribeTo) {
          return isA<EventListener>()
              .having((x) => x.classType, 'classType', equals(classType))
              .having((x) => x.subscribeTo, 'subscribeTo', equals(subscribeTo));
        }

        expect(
          delegate.eventListeners,
          equals([
            hasListener(FooEventListener, FooEvent),
          ]),
        );
      });

      test('.maybeParseEventListener()', () async {
        final delegate = ReflectedApplicationDelegate(App4);
        final listener = delegate.maybeParseEventListener(
          FooEventListener,
          reflectClass(FooEventListener)
              .findInstanceMethod(Symbol('onFooEvent'))!,
        );

        expect(listener, isNotNull);
        expect(listener?.classType, equals(FooEventListener));
        expect(listener?.subscribeTo, equals(FooEvent));
        final event = FooEvent();
        await listener?.invoker.call(
          FooEventListener(),
          Invocation.method(Symbol.empty, [event]),
        );
        expect(FooEventListener.events[0], equals(event));

        //
        expect(
          () => listener?.invoker
              .call(Object(), Invocation.method(Symbol.empty, [])),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
