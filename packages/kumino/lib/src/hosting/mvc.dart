import 'dart:async';

class MvcController {
  late Type classType;

  late List<MvcAction> actions;
}

typedef MvcActionInvoker = FutureOr Function(
  Object controllerInstance,
  Invocation invocation,
);

class MvcAction {
  late String method;
  late String path;
  late MvcActionInvoker invoker;

  FutureOr invoke(Object controllerInstance, Object request) => invoker.call(
        controllerInstance,
        Invocation.method(Symbol.empty, [request]),
      );
}
