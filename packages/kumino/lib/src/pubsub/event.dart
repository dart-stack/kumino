abstract interface class EventPublisher {
  Future<void> publishEvent<T>(T event);
}