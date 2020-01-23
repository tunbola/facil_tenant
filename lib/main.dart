import 'package:facil_tenant/singleton/locator.dart';
import 'package:facil_tenant/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:overlay_support/overlay_support.dart';

import 'styles/theme.dart';

import 'pages/splash_screen_page.dart';
import "package:facil_tenant/routes/router.dart" as router;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        // showPerformanceOverlay: true,
        // debugShowMaterialGrid: true,
        title: 'Facil App',
        theme: shedAppThemeData(),
        home: const SplashPage(),
        onGenerateRoute: router.generateRoute,
        navigatorKey: locator<NavigationService>().navigatorKey,
      ),
    );
  }
}
