import 'dart:collection';

import 'package:cube_system/features/date_time_contol/managers/date_time_manager.dart';
import 'package:cube_system/features/timetable_page/managers/timetable_day_event_manager.dart';
import 'package:cube_system/models/timetable/timetable_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cube_system/core/api/cube_api.dart';
import 'package:cube_system/gen/api/cube_api.swagger.dart';
import 'package:cube_system/models/lesson/lesson.dart';
import 'package:cube_system/features/date_time_contol/state_holders/current_date_time_state_holders.dart';
import 'package:cube_system/features/timetable_page/state_holders/lessons/current_lesson.dart';
import 'package:cube_system/features/timetable_page/state_holders/lessons/last_lesson.dart';
import 'package:cube_system/features/timetable_page/state_holders/lessons/next_lesson.dart';
import 'package:cube_system/features/timetable_page/state_holders/selected_date.dart';
import 'package:cube_system/features/timetable_page/state_holders/timetable_page_events.dart';
import 'package:cube_system/features/timetable_page/state_holders/timetable_page_lessons.dart';
import 'package:cube_system/features/timetable_page/managers/lesson_convertor.dart';
import 'package:intl/intl.dart';

import 'package:cube_system/features/timetable_page/state_holders/selected_timetable.dart';

final timetableLessonsManager = Provider<TimetableLessonsManager>((ref) {
  return TimetableLessonsManager(
    api: ref.watch(cubeApi),
    lessonConvertor: ref.watch(lessonConvertor),
    eventManager: ref.watch(timetableDayEventManager),
    dateTimeManager: ref.watch(dateTimeManager),
    selectedTimetable: ref.watch(selectedTimetableStateHolder.notifier),
    timetableLessons: ref.watch(timetablePageLessons.notifier),
    events: ref.watch(timetablePageEvents.notifier),
    currentDateTime: ref.watch(currentDateTimeQuick.notifier),
    selectedDate: ref.watch(selectedDate.notifier),
    currentLesson: ref.watch(currentLessonStateHolder.notifier),
    nextLesson: ref.watch(nextLessonStateHolder.notifier),
    lastLesson: ref.watch(lastLessonStateHolder.notifier),
  );
});

class TimetableLessonsManager {
  final CubeApi api;

  final LessonConvertor lessonConvertor;
  final TimetableDayEventManager eventManager;
  final DateTimeManager dateTimeManager;

  final SelectedTimetableNotifier selectedTimetable;
  final TimetablePageLessonsNotifier timetableLessons;
  final TimetablePageEventsNotifier events;
  final StateController<DateTime> currentDateTime;
  final StateController<DateTime> selectedDate;
  final StateController<Lesson?> currentLesson;
  final StateController<Lesson?> nextLesson;
  final StateController<Lesson?> lastLesson;

  TimetableLessonsManager({
    required this.api,
    required this.lessonConvertor,
    required this.eventManager,
    required this.dateTimeManager,
    required this.selectedTimetable,
    required this.timetableLessons,
    required this.events,
    required this.currentDateTime,
    required this.selectedDate,
    required this.currentLesson,
    required this.nextLesson,
    required this.lastLesson,
  });

  void clear() {
    timetableLessons.change(SplayTreeMap());
    events.change(SplayTreeMap());
  }

  Future<List<AppApiEntitiesTimetableLessonSchemasLesson>> _getLessons({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final timetable = selectedTimetable.state;

    if (timetable == null) return [];

    final format = DateFormat('yyyy-MM-dd');

    final startDateStr = format.format(startDate);
    final endDateStr = format.format(endDate);

    final lessonResponse = await api.apiTimetableLessonsViewerGet(
      group: timetable.type == TimetableType.group ? [timetable.id] : null,
      teacher: timetable.type == TimetableType.teacher ? [timetable.id] : null,
      place: timetable.type == TimetableType.place ? [timetable.id] : null,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    if (lessonResponse.statusCode >= 400 && lessonResponse.statusCode < 500) {
      eventManager.setUnavailableAfterLoading();
      throw Exception('Unavailable Timetable');
    }

    return lessonResponse.body!.data;
  }

  void _setLessons(List<AppApiEntitiesTimetableLessonSchemasLesson> lessons) {
    TimetableLessons timetableMap =
        SplayTreeMap.of(timetableLessons.state.cast());

    for (final lesson in lessons) {
      timetableMap[lesson.date] = [];
    }

    // for (int i = 0; i < lessons.length; i++) {
    //   if (lessons[i].date.day == DateTime.now().day) {
    //     lessons.insert(
    //       i + 1,
    //       lessons[i].copyWith(
    //         place: lessons[i].place?.copyWith(
    //               name: 'fwefweof',
    //             ),
    //       ),
    //     );
    //     break;
    //   }
    // }

    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      int emptyLessonsBefore = 0;

      final equalPrevious = i > 0 &&
          lessons[i - 1].number == lesson.number &&
          lessons[i - 1].date == lesson.date;
      final equalNext = i < lessons.length - 1 &&
          lessons[i + 1].number == lesson.number &&
          lessons[i + 1].date == lesson.date;

      final isCollision = equalPrevious || equalNext;

      if (i > 0 && lessons[i - 1].date == lesson.date && !isCollision) {
        emptyLessonsBefore = lesson.number - lessons[i - 1].number - 1;
      }

      final l = lessonConvertor.lessonByLessonFullNamesInDb(
        lesson: lesson,
        emptyLessonsBefore: emptyLessonsBefore,
        isCollision: isCollision,
      );

      timetableMap[lesson.date]!.add(l);
    }

    timetableLessons.change(timetableMap);
  }

  Future<void> updateCurrentTimetable() async {
    await Future(() {});

    final bounds = dateTimeManager.getDateTimeBounds(selectedDate.state);

    final startDate = bounds.start;
    final endDate = bounds.end;

    if (selectedTimetable.state == null) {
      eventManager.setNotSelectedEvents(
        startDate: startDate,
        endDate: endDate,
      );
      return;
    }

    eventManager.setLoadingEvents(startDate: startDate, endDate: endDate);

    try {
      await Future.delayed(const Duration(milliseconds: 350));

      final lessons = await _getLessons(startDate: startDate, endDate: endDate);

      for (int day = 0; day <= endDate.difference(startDate).inDays; day++) {
        final date = startDate.add(Duration(days: day));
        timetableLessons.state[date] ??= [];
      }

      _setLessons(lessons);
      eventManager.setLessonsAfterLoading();
    } catch (e) {
      eventManager.setErrorsAfterLoading();
    }

    findLastCurrentNextLesson();
  }

  void findLastCurrentNextLesson() async {
    await Future(() {});
    final currentDate = currentDateTime.state.add(const Duration(seconds: 1));

    Lesson? lessonCurrent;
    Lesson? lessonLast;

    final dates = timetableLessons.state.keys;

    for (final date in dates) {
      final lessons = timetableLessons.state[date]!;

      for (final lesson in lessons) {
        if (lesson.isEvent) continue;

        if (currentDate.isAfter(lesson.dateTimings.startDateTime) &&
            currentDate.isBefore(lesson.dateTimings.endDateTime)) {
          lessonCurrent = lesson;
        } else if (currentDate.isBefore(lesson.dateTimings.startDateTime)) {
          nextLesson.state = lesson;
          currentLesson.state = lessonCurrent;
          lastLesson.state = lessonLast;
          return;
        }

        lessonLast = lesson;
      }
    }
  }

  bool isEquelLessons(Lesson? one, Lesson? two) {
    return one?.dateTimings.startDateTime == two?.dateTimings.startDateTime &&
        one?.number == two?.number;
  }
}
