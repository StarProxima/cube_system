import 'package:cube_system/features/timetable_page/managers/timetable_page_manager.dart';
import 'package:cube_system/features/date_time_contol/state_holders/current_date_time_state_holders.dart';
import 'package:cube_system/features/timetable_page/ui/widgets/timetable_page_day.dart';
import 'package:cube_system/features/timetable_page/ui/widgets/timetable_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cube_system/features/date_time_contol/managers/date_time_manager.dart';

import 'package:cube_system/features/timetable_page/features/week_timeline/ui/week_timeline.dart';
import 'package:cube_system/features/timetable_page/state_holders/selected_date.dart';

import 'package:cube_system/features/timetable_page/state_holders/current_picked_date_in_page_view.dart';

import 'package:cube_system/features/timetable_page/features/lesson_card/providers/last_current_next_lesson_listener.dart';

class TimetablePage extends ConsumerWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeManager = ref.watch(dateTimeManager);
    timeManager.setTimers();

    final manager = ref.read(timetablePageManager);
    manager.updateCurrentTimetable();

    ref.listen(lastCurrentNextLessonListener, (_, __) {
      manager.findLastCurrentNextLesson();
    });

    return const _TimetablePage();
  }
}

class _TimetablePage extends ConsumerStatefulWidget {
  const _TimetablePage();

  @override
  ConsumerState<_TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<_TimetablePage> {
  static const _initialPage = 1000;

  late final pageController = PageController(
    initialPage: _initialPage -
        ref.read(currentDate).difference(ref.read(selectedDate)).inDays,
  );

  // @override
  // void initState() {
  //   print('initstate - $hashCode');
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final manager = ref.read(timetablePageManager);

    final date = ref.watch(currentDate);

    // Обрабатывается изменение выбранной даты из WeekTimeline.
    ref.listen(selectedDate, (prev, next) {
      if (ref.read(currentPickedDateInPageView) == next) return;
      final targetPage = _initialPage - date.difference(next).inDays;

      pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    DateTime getDateByPageIndex(int index) =>
        date.add(Duration(days: index - _initialPage));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(),
              child: TimetablePageHeader(),
            ),
            const WeekTimeline(),
            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: _initialPage * 2,
                onPageChanged: (index) =>
                    manager.handlePageViewChange(getDateByPageIndex(index)),
                itemBuilder: (context, index) {
                  return TimetablePageDay(
                    date: getDateByPageIndex(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
