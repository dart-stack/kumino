import 'dart:io';

extension HttpRequestSerializationExtensions on HttpRequest {
  Future<T> serializeBodyAs<T>() async {
    throw UnimplementedError();
  }
}
