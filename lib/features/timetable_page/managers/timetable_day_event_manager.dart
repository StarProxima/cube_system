import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cube_system/models/timetable_day/timetable_day_event.dart';

import 'package:cube_system/features/timetable_page/state_holders/timetable_page_events.dart';
import 'package:cube_system/features/timetable_page/state_holders/timetable_page_lessons.dart';

import 'package:cube_system/models/timetable_day/timetable_day_type.dart';

final timetableDayEventManager = Provider<TimetableDayEventManager>((ref) {
  return TimetableDayEventManager(
    timetable: ref.watch(timetablePageLessons.notifier),
    events: ref.watch(timetablePageEvents.notifier),
  );
});

class TimetableDayEventManager {
  final TimetablePageLessonsNotifier timetable;
  final TimetablePageEventsNotifier events;

  TimetableDayEventManager({
    required this.timetable,
    required this.events,
  });

  void setNotSelectedEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    SplayTreeMap<DateTime, TimetableDayEvent> eventMap = SplayTreeMap();

    for (int day = 0; day < endDate.difference(startDate).inDays; day++) {
      final date = startDate.add(Duration(days: day));
      eventMap[date] =
          TimetableDayEvent(type: TimetableDayEventType.notSelected);
    }

    events.change(eventMap);
  }

  static final _shouldLoadingEvents = [
    TimetableDayEventType.error,
    TimetableDayEventType.notSelected,
    TimetableDayEventType.unavailable,
  ];

  void setLoadingEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    SplayTreeMap<DateTime, TimetableDayEvent> eventMap =
        SplayTreeMap.of(events.state.cast());

    for (int day = 0; day < endDate.difference(startDate).inDays; day++) {
      final date = startDate.add(Duration(days: day));

      final shouldLoading = !eventMap.containsKey(date) ||
          _shouldLoadingEvents.contains(eventMap[date]?.type);

      if (shouldLoading) {
        eventMap[date] = TimetableDayEvent(type: TimetableDayEventType.loading);
      }
    }

    events.change(eventMap);
  }

  void setLessonsAfterLoading() {
    SplayTreeMap<DateTime, TimetableDayEvent> eventMap =
        SplayTreeMap.of(events.state.cast());
    final timetableMap = timetable.state;

    for (final entry in eventMap.entries) {
      eventMap[entry.key] = TimetableDayEvent(
        type: timetableMap[entry.key]?.isEmpty ?? true
            ? TimetableDayEventType.weekend
            : TimetableDayEventType.lessons,
      );
    }

    events.change(eventMap);
  }

  void setUnavailableAfterLoading() {
    SplayTreeMap<DateTime, TimetableDayEvent> eventMap =
        SplayTreeMap.of(events.state.cast());

    for (final MapEntry(key: date, value: event) in eventMap.entries) {
      if (event.type == TimetableDayEventType.loading) {
        eventMap[date] = TimetableDayEvent(
          type: TimetableDayEventType.unavailable,
        );
      }
    }

    events.change(eventMap);
  }

  void setErrorsAfterLoading() {
    SplayTreeMap<DateTime, TimetableDayEvent> eventMap =
        SplayTreeMap.of(events.state.cast());

    final timetableMap = timetable.state;

    for (final entry in eventMap.entries) {
      if (entry.value.type == TimetableDayEventType.loading) {
        final TimetableDayEventType type;
        final lessons = timetableMap[entry.key];
        if (lessons == null) {
          type = TimetableDayEventType.error;
        } else if (lessons.isEmpty) {
          type = TimetableDayEventType.weekend;
        } else {
          type = TimetableDayEventType.lessons;
        }
        eventMap[entry.key] = TimetableDayEvent(
          type: type,
        );
      }
    }

    events.change(eventMap);
  }
}
