import '_internal/http_types.dart';

abstract interface class HttpRequest implements DartHttpRequest {
  QueryParametersAccessor get query;

  PathParametersAccessor get params;
}

abstract interface class PathParametersAccessor {
  T value<T>(String name) {
    throw UnimplementedError();
  }
}

abstract interface class QueryParametersAccessor {
  T value<T>(String name) {
    throw UnimplementedError();
  }
}