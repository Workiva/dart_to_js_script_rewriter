# dart_to_js_script_rewriter

<a href="https://pub.dartlang.org/packages/dart_to_js_script_rewriter"><img src="https://img.shields.io/pub/v/dart_to_js_script_rewriter.svg" alt="Pub" /></a>
<a href="https://travis-ci.org/Workiva/dart_to_js_script_rewriter"><img src="https://travis-ci.org/Workiva/dart_to_js_script_rewriter.svg?branch=travis-ci" alt="Build Status" /></a>
<a href="http://codecov.io/github/Workiva/dart_to_js_script_rewriter?branch=master"><img src="http://codecov.io/github/Workiva/dart_to_js_script_rewriter/coverage.svg?branch=master" alt="codecov.io" /></a>


A pub transformer that rewrites Dart script tags to
JavaScript script tags, eliminating
404s and speeding up initial loads.
Useful when building for deployment.

## Why? Load your app quicker!

A traditional Dart application is deployed with HTML that looks something
like this:

    <script async type="application/dart" src="test.dart"></script>
    <script async src="packages/browser/dart.js"></script>

This is a performance problem for initial startup, because:

* Some browsers will attempt to download test.dart, but that file is not
  deployed. This causes unnecessary server strain and noisy 404s.
* The browser needs to run dart.js to replace a script tag in the DOM,
  so that the actual JavaScript version of the app can be downloaded. This is
  an unnecessary delay, since today no production browser includes Dart VM
  and thus only the JavaScript version is required.

With this transformer, you can address the above issues, speed up the load
time of your apps, and make happier users.

## Configuring

Add the transformer to your pubspec.yaml:

    transformers:
    - dart_to_js_script_rewriter

(Assuming you already added this package to your pubspec.yaml file.)

## How it works

**When run in "release" mode**, this transformer does two things:

* Removes script tags that point to `browser/dart.js`.
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
runs in _release_ mode.

See the [pub docs][pubdocs] for more on modes.

## Reporting issues

Please use the [issue tracker][issues].

[issues]: https://github.com/Workiva/dart_to_js_script_rewriter/issues
[pubdocs]: https://www.dartlang.org/tools/pub/

Thanks to Seth Ladd, <sethladd@gmail.com>, for creating the original version of this [library](https://github.com/sethladd/dart_to_js_script_rewriter).
