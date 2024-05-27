import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class ComponentsAnnotation {
  const ComponentsAnnotation({
    this.imports = const [],
  });

  final List<Type> imports;
}

@Target({TargetKind.classType})
class ComponentAnnotation {
  const ComponentAnnotation();
}
