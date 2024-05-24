import 'dart:async';

import 'mvc.dart';

class Application {
  Application(this._delegate);

  final ApplicationDelegate _delegate;

  Future<void> run() async {
    
  }
}

abstract interface class ApplicationDelegate {
  List<MvcController> get controllers;
}