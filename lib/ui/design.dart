import 'package:flutter/material.dart';

import '../models/activity.dart';

const ink = Color(0xFF262735);
const muted = Color(0xFF858592);
const violet = Color(0xFF7560D6);
const canvas = Colors.white;
const line = Color(0xFFEEEEF3);
const lavender = Color(0xFFF0EDFC);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: violet, surface: Colors.white),
  scaffoldBackgroundColor: canvas,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -1,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -.6,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    bodyLarge: TextStyle(fontSize: 15, height: 1.7, color: ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: ink),
    bodySmall: TextStyle(fontSize: 12, height: 1.5, color: muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: canvas,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    elevation: 0,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: violet,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8F8FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(18),
  ),
  dividerTheme: const DividerThemeData(color: line, thickness: 1),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

extension ActivityPresentation on ActivityType {
  String get label => switch (this) {
    ActivityType.assignment => '과제',
    ActivityType.lecture => '강의',
    ActivityType.announcement => '공지',
  };
  IconData get icon => switch (this) {
    ActivityType.assignment => Icons.assignment_outlined,
    ActivityType.lecture => Icons.play_circle_outline_rounded,
    ActivityType.announcement => Icons.campaign_outlined,
  };
}

String dateLabel(DateTime date) => '${date.month}월 ${date.day}일';
String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String weekday(DateTime date) =>
    ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
String videoDurationLabel(Duration? duration) {
  if (duration == null) return '길이 미제공';
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return [
    if (hours > 0) '$hours시간',
    if (minutes > 0) '$minutes분',
    if (seconds > 0 || duration.inSeconds == 0) '$seconds초',
  ].join(' ');
}

String reminderLabel(int minutes) => switch (minutes) {
  60 => '1시간 전',
  180 => '3시간 전',
  1440 => '하루 전',
  2880 => '이틀 전',
  _ => '$minutes분 전',
};
String dueLabel(Activity a, DateTime today) {
  if (a.dueAt == null) return '기한 없음';
  final due = a.dueAt!;
  final difference = dayOnly(due).difference(dayOnly(today)).inDays;
  final day = switch (difference) {
    0 => '오늘',
    1 => '내일',
    -1 => '어제',
    _ => '${due.month}.${due.day}',
  };
  return '$day ${timeLabel(due)}';
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.heightFactor});
  final Widget child;
  final double? heightFactor;
  @override
  Widget build(BuildContext context) => Align(
    heightFactor: heightFactor,
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: child,
    ),
  );
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.today,
    required this.onTap,
  });
  final Activity activity;
  final DateTime today;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final a = activity;
    final overdue = a.dueAt != null && a.dueAt!.isBefore(today) && !a.completed;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 37,
                margin: const EdgeInsets.only(right: 13, top: 4),
                decoration: BoxDecoration(
                  color: a.completed ? line : Color(a.course.colorValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: a.completed ? muted : ink,
                        decoration: a.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 3,
                      children: [
                        Text(
                          '${a.course.name} · ${a.type.label}',
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                        if (a.type == ActivityType.lecture &&
                            a.videoDuration != null)
                          Text(
                            videoDurationLabel(a.videoDuration),
                            style: const TextStyle(fontSize: 11, color: muted),
                          ),
                        if (a.dueAt != null)
                          Text(
                            dueLabel(a, today),
                            style: TextStyle(
                              fontSize: 11,
                              color: overdue ? const Color(0xFFD56363) : muted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (a.completed)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.check_rounded, size: 18, color: muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Text(title, style: const TextStyle(fontSize: 13, color: muted)),
    ),
  );
}
