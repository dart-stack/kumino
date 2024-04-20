
class Controller {
  const Controller();
}

enum HttpMethod { get, post, put, delete, patch }

class HttpEndpoint {
  final String path;
  final HttpMethod method;

  const HttpEndpoint({
    required this.path,
    required this.method,
  });
}

class HttpGet extends HttpEndpoint {
  const HttpGet({
    required super.path,
  }) : super(
          method: HttpMethod.get,
        );
}

class HttpPost extends HttpEndpoint {
  const HttpPost({
    required super.path,
  }) : super(
          method: HttpMethod.post,
        );
}

class HttpPut extends HttpEndpoint {
  const HttpPut({
    required super.path,
  }) : super(
          method: HttpMethod.put,
        );
}

class HttpPatch extends HttpEndpoint {
  const HttpPatch({
    required super.path,
  }) : super(
          method: HttpMethod.patch,
        );
}

class HttpDelete extends HttpEndpoint {
  const HttpDelete({
    required super.path,
  }) : super(
          method: HttpMethod.delete,
        );
}
