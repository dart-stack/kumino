import 'dart:mirrors';

import 'package:meta/meta.dart';

import 'enhanced.dart';

extension PrettyDeclaration on DeclarationMirror {
  String get prettySimpleName {
    return simpleName.name;
  }

  String get prettyQualifiedName {
    final clazz = owner! as ClassMirror;

    return '${clazz.simpleName.name}.${simpleName.name}';
  }
}

extension PrettyMethod on MethodMirror {
  String get prettyMethodSignature {
    final returnType = this.returnType.simpleName.name;
    final methodName = prettySimpleName;
    final requiredParams = <String>[];
    final optionalParams = <String>[];
    final namedParams = <String>[];
    bool hasNamedParams = false;

    for (final param in parameters) {
      if (!param.isNamed) {
        if (!param.isOptional) {
          requiredParams.add(
            '${param.type.simpleName.name} ${param.simpleName.name}',
          );
        } else {
          optionalParams.add(
            '${param.type.simpleName.name} ${param.simpleName.name}',
          );
        }
      } else {
        hasNamedParams = true;
        // NOTE: 'dart:mirrors' doesn't support to recognize the keyword
        //  'required' for named parameter. we use the annotations of
        //  'package:meta' to determine that is required.
        if (param.hasExactAnnotation(required)) {
          namedParams.add(
            'required ${param.type.simpleName.name} ${param.simpleName.name}',
          );
        } else {
          namedParams.add(
            '${param.type.simpleName.name} ${param.simpleName.name}',
          );
        }
      }
    }

    final sb = StringBuffer();
    // ignore: cascade_invocations
    sb.writeAll([
      '$returnType ',
      '$methodName(',
      requiredParams.join(', '),
      ...optionalParams.isEmpty
          ? []
          : [
              ', ',
              '[',
              optionalParams.join(', '),
              ']',
            ],
      ...!hasNamedParams
          ? []
          : [
              ', ',
              '{',
              namedParams.join(', '),
              '}',
            ],
      ')',
    ]);

    return sb.toString();
  }
}
