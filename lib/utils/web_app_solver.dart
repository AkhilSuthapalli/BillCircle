import 'dart:js_interop';
import 'platform_resolver.dart';

@JS('window.location.href')
external String get _href;

@JS('location.assign')
external void _assign(JSString url);

void resetToHomeAndReload() {
  _assign('/'.toJS);
}

class WebAppSolver implements PlatformResolver {
  @override
  String? getInitialCircleToken() {
    final uri = Uri.parse(_href);
    return uri.queryParameters['circle'];
  }
  @override
  String? getAction() {
    final uri = Uri.parse(_href);
    return uri.queryParameters['action'];
  }

  @override
  void clearUrl() {
    resetToHomeAndReload();
  }
}
