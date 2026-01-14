import 'platform_resolver.dart';

class AndroidAppSolver implements PlatformResolver {
  @override
  String? getInitialCircleToken() {
    // Deep links will be handled here later
    return null;
  }

  @override
  String? getAction() {
    // Deep links will be handled here later
    return null;
  }

  @override
  void clearUrl() {
    // TODO: implement clearUrl
    throw UnimplementedError();
  }
}

