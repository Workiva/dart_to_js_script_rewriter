library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  List<String> directories = ['example/', 'lib/', 'test/', 'tool/'];

  config.analyze.entryPoints = directories;
  config.format.directories = directories;
  config.test
    ..platforms = ['vm']
    ..pubServe = true
    ..unitTests = ['test/'];

  config.coverage.pubServe = true;

  await dev(args);
}
