# dart_to_js_script_rewriter

A pub transformer that rewrites Dart script tags to
JavaScript script tags, eliminating
404s and speeding up initial loads.
Useful when building for deployment.

## Configuring

Add the transformer to your pubspec.yaml:

    transformers:
    - dart_to_js_script_rewriter
    
(Assuming you already added this package to your pubspec.yaml file.)

## How it works

**When run in "release" mode**, this transformer does two things:

* Removes script tags that point to `dart.js`.
* Rewrites a Dart script tag to a JavaScript script tag.

For example, this code:

    <script async type="application/dart" src="test.dart"></script>
    <script async src="packages/browser/dart.js"></script>

is turned into this code:

    <script async src="test.dart.js"></script>
    
## Pub, modes, and this transformer

**This transformer only runs when pub is running in release mode.**

This transformer only makes sense when you want to build your app for a
production deployment. You probably do not want to run this transformer
during the normal develop/reload cycles.

Pub can run in different _modes_, which have different semantics. The
_debug mode_, for example, can disable minification. The _release mode_
can turn on optimizations.

By default, `pub serve` runs in _debug_ mode. By default, `pub build`
runs in _release_mode.

See the [pub docs][pubdocs] for more on modes.

## Reporting issues

Please use the [issue tracker][issues].

[issues]: https://github.com/sethladd/dart_to_js_script_rewriter/issues
[pubdocs]: https://www.dartlang.org/tools/pub/
