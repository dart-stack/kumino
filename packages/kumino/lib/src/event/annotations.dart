import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class EventListenersAnnotation {
  const EventListenersAnnotation(this.eventListeners);

  final List<Type> eventListeners;
}

@Target({TargetKind.method})
class EventListenerAnnotation {
  const EventListenerAnnotation({required this.subscribeTo});

  final Type subscribeTo;
}
