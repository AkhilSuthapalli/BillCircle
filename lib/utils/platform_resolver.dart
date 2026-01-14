
import 'package:billcircle/utils/web_app_solver.dart';
import 'package:flutter/foundation.dart';
import 'android_app_solver.dart';

abstract class PlatformResolver {
  String? getInitialCircleToken();
  String? getAction();
  void clearUrl();
}

final PlatformResolver resolver = kIsWeb ? WebAppSolver() : AndroidAppSolver();
