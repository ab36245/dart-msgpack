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

/// `isJS` should only be defined on true JavaScript platforms (i.e. browser)
const isJS = bool.fromEnvironment('dart.library.js_util');

/// `asJS` can be set on non-Javascript platforms by defining the compilation-
/// time environment variable AS_JS.
/// See the `runTests` scripts in the package root folder for an example.
const asJS = bool.fromEnvironment('AS_JS', defaultValue: isJS);
