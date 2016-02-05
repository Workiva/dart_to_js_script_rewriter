@TestOn('vm')
library dart_to_js_script_rewriter.test.unit_test;

import 'dart:io';

import 'package:barback/barback.dart';
import 'package:html/dom.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:dart_to_js_script_rewriter/dart_to_js_script_rewriter.dart';

import 'transformer_mocks.dart';

main() {
  final transformer = new DartToJsScriptRewriter.asPlugin(
      new BarbackSettings({}, BarbackMode.RELEASE));

  group('apply()', () {
    test('when run in release mode', () async {
      AssetId fakeInputFileAssetId =
          new AssetId('testid', 'test/test_data/test_file.html');

      MockAsset inputFile;
      MockTransform mockTransform;

      String transformedFile;

      inputFile = new MockAsset();
      mockTransform = new MockTransform();

      when(inputFile.id).thenReturn(fakeInputFileAssetId);
      when(inputFile.readAsString()).thenReturn(
          new File.fromUri(Uri.parse('test/test_data/test_file.html'))
              .readAsString());

      when(mockTransform.primaryInput).thenReturn(inputFile);
      when(mockTransform.readInputAsString(fakeInputFileAssetId))
          .thenAnswer((_) {
        return new File.fromUri(Uri.parse('test/test_data/test_file.html'))
            .readAsString();
      });

      await transformer.apply(mockTransform);

      Asset fileAsset =
          verify(mockTransform.addOutput(captureAny)).captured.first;

      transformedFile = await fileAsset.readAsString();
      expect(
          transformedFile.contains(
              '<script async type="application/dart" src="test.dart"></script>'),
          isFalse);
      expect(
          transformedFile.contains(
              '<script async src="packages/browser/dart.js"></script>'),
          isFalse);
      expect(
          transformedFile
              .contains('<script async="" src="test.dart.js"></script>'),
          isTrue);
    });
  });

  group('rewriteDartScriptTag', () {
    testScriptShouldBeRewritten(String script, bool shouldRewrite) {
      final document = documentFromScript(script);
      final oldScript = document.querySelector('script');
      expect(transformer.scriptShouldBeRewritten(oldScript), shouldRewrite);

      transformer.rewriteDartScriptTag(document);

      final scripts = document.querySelectorAll('script');
      if (shouldRewrite) {
        expect(scripts.first.attributes["src"], 'main.dart.js');
      } else {
        expect(scripts.first.attributes["src"], oldScript.attributes["src"]);
      }
    }

    test('do rewrite script with src specified and of type application/dart',
        () {
      final script =
          '<script src="main.dart" type="application/dart"></script>';
      testScriptShouldBeRewritten(script, true);
    });

    test('don\'t rewrite inline scripts', () {
      final script = '<script type="application/dart"></script>';
      testScriptShouldBeRewritten(script, false);
    });

    test('don\'t rewrite script of type type="text/javascript"', () {
      final script = '<script type="text/javascript"></script>';
      testScriptShouldBeRewritten(script, false);
    });

    test('don\'t rewrite script of without type', () {
      final script = '<script src="main.js"></script>';
      testScriptShouldBeRewritten(script, false);
    });
  });

  group('removeBrowserPackageScript', () {
    testScriptShouldBeRemoved(String script, bool shouldRemove) {
      final document = documentFromScript(script);
      final oldScript = document.querySelector('script');
      expect(transformer.scriptShouldBeRemoved(oldScript), shouldRemove);

      transformer.removeBrowserPackageScript(document);
      final dartJsScripts = document.querySelectorAll('script');
      if (shouldRemove) {
        expect(dartJsScripts, isEmpty);
      } else {
        expect(dartJsScripts, isNotEmpty);
      }
    }

    test('do rewrite scripts where src="browser/dart.js"', () {
      final script = '<script src="browser/dart.js"></script>';
      testScriptShouldBeRemoved(script, true);
    });

    test('don\'t remove other scripts where src ends with dart.js', () {
      final script = '<script src="dart.js"></script>';
      testScriptShouldBeRemoved(script, false);
    });
  });

  group('isPrimary', () {
    test('do touch html files in web', () {
      AssetId assetId = new AssetId('my_package', 'web/index.html');
      expect(transformer.isPrimary(assetId), isTrue);
    });

    test('do touch html files in example', () {
      AssetId assetId = new AssetId('my_package', 'example/index.html');
      expect(transformer.isPrimary(assetId), isTrue);
    });

    test('do not touch html files in lib', () {
      AssetId assetId = new AssetId('my_package', 'lib/app.component.html');
      expect(transformer.isPrimary(assetId), isFalse);
    });

    test('don\'t touch html in DEBUG mode', () {
      final settings = new BarbackSettings({}, BarbackMode.DEBUG);
      final transformer = new DartToJsScriptRewriter.asPlugin(settings);
      AssetId assetId = new AssetId('my_package', 'web/index.html');
      expect(transformer.isPrimary(assetId), isFalse);
    });

    test('don\'t touch dart files', () {
      AssetId assetId = new AssetId('my_package', 'web/main.dart');
      expect(transformer.isPrimary(assetId), isFalse);
    });
  });
}

Document documentFromScript(String script) => new Document.html('''
<!DOCTYPE html>

<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Test</title>
    $script
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
''');
