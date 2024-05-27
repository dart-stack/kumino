import 'dart:async';

abstract interface class EventPublisher {
  FutureOr<void> publishEvent<T extends Object>(T event);
}
