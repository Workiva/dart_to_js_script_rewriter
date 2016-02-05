@TestOn('vm')
library dart_to_js_script_rewriter.test.integration_test;

import 'package:test/test.dart';
import 'package:grinder/grinder.dart';
import 'dart:io';

void main() {
  test('transformer is activated in pub build release', () async {
    Pub.build(mode: 'release', directories: ['example']);
    final testHtml = new File('build/example/index.html');
    final content = await testHtml.readAsString();

    File expectedHtml = new File('test/expected.html');
    expect(content, await expectedHtml.readAsString());
  });
}
