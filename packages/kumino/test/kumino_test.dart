import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpException;

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:kumino/annotations.dart';
import 'package:kumino/src/hosting/application.dart';
import 'package:kumino/src/hosting/reflect/application.dart';
import 'package:kumino/src/mvc/interception.dart';
import 'package:kumino/src/mvc/exception.dart';
import 'package:kumino/src/pubsub/event.dart';

import 'fixtures/http_server.dart';
import 'kumino_test.mocks.dart';

@Controllers([
  GreetingController,
])
class App1 {}

@Controllers([
  GreetingController,
])
@Components(
  imports: [RequireLoggedIn],
)
class App2 {}

@Components(
  imports: [FooService],
)
@Module(
  exports: [FooService],
)
class Module1 {}

class FooService {}

class RequireLoggedIn implements Interceptor {
  @override
  FutureOr intercept(HttpRequest request, NextCall next) {
    final token = request.headers.value(HttpHeaders.authorizationHeader);
    if (token != 'Bearer 123456') {
      throw HttpException(
        statusCode: 401,
        message: {
          'success': false,
          'error': {
            'code': 401,
            'message': 'this request is required to be authenticated',
          }
        },
      );
    }
    return next(request);
  }
}

@Controllers([OrderController])
@EventListeners([NewOrderHandler])
class App3 {}

class NewOrder {
  late String id;
  late String customerName;
  late String sku;
}

@ApiController()
class GreetingController {
  @GetRoute(path: '/api/v1/greet')
  Future greet(HttpRequest request) async {
    return {
      'success': true,
      'data': 'Hello, World!',
    };
  }
}

@ApiController()
class OrderController {
  OrderController(this.eventPublisher);

  final EventPublisher eventPublisher;

  @PutRoute(path: '/api/v1/orders')
  FutureOr newOrder(HttpRequest request) async {
    final newOrder = json.decode(await utf8.decodeStream(request));
    await eventPublisher.publishEvent<NewOrder>(
      NewOrder()
        ..id = newOrder['id']
        ..customerName = newOrder['customerName']
        ..sku = newOrder['sku'],
    );

    return {
      'success': true,
      'transaction': {
        'state': 'COMMITTED',
      }
    };
  }
}

class NewOrderHandler {
  static List<NewOrder> newOrders = [];

  @EventListener(subscribeTo: NewOrder)
  FutureOr onNewOrder(NewOrder event) {
    newOrders.add(event);
  }
}

@GenerateNiceMocks([
  MockSpec<HttpRequest>(),
  MockSpec<HttpHeaders>(),
])
void main() {
  group('Application', () {
    late HttpServerTestFixture httpServerFixture;

    setUp(() async {
      httpServerFixture = HttpServerTestFixture();
      await httpServerFixture.setUp();
    });

    tearDown(() async {
      await httpServerFixture.tearDown();
    });

    group('MVC related', () {
      group('.buildCallChain()', () {
        // TODO(mc): check the execution order.

        test('intercepted', () {
          final app = Application(delegateTo<App2>())
            ..addInterceptor<RequireLoggedIn>();
          final req = MockHttpRequest();
          final headers = MockHttpHeaders();
          when(req.headers).thenReturn(headers);
          when(headers.value(HttpHeaders.authorizationHeader)).thenReturn('');

          final call = app.buildCallChain((req) => {});

          expect(
            () async => call(req),
            throwsA(
              isA<HttpException>()
                  .having((x) => x.statusCode, 'statusCode', equals(401)),
            ),
          );
        });

        test('not intercepted', () async {
          final app = Application(delegateTo<App2>())
            ..addInterceptor<RequireLoggedIn>();
          final req = MockHttpRequest();
          final headers = MockHttpHeaders();
          when(req.headers).thenReturn(headers);
          when(headers.value(HttpHeaders.authorizationHeader))
              .thenReturn('Bearer 123456');

          final call = app.buildCallChain((req) => 'ok');

          expect(await call(req), equals('ok'));
        });
      });

      test('handle HTTP request by controller', () async {
        final app = Application(delegateTo<App1>());

        unawaited(app.run(httpServerFixture.server));

        expect(
          await httpServerFixture
              .send('GET', '/api/v1/greet')
              .timeout(Duration(seconds: 1))
              .then((res) => res.asJson()),
          equals({
            'success': true,
            'data': 'Hello, World!',
          }),
        );
      });

      test('intercept a HTTP request', () async {
        final app = Application(delegateTo<App2>())
          ..addInterceptor<RequireLoggedIn>();

        unawaited(app.run(httpServerFixture.server));

        final res = await httpServerFixture
            .send('GET', '/api/v1/greet')
            .timeout(Duration(seconds: 1));
        expect(res.statusCode, equals(401));
        expect(
          await res.asJson(),
          equals({
            'success': false,
            'error': {
              'code': 401,
              'message': 'this request is required to be authenticated',
            }
          }),
        );
      });
    });

    group('event related', () {
      test('event listener', () async {
        final app = Application(delegateTo<App3>());

        unawaited(app.run(httpServerFixture.server));

        await httpServerFixture
            .send(
              'PUT',
              '/api/v1/orders',
              configure: (req) => req.write(json.encode({
                'id': 'o123456',
                'customerName': 'Banana Inc.',
                'sku': 'Chocolate',
              })),
            )
            .timeout(Duration(seconds: 1))
            .then((res) => res.join());

        expect(NewOrderHandler.newOrders, hasLength(1));
        final newOrder = NewOrderHandler.newOrders[0];
        expect(newOrder.id, equals('o123456'));
        expect(newOrder.customerName, equals('Banana Inc.'));
        expect(newOrder.sku, equals('Chocolate'));
      });
    });
  });
}
