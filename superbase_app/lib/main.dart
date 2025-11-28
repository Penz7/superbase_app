import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:superbase_app/controller/system_controller.dart';
import 'package:superbase_app/env.dart';

import 'app_config.dart';
import 'commons/routes/route.dart';
import 'commons/widgets/app_life_cycle_overlay.dart';
import 'commons/widgets/flavor_banner.dart';
import 'controller/init_controller.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env().getRemoteConfig();
  await initConfig();
  await initControllers();

  /// Router
  Get.put(RouteService());

  final systemController = Get.find<SystemController>();
  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      resumeCallBack: () async => systemController.onAppForeground(),
      suspendingCallBack: () async => systemController.onAppBackground(),
    ),
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      key: _navigatorKey,
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


class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
      case AppLifecycleState.inactive:
      default:
        break;
    }
  }
}
