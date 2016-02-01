@TestOn('vm')
library dart_to_js_script_rewriter.test.dart_to_js_script_rewriter_test;

import 'dart:io';

import 'package:barback/barback.dart'
    show Asset, AssetId, BarbackMode, BarbackSettings;
import 'package:html/dom.dart' show Document;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:dart_to_js_script_rewriter/dart_to_js_script_rewriter.dart';
import 'transformer_mocks.dart';

void main() {
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

    test('allowedExtensions', () {
      expect(
          new DartToJsScriptRewriter.asPlugin(
                  new BarbackSettings(const {}, BarbackMode.RELEASE))
              .allowedExtensions,
          equals('.html'));
    });

    group('apply()', () {
      BarbackSettings configuration;
      final Matcher isHtmlFile =
          predicate((Asset asset) => asset.id.extension == '.html');
      DartToJsScriptRewriter transformer;

      test('when run in release mode', () async {
        configuration = new BarbackSettings(const {}, BarbackMode.RELEASE);
        transformer = new DartToJsScriptRewriter.asPlugin(configuration);
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
            verify(mockTransform.addOutput(captureThat(isHtmlFile)))
                .captured
                .first;

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

      test('when run in debug mode', () async {
        configuration = new BarbackSettings(const {}, BarbackMode.DEBUG);
        transformer = new DartToJsScriptRewriter.asPlugin(configuration);
        AssetId fakeInputFileAssetId =
            new AssetId('testid', 'test/test_data/test_file.html');

        MockAsset inputFile;
        MockTransform mockTransform;

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

        verifyNever(mockTransform.addOutput(any));
      });
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
    <script async type="application/dart" src="test.dart"></script>
    <script async src="packages/browser/dart.js"></script>
  </head>
</html>
""";
