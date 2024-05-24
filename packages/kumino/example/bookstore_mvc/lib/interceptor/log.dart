import 'dart:async';

import 'package:kumino/kumino.dart';

class TraceFootprint implements Interceptor {
  @override
  FutureOr intercept(HttpRequest request, NextCall next) async{
    return next(request);
  }
}