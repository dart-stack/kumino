import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class EntityAnnotation {
  const EntityAnnotation();
}

@Target({TargetKind.field, TargetKind.getter})
class PrimaryKeyAnnotation {
  const PrimaryKeyAnnotation();
}

@Target({TargetKind.field, TargetKind.getter})
class IndexAnnotation {
  const IndexAnnotation();
}
