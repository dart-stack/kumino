import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class ModuleAnnotation {
  const ModuleAnnotation({
    this.exports = const [],
  });

  final List<Type> exports;
}
