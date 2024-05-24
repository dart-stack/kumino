import 'package:ansicolor/ansicolor.dart';

class TestLogger {
  static void info(String message) {
    final pen = AnsiPen()..green();
    print(pen('[INFO] $message'));
  }
}
