import '../http/request.dart';

extension HttpRequestSerializationExtensions on HttpRequest {
  Future<T> serializeBodyAs<T>() async {
    throw UnimplementedError();
  }
}
