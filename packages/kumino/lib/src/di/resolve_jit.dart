import 'package:kumino/src/reflect/mirrors.dart';

import 'resolve.dart';

class ServiceResolver {
  final Map<Type, dynamic> singletonInstances = {};

  dynamic resolve(
    Type serviceType,
    ServiceConfigurationFinder configurationFinder,
  ) {
    return _resolve(
      serviceType,
      ResolutionContext.root(),
      configurationFinder,
      {},
    );
  }

  dynamic _resolve(
    Type serviceType,
    ResolutionContext context,
    ServiceConfigurationFinder configurationFinder,
    Map<Type, dynamic> inRequestInstances,
  ) {
    if (context.serviceWasRequested(serviceType)) {
      throw Exception(
          "detect a ring in dependency graph: $serviceType -> $serviceType");
    }
    final configuration =
        configurationFinder.findOrDefaultServiceConfiguration(serviceType);
    if (configuration.lifetime == ServiceLifetime.singleton &&
        singletonInstances.containsKey(serviceType)) {
      return singletonInstances[serviceType];
    } else if (configuration.lifetime == ServiceLifetime.request &&
        inRequestInstances.containsKey(serviceType)) {
      return inRequestInstances[serviceType];
    }
    final classMirror = reflectClass(serviceType);
    final constructorMirror = _findPreferredConstructor(classMirror);
    final args = _resolveArguments(
      constructorMirror.parameters,
      context.createForSubRequest(serviceType),
      configurationFinder,
      inRequestInstances,
    );
    final instance = classMirror
        .newInstance(
          constructorMirror.constructorName,
          args.positionalArguments,
          args.namedArguments,
        )
        .reflectee;
    if (configuration.lifetime == ServiceLifetime.singleton) {
      singletonInstances[serviceType] = instance;
    } else if (configuration.lifetime == ServiceLifetime.request) {
      inRequestInstances[serviceType] = instance;
    }
    return instance;
  }

  MethodMirror _findPreferredConstructor(ClassMirror classMirror) {
    return classMirror.constructors.first;
  }

  Arguments _resolveArguments(
    List<ParameterMirror> paramsMirror,
    ResolutionContext context,
    ServiceConfigurationFinder configurationFinder,
    Map<Type, dynamic> inRequestInstances,
  ) {
    final args = Arguments();
    for (final paramMirror in paramsMirror) {
      // TODO(nullself): support optional parameter
      final resolved = _resolve(
        paramMirror.type.reflectedType,
        context,
        configurationFinder,
        inRequestInstances,
      );
      if (paramMirror.isNamed) {
        args.addNamed(paramMirror.simpleName, resolved);
      } else {
        args.addPositional(resolved);
      }
    }
    return args;
  }
}

class Arguments {
  final List<dynamic> _positionalArguments = [];

  final Map<Symbol, dynamic> _namedArguments = {};

  Arguments();

  List<dynamic> get positionalArguments => List.from(_positionalArguments);

  Map<Symbol, dynamic> get namedArguments => Map.from(_namedArguments);

  void addPositional(dynamic value) {
    _positionalArguments.add(value);
  }

  void addNamed(Symbol name, dynamic value) {
    _namedArguments[name] = value;
  }
}
