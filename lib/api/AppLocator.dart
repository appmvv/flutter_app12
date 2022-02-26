import 'package:get_it/get_it.dart';

import 'GlpiApi.dart';

class AppLocator {

  static Future<void> init() {

    final getIt = GetIt.I;

    getIt.registerSingleton<GlpiApi>(GlpiApi());

    return GetIt.I.allReady();

  }

  static Future<void> dispose() => GetIt.I.reset();
}