import 'dart:async';
import 'dart:developer';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/scaffolding.dart';

class MyBuilder implements 
Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final library = await buildStep.inputLibrary;
    final node = await buildStep.resolver.astNodeFor(library.units[0].functions[0]);
    debugger();
  }
}

void main() {
  test("should test", () async {
    await testBuilder(
      MyBuilder(),
      {
        "kumino|lib/testdata.dart": '''
import 'package:kumino/kumino.dart';

void main() {
  print("123");
  int i = 1 + 2;
  print("123");
}
'''
      },
      reader: await PackageAssetReader.currentIsolate(),
    );
  });
}
