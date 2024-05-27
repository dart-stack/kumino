import 'dart:async';

class EventContext {}

typedef EventListenerInvoker = FutureOr Function(
  Object event,
  Invocation invocation,
);

class EventListener {
  late Type classType;
  late Type subscribeTo;
  late EventListenerInvoker invoker;

  FutureOr<void> invoke(Object instance, Object event) async {
    return invoker.call(instance, Invocation.method(Symbol.empty, [event]));
  }
}
