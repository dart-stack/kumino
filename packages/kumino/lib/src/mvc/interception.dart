import 'dart:async';

import '../http/request.dart';

// TODO: Supports add an interceptor with high-order function?

typedef NextCall = FutureOr Function(HttpRequest request);

abstract interface class Interceptor {
  FutureOr intercept(HttpRequest request, NextCall next);
}
