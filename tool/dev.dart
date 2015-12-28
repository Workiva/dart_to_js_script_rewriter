library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  config.analyze.entryPoints = ['lib/', 'test/', 'tool/', 'example/'];
  config.format.directories = ['lib/', 'test/', 'tool/', 'example/'];

  await dev(args);
}
