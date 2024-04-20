class WebServer {
  static WebServerBuilder builder() => throw UnimplementedError();
}

abstract interface class WebServerBuilder {
  WebServerBuilder useHttp2();

  WebServerBuilder configureHttp2();

  WebServerBuilder useQuic();

  WebServerBuilder configureQuic();

  WebServerBuilder configureHttps(HttpsConfigurationBuilder Function(HttpsConfigurationBuilder) configurator);

  WebServerBuilder enableWebSocket();

  WebServerBuilder configureWebSocket();

  WebServerBuilder enableSse();

  WebServerBuilder configureSse();
}

abstract interface class HttpsConfigurationBuilder {}