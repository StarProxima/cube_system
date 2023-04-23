import 'package:cube_system/features/settings/state_holders/app_settings_state_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cube_system/ui/ui_kit/radio_selector/app_radio_selector.dart';
import 'package:cube_system/ui/ui_kit/radio_selector/models/app_radio_selector_item.dart';

import 'package:cube_system/features/settings/models/app_lesson_colors_mode/app_lesson_colors_mode.dart';

import 'package:cube_system/features/settings/models/lesson_card_lesson_type_position/lesson_card_lesson_type_position.dart';

import 'package:cube_system/features/settings/models/lesson_card_recess_display_condition/lesson_card_recess_display_condition.dart';

part 'widgets/settings_page_lesson_colors.dart';
part 'widgets/settings_page_lesson_card_lesson_type_position.dart';
part 'widgets/settings_page_lesson_card_recess_display_condition.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SettingsPage();
  }
}

class _SettingsPage extends ConsumerStatefulWidget {
  const _SettingsPage();

  @override
  ConsumerState<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<_SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Настройки',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            _SettingsPageLessonColors(),
            SizedBox(height: 20),
            _SettingsPageLessonCardLessonTypePosition(),
            SizedBox(height: 20),
            _SettingsPageLessonCardRecessDisplayCondition(),
          ],
        ),
      ),
    );
  }
}
