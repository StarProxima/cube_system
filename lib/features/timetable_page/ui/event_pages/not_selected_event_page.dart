import 'package:flutter/cupertino.dart';

import 'package:cube_system/gen/assets/assets.gen.dart';
import 'package:cube_system/ui/widgets/event_pages/app_event_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

class NotSelectedEventPage extends ConsumerWidget {
  const NotSelectedEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppEventPage(
      picture: Assets.brooklyn.pageNotFound1.svg(),
      title: 'Расписание не выбрано',
      buttonText: 'Выбрать',
      onTap: () {
        context.go('/timetable');
      },
    );
  }
}
