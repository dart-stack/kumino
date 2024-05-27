import 'dart:io';

class PathParametersAccessor {
  T value<T>(String name) {
    throw UnimplementedError();
  }
}

class QueryParametersAccessor {
  T value<T>(String name) {
    throw UnimplementedError();
  }
}

extension EnhancedHttpRequest on HttpRequest {
  QueryParametersAccessor get query => QueryParametersAccessor();

  PathParametersAccessor get params => PathParametersAccessor();
}
