// Cross-platform accessor for the browser's current URL.
//
// `dart:html` only exists on the web compile target, so importing it
// unconditionally breaks compilation on Windows/Linux/macOS/Android/iOS.
// This conditional export picks the real implementation on web and a
// no-op stub everywhere else.
export 'web_location_stub.dart' if (dart.library.html) 'web_location_web.dart';
