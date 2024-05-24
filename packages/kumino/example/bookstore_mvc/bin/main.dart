import 'package:kumino/kumino.dart';
import 'package:kumino/reflect.dart';

import 'package:bookstore_mvc/app.dart';

void main(List<String> args) async {
  final app = Application(delegateTo<AppDelegate>());
  await app.run();
}
