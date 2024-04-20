import 'dart:io';

import 'package:kumino/mvc.dart';
import 'package:spry/spry.dart' as spry;

void main(List<String> args) async {
  final server = await HttpServer.bind("127.0.0.1", 61234);
  print("server is running at http://127.0.0.1:${server.port}");

  final app = spry.Application(server);
  app.get("/health", (request) async => "200 OK");
  addControllers(app);

  app.listen();
}

@Controller()
class ReportController {
  @HttpGet(path: "/api/v1/resource")
  doGet(HttpRequest request) {
    return "GET";
  }

  @HttpPost(path: "/api/v1/resource")
  doPost(HttpRequest request) {
    return "POST";
  }

  @HttpPut(path: "/api/v1/resource")
  doPut(HttpRequest request) {
    return "PUT";
  }

  @HttpPatch(path: "/api/v1/resource")
  doPatch(HttpRequest request) {
    return "PATCH";
  }

  @HttpDelete(path: "/api/v1/resource")
  doDelete(HttpRequest request) {
    return "DELETE";
  }
}
