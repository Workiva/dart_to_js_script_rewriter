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
  bool cacheBust = false;
  String cacheBustKey = "dartcachebust";

  DartToJsScriptRewriter.asPlugin(BarbackSettings settings){
    releaseMode = (settings.mode == BarbackMode.RELEASE);
    cacheBust = (settings.configuration.containsKey("bust_cache") && settings.configuration["bust_cache"] == true);
    if(settings.configuration.containsKey("bust_cache_key")){
      cacheBustKey = settings.configuration["bust_cache_key"];
    }
  }

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
      var query = "";
      var cacheBustString = "${new DateTime.now().millisecondsSinceEpoch.toString()}";
      if(src.contains("?")){
        var spliturl = src.split("?");
        src = spliturl[0];
        query = spliturl[1];
      }

      if(query.length > 0){
        src = '${src}.js?${query}';
        if(cacheBust){
          src = "${src}&${cacheBustKey}=${cacheBustString}";
        }
      }else{
        src = '${src}.js';
        if(cacheBust){
          src = "${src}?${cacheBustKey}=${cacheBustString}";
        }
      }

      tag.attributes['src'] = src;
      tag.attributes.remove('type');
    });
  }
}
