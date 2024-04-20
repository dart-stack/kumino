import 'package:mockito/annotations.dart';
import 'package:kumino/src/di/resolve.dart';

export 'resolve.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ServiceConfigurationFinder>(),
])
void unused() {}

class TestingServiceConfigurationFinder implements ServiceConfigurationFinder {
  final ServiceConfiguration? defaultOverrided;

  final Map<Type, ServiceConfiguration> configurations = {};

  TestingServiceConfigurationFinder({
    ServiceConfiguration? defaultConfiguration,
  }) : defaultOverrided = defaultConfiguration;

  void add<T>({
    required ServiceLifetime lifetime,
  }) {
    configurations[T] = (ServiceConfiguration(lifetime: lifetime));
  }

  @override
  ServiceConfiguration findOrDefaultServiceConfiguration(Type serviceType) {
    const defaultConfiguration = ServiceConfiguration(
      lifetime: ServiceLifetime.transient,
    );

    return configurations[serviceType] ??
        defaultOverrided ??
        defaultConfiguration;
  }
}
