import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class ControllersAnnotation {
  const ControllersAnnotation(this.controllers);

  final List<Type> controllers;
}

@Target({TargetKind.classType})
class ControllerAnnotation {
  const ControllerAnnotation({
    this.prefix = '',
    this.interceptors = const [],
  });

  final String prefix;
  final List<Type> interceptors;
}

@Target({TargetKind.classType})
class ApiControllerAnnotation extends ControllerAnnotation {
  const ApiControllerAnnotation({
    super.prefix,
    super.interceptors,
  });
}

@Target({TargetKind.method})
class RouteMappingAnnotation {
  const RouteMappingAnnotation({
    required this.path,
    required this.method,
    this.interceptors = const [],
  });

  final String method;
  final String path;
  final List<Type> interceptors;
}

@Target({TargetKind.method})
class GetRouteAnnotation extends RouteMappingAnnotation {
  const GetRouteAnnotation({
    required super.path,
    super.interceptors,
  }) : super(method: 'GET');
}

@Target({TargetKind.method})
class PostRouteAnnotation extends RouteMappingAnnotation {
  const PostRouteAnnotation({
    required super.path,
    super.interceptors,
  }) : super(method: 'POST');
}

@Target({TargetKind.method})
class PutRouteAnnotation extends RouteMappingAnnotation {
  const PutRouteAnnotation({
    required super.path,
    super.interceptors,
  }) : super(method: 'PUT');
}

@Target({TargetKind.method})
class PatchRouteAnnotation extends RouteMappingAnnotation {
  const PatchRouteAnnotation({
    required super.path,
    super.interceptors,
  }) : super(method: 'PATCH');
}

@Target({TargetKind.method})
class DeleteRouteAnnotation extends RouteMappingAnnotation {
  const DeleteRouteAnnotation({
    required super.path,
    super.interceptors,
  }) : super(method: 'DELETE');
}
