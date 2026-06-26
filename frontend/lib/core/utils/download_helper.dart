/// Conditional export: uses web implementation when dart:html is available,
/// otherwise falls back to mobile/desktop stub.
export 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart';
