class Controllers {
  const Controllers(this.controllers);

  final List<Type> controllers;
}

class Controller {}

class ApiController implements Controller {
  const ApiController({
    this.prefix = '',
    this.interceptors = const [],
  });

  final String prefix;
  final List<Type> interceptors;
}

class RouteMapping {
  const RouteMapping({
    required this.path,
    required this.method,
    this.interceptors = const [],
  });

  final String method;
  final String path;
  final List<Type> interceptors;
}

class HttpGet extends RouteMapping {
  const HttpGet({
    required super.path,
    super.interceptors,
  }) : super(method: 'GET');
}

class HttpPost extends RouteMapping {
  const HttpPost({
    required super.path,
    super.interceptors,
  }) : super(method: 'POST');
}

class HttpPut extends RouteMapping {
  const HttpPut({
    required super.path,
    super.interceptors,
  }) : super(method: 'PUT');
}

class HttpDelete extends RouteMapping {
  const HttpDelete({
    required super.path,
    super.interceptors,
  }) : super(method: 'DELETE');
}

class HttpPatch extends RouteMapping {
  const HttpPatch({
    required super.path,
    super.interceptors,
  }) : super(method: 'PATCH');
}
