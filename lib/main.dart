import 'package:app_runner/app_runner.dart';
import 'package:cube_system/ui/main_app.dart';
import 'package:cube_system/ui/widgets/app_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cube_system/core/hive_initializer.dart';

void main() async {
  final widgetConfiguration = WidgetConfiguration(
    child: AppBuilder<void>(
      preInitialize: (binding) async {
        await Future.wait([
          HiveInitializer.init(),
          Future.delayed(const Duration(milliseconds: 2000))
        ]);
      },
      builder: (context, snapshot, _) {
        final Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          child = const ProviderScope(child: MainApp());
        } else {
          child = const AppSplash();
        }

        return child;
      },
    ),
    onFlutterError: (errorDetails) {},
  );

  final ZoneConfiguration zoneConfiguration = ZoneConfiguration(
    onZoneError: (Object error, StackTrace stackTrace) {},
  );

  appRunner(
    RunnerConfiguration.guarded(
      widgetConfig: widgetConfiguration,
      zoneConfig: zoneConfiguration,
    ),
  );
}
