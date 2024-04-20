import 'resolve.dart';
import 'resolve_aot.dart' if (dart.library.mirrors) 'resolve_jit.dart';

abstract interface class ServiceCollection {
  void addService<T>({
    Type? type,
    ServiceLifetime lifetime,
  });
}

// TODO(nullself): (DELAYED DECISION) Consider introduce a builder to keep
//  service declarations to be immutable.
abstract interface class ServiceContainer extends ServiceCollection {
  factory ServiceContainer() = _ServiceContainer;

  T getService<T>([Type? type]);
}

bool _aotEnabled = false;

class _ServiceContainer
    implements ServiceContainer, ServiceCollection, ServiceConfigurationFinder {
  final Map<Type, ServiceConfiguration> _serviceConfigurations = {};

  final ServiceResolver _resolver = ServiceResolver();

  @override
  void addService<T>({
    Type? type,
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    _serviceConfigurations[type ?? T] = ServiceConfiguration(
      lifetime: lifetime,
    );
  }

  @override
  T getService<T>([Type? type]) {
    return _resolver.resolve(type ?? T, this) as T;
  }

  @override
  ServiceConfiguration findOrDefaultServiceConfiguration(Type serviceType) {
    const defaultServiceConfiguration = ServiceConfiguration(
      lifetime: ServiceLifetime.transient,
    );

    return _serviceConfigurations[serviceType] ?? defaultServiceConfiguration;
  }
}
