// This hack is the dart-specific (as opposed to flutter-specific)
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

// const kIsWeb = bool.fromEnvironment('dart.library.js_util');
const kIsWeb = true;
