import 'package:kumino/src/di/container.dart';
import 'package:reflectable/reflectable.dart';
import 'package:test/test.dart';

class Service extends Reflectable {
  const Service(): super.fromList(const []);
}

@Service()
class X {}

class Y {}


class A {
  final X p1;
  final Y p2;

  A(this.p1, this.p2);
}

class AotServiceSpec {
  final Type serviceType;
  final Function(ServiceContainer) resolver;

  AotServiceSpec({
    required this.serviceType,
    required this.resolver,
  });
}

void main() {
  test("should be OK", () {
    final container = ServiceContainer();
      AotServiceSpec(
        serviceType: A,
        resolver: (container) =>
            A(container.getService<X>(), container.getService<Y>()),
    );
  });
}
