import 'dart:io';
import 'dart:async';

import 'package:kumino/kumino.dart';

class RequireLogin implements Interceptor {
  @override
  FutureOr intercept(HttpRequest request, NextCall next) async {
    const token = "Bearer 123456";
    if (request.headers.value(HttpHeaders.authorizationHeader) != token) {
      throw HttpException("Unauthorized");
    }
    return next(request);
  }
}
