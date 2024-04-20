import 'resolve.dart';

class AotServiceRegistry {
  static AotServiceRegistry? _instance;

  static AotServiceRegistry get instance => _instance ??= AotServiceRegistry();

  final Map<Type, AotServiceSpec> _services = {};

  void addService(AotServiceSpec service) {
    _services[service.serviceType] = service;
  }

  AotServiceSpec? findService<T>([Type? type]) {
    return _services[type ?? T];
  }
}

class AotServiceSpec {
  final Type serviceType;
  final Function(ServiceResolver) resolver;

  AotServiceSpec({
    required this.serviceType,
    required this.resolver,
  });
}

class ServiceResolver {
  dynamic resolve(
    Type serviceType,
    ServiceConfigurationFinder configurationFinder,
  ) {}
}
