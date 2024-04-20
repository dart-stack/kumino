import 'dart:async';

import 'package:build/build.dart';

Builder generateCode(BuilderOptions options) {
  return _Codegen();
}

class _Codegen implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => throw UnimplementedError();
  
}