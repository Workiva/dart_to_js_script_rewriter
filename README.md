# dart_to_js_script_rewriter

A pub transformer that Rewrites Dart script tags to
JavaScript script tags, eliminating
404s and speeding up initial loads.
Use when building for deployment.

## Configuring

Add the transformer to your pubspec.yaml:

    transformers:
    - dart_to_js_script_rewriter
    
(Assuming you already added this package to your pubspec.yaml file.)

## How it works

This transformer does two things:

* Removes script tags that point to `dart.js`.
* Rewrites a Dart script tag to a JavaScript script tag.

For example, this code:

    <script async type="application/dart" src="test.dart"></script>
    <script async src="packages/browser/dart.js"></script>

is turned into this code:

    <script async src="test.dart.js"></script>

## Reporting issues

Please use the [issue tracker][issues].

[issues]: https://github.com/sethladd/dart_to_js_script_rewriter/issues
