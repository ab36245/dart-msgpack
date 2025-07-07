// This hack uses the dart-specific (as opposed to flutter-specific)
// way of telling if we are running on javascript.
// 
// It's important to know this because some 64-bit operations
// don't work on a javascript platform and have to be worked
// around.
//
// See comments in other files for where this is necessary.
//
// For more information also see the dart-specifc comment in
//
// https://stackoverflow.com/questions/57937280/how-can-i-detect-if-my-flutter-app-is-running-in-the-web
// 
// which references
//
// https://api.flutter.dev/flutter/foundation/kIsWeb-constant.html

/// `isJS` identifies whether the target platform is using Javascript.
/// 
/// The value defaults to the standard Dart/Flutter way of detecting Javascript
/// (see `_isJS` below).
/// 
/// The `isJS` can be overridden on non-Javascript platforms by defining the
/// compilation-time environment variable `IS_JS`. See the `runTests` scripts
/// in the package root folder for an example. This is only useful for testing!
/// Setting `isJS` to true on non-JS platforms will just slow things down and
/// setting `isJS` to false on JS platforms will cause both encoding and
/// decoding failures.
/// 
const isJS = bool.fromEnvironment('IS_JS', defaultValue: _isJS);

const _isJS = bool.fromEnvironment('dart.library.js_util');
