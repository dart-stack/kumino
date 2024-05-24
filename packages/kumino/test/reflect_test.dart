import 'package:test/test.dart';

import 'package:kumino/src/dependency_injection/annotations.dart';
import 'package:kumino/src/hosting/reflect/application_impl.dart';
import 'package:kumino/src/hosting/mvc.dart';
import 'package:kumino/src/mvc/annotations.dart';

@Controllers([
  FooController,
])
@Components(
  imports: [BarController],
)
class Delegate {}

class FooController {
  @HttpGet(path: '/api/v1/cats')
  Future findCats() {
    throw UnimplementedError();
  }
}

@ApiController()
class BarController {
  @HttpGet(path: '/api/v1/animals')
  Future findAnimals() {
    throw UnimplementedError();
  }
}

void main() {
  group('ReflectedApplicationDelegate', () {
    test('.importedControllers', () {
      final delegate = ReflectedApplicationDelegate(Delegate);

      expect(
        delegate.importedControllers,
        equals([FooController, BarController]),
      );
    });

    test('.controllers', () {
      final delegate = ReflectedApplicationDelegate(Delegate);

      expect(
        delegate.controllers,
        equals([
          isA<MvcController>().having(
            (x) => x.actions,
            'actions',
            equals([
              isA<MvcAction>()
                  .having((x) => x.path, 'path', equals('/api/v1/cats'))
            ]),
          ),
          isA<MvcController>().having(
            (x) => x.actions,
            'actions',
            equals([
              isA<MvcAction>()
                  .having((x) => x.path, 'path', equals('/api/v1/animals'))
            ]),
          ),
        ]),
      );
    });
  });
}
