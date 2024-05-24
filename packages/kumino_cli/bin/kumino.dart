import 'dart:io';

class Args {}

void main(List<String> args) async {
  print("Current Working Directory: ${Environment.workingDirectory.path}");
  print("CLI Arguments: $args");

  await build(Args());
}

Future<void> build(Args args) async {
  final proc = await Process.start("dart", ["info"]);
  await Future.wait([
    stdout.addStream(proc.stdout),
    stderr.addStream(proc.stderr),
  ]);
}

class Environment {
  static Directory get workingDirectory => Directory.current;
}
