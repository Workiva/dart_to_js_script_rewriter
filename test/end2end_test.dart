import 'package:test/test.dart';
import 'package:grinder/grinder.dart';
import 'dart:io';

void main() {
  test('transformer is activated in pub build release', () async {
    Pub.build(mode: 'release', directories: ['example']);
    final testHtml = new File('build/example/test.html');
    final content = await testHtml.readAsString();

    File expectedHtml = new File('test/expected.html');
    expect(content, await expectedHtml.readAsString());
  });
}

// TODO maybe we should expect the html to be formatted?
final expectContent = '''
<!DOCTYPE html><html><head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Test</title>

    <script async="" src="test.dart.js"></script>

    <link rel="stylesheet" href="test.css">
  </head>
  <body>
    <h1>Test</h1>

    <p>Hello world from Dart!</p>

    <div id="sample_container_id">
      <p id="sample_text_id">Click me!</p>
    </div>



</body></html>
''';
