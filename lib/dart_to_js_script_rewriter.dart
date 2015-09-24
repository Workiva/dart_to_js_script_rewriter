library dart_to_js_script_rewriter;

import 'dart:async' show Future;

import 'package:barback/barback.dart'
    show Asset, Transform, Transformer, BarbackSettings, BarbackMode;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;

/// Finds script tags with type equals `application/dart` and rewrites them to
/// point to the JS version. This eliminates a 404 get on the .dart file and
/// speeds up initial loads. Win!
class DartToJsScriptRewriter extends Transformer {
  bool releaseMode = false;

  DartToJsScriptRewriter.asPlugin(BarbackSettings settings)
      : releaseMode = (settings.mode == BarbackMode.RELEASE);

  String get allowedExtensions => ".html";

  Future apply(Transform transform) {
    if (!releaseMode) return new Future.value(true);

    var id = transform.primaryInput.id;
    return transform.primaryInput.readAsString().then((content) {
      var document = parse(content);

      removeDartDotJsTags(document);
      rewriteDartTags(document);

      return document;
    }).then((document) {
      return transform.addOutput(new Asset.fromString(id, document.outerHtml));
    });
  }

  void removeDartDotJsTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['src'] != null &&
          tag.attributes['src'].endsWith('browser/dart.js');
    }).forEach((tag) => tag.remove());
  }

  void rewriteDartTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['type'] == 'application/dart' &&
          tag.attributes['src'] != null;
    }).forEach((tag) {
      var src = tag.attributes['src'];
      tag.attributes['src'] = '${src}.js';
      tag.attributes.remove('type');
    });
  }
}
