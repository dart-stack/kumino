import 'dart:async';

import 'package:test/test.dart';

import 'package:kumino/src/hosting/application.dart';
import 'package:kumino/src/hosting/reflect/application.dart';
import 'package:kumino/src/mvc/annotations.dart';

import 'fixtures/http_server.dart';

@Controllers([
  GreetingController,
])
class AppDelegate {

}

@ApiController()
class GreetingController {
  @HttpGet(path: '/api/v1/home')
  Future greet() async {
    return {
      'success': true,
      'data': 'Hello, World!',
    };
  }
}


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

    test('registering a controller', () async {
      final app = Application(delegateTo<AppDelegate>());
      unawaited(app.run());

      expect(
        await httpServerFixture
            .send('GET', '/api/v1/home')
            .timeout(Duration(seconds: 1))
            .then((res) => res.asJson()),
        equals({
          'success': true,
          'data': 'Hello, World!',
        }),
      );
    });
  });

}
