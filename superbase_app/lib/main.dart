import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:superbase_app/env.dart';

import 'app_config.dart';
import 'commons/routes/route.dart';
import 'commons/widgets/app_life_cycle_overlay.dart';
import 'commons/widgets/flavor_banner.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env().getRemoteConfig();
  await initConfig();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      routingCallback: (routing) {
        if (routing != null) {
          RouteService.to.updateRoute(routing.current);
        }
      },
      smartManagement: SmartManagement.full,
      onGenerateTitle: (context) => 'SuperBase App',
      debugShowCheckedModeBanner: false,
      title: Env().appName,
      enableLog: kDebugMode,
      popGesture: !kIsWeb,
      defaultTransition: kIsWeb ? Transition.fadeIn : Transition.cupertino,
      getPages: getPages,
      initialRoute: Routes.splash.p,
      locale: Locale('en'),
      builder: (_, c) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => FlavorBanner(
                enable: !kReleaseMode || Env().flavor == Flavor.develop,
                child: c!,
              ),
            ),
            OverlayEntry(builder: (context) => AppLifecycleOverlay()),
          ],
        );
      },
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
