enum ServiceLifetime {
  singleton,
  transient,
  request,
}

class ServiceConfiguration {
  final ServiceLifetime lifetime;

  const ServiceConfiguration({
    required this.lifetime,
  });
}

abstract interface class ServiceConfigurationFinder {
  ServiceConfiguration findOrDefaultServiceConfiguration(Type serviceType);
}

class ResolutionContext {
  final ResolutionContext? parent;

  final Type serviceType;

  ResolutionContext.root()
      : serviceType = Null,
        parent = null;

  ResolutionContext._internal(this.parent, this.serviceType);

  ResolutionContext createForSubRequest(Type serviceType) =>
      ResolutionContext._internal(this, serviceType);

  bool serviceWasRequested(Type serviceType) {
    if (serviceType == this.serviceType) {
      return true;
    }
    return parent != null ? parent!.serviceWasRequested(serviceType) : false;
  }
}
