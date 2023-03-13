part of 'package:cube_system/features/timetable_page/features/lesson_card/ui/lesson_card.dart';

class LessonCardTimeLeft extends ConsumerWidget {
  const LessonCardTimeLeft({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActiveLessons =
        ref.watch(_lessonInLessonCard) == ref.watch(lessonCardActiveLesson);

    if (!isActiveLessons) return const SizedBox();

    return Consumer(
      builder: (context, ref, _) {
        final timeLeft = ref.watch(lessonCardTimeLeft);

        if (timeLeft == null) {
          return const Text(
            '00:00:00',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          );
        }

        final timeLeftBuffer = StringBuffer();

        if (timeLeft.hour > 0) {
          timeLeftBuffer.write("${timeLeft.hour}");
        }

        if (timeLeft.hour > 0) timeLeftBuffer.write(":");

        timeLeftBuffer.write("${timeLeft.minute}".padLeft(2, '0'));

        timeLeftBuffer.write(":");

        timeLeftBuffer.write("${timeLeft.second}".padLeft(2, '0'));

        if (timeLeft.minute == 0 && timeLeft.hour == 0) {
          timeLeftBuffer.write(
            ":${"${timeLeft.millisecond}".padLeft(2, '0').substring(0, 2)}",
          );
        }

        return Text(
          timeLeftBuffer.toString(),
          style: context.textStyles.chipLabel
              .copyWith(color: context.colors.white),
        );
      },
    );
  }
}
