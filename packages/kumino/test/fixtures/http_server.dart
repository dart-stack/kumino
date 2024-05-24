import 'dart:convert';
import 'dart:io';

import 'logging.dart';

class HttpServerTestFixture {
  late final HttpServer server;

  late final HttpClient client;

  Future<void> setUp() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    TestLogger.info(
        'HTTP server is running at ${server.address.address}:${server.port}');
    client = HttpClient();
  }

  Future<void> tearDown() async {
    await server.close(force: true);
  }

  Future<HttpClientResponse> send(
    String method,
    String path, {
    HttpClientRequest Function(HttpClientRequest)? configure,
    Duration? timeout,
  }) async {
    return client
        .open(method, server.address.address, server.port, path)
        .then((req) => (configure?.call(req) ?? req).done);
  }
}

extension HttpClientResponseReaderExtensions on HttpClientResponse {
  Future<String> asText([Encoding encoding = utf8]) async {
    return encoding.decodeStream(this);
  }

  Future<Map> asJson([Encoding encoding = utf8]) async {
    return json.decode(await encoding.decodeStream(this));
  }
}
