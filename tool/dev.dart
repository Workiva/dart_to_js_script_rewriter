library dart_to_js_script_rewriter.tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  List<String> directories = ['example/', 'lib/', 'test/', 'tool/'];

  config.analyze.entryPoints = directories;
  config.analyze.strong = true;
  config.format.directories = directories;
  config.test
    ..platforms = ['vm']
    ..pubServe = true
    ..unitTests = ['test/unit_test.dart']
    ..integrationTests = ['test/integration_test.dart'];

  config.coverage.pubServe = true;

  await dev(args);
}
