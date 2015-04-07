library dart_to_js_script_rewriter_test;

import 'package:barback/barback.dart' show BarbackMode, BarbackSettings;
import 'package:dart_to_js_script_rewriter/dart_to_js_script_rewriter.dart';
import 'package:html/dom.dart' show Document;
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('dart_to_js_script_rewriter', () {
    test('removeDartDotJsTags', () {
      DartToJsScriptRewriter transformer = _transformer();
      Document document = new Document.html(_html);
      transformer.removeDartDotJsTags(document);
      var dartJsScripts = document.querySelectorAll('script').where((tag) {
        Map attrs = tag.attributes;
        return attrs['src'] != null && attrs['src'].endsWith('/dart.js');
      });
      expect(dartJsScripts, isEmpty);
    });

    test('rewriteDartTags', () {
      DartToJsScriptRewriter transformer = _transformer();
      Document document = new Document.html(_html);
      transformer.rewriteDartTags(document);
      var dartJsScripts = document.querySelectorAll('script').where((tag) {
        Map attrs = tag.attributes;
        return attrs['type'] == 'application/dart' && attrs['src'] != null;
      });
      expect(dartJsScripts, isEmpty);
    });
  });
}

DartToJsScriptRewriter _transformer() {
  return new DartToJsScriptRewriter.asPlugin(
      new BarbackSettings({}, BarbackMode.RELEASE));
}

final String _html = """
<!DOCTYPE html>

<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Test</title>

    <script async type="application/dart" src="test.dart"></script>
    <script async src="packages/browser/dart.js"></script>

    <link rel="stylesheet" href="test.css">
  </head>
  <body>
    <h1>Test</h1>

    <p>Hello world from Dart!</p>

    <div id="sample_container_id">
      <p id="sample_text_id">Click me!</p>
    </div>

  </body>
</html>
""";
