import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../state/demo_store.dart';
import 'activity_detail.dart';
import 'design.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime month;
  late DateTime selected;
  @override
  void initState() {
    super.initState();
    selected = dayOnly(widget.store.referenceDate);
    month = DateTime(selected.year, selected.month);
  }

  void move(int offset) => setState(() {
    month = DateTime(month.year, month.month + offset);
    selected = month;
  });
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final all = store.activities
        .where((a) => a.dueAt != null && (store.showCompleted || !a.completed))
        .toList();
    final entries = all.where((a) => sameDay(a.dueAt!, selected)).toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    final firstWeekday = month.weekday % 7;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final cells = ((firstWeekday + count) / 7).ceil() * 7;
    return PageWidth(
      child: ListView(
        key: const PageStorageKey('calendar-scroll'),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${month.year}년 ${month.month}월',
                  key: const Key('calendar-title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  selected = dayOnly(store.referenceDate);
                  month = DateTime(selected.year, selected.month);
                }),
                child: const Text('오늘', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: const Key('previous-month'),
                tooltip: '이전 달',
                onPressed: () => move(-1),
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
              ),
              IconButton(
                key: const Key('next-month'),
                tooltip: '다음 달',
                onPressed: () => move(1),
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final label in ['일', '월', '화', '수', '목', '금', '토'])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: label == '일' ? const Color(0xFFCF8888) : muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 54,
            ),
            itemBuilder: (context, index) {
              final day = index - firstWeekday + 1;
              if (day < 1 || day > count) return const SizedBox.shrink();
              final date = DateTime(month.year, month.month, day);
              final isSelected = sameDay(date, selected);
              final isToday = sameDay(date, store.referenceDate);
              final dayActivities = all
                  .where((a) => sameDay(a.dueAt!, date))
                  .toList();
              return Semantics(
                label: '${dateLabel(date)}, 일정 ${dayActivities.length}개',
                selected: isSelected,
                child: InkWell(
                  key: ValueKey('day-${date.year}-${date.month}-$day'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => selected = date),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? violet
                              : isToday
                              ? lavender
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? violet
                                : index % 7 == 0
                                ? const Color(0xFFCF8888)
                                : ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final a in dayActivities.take(3))
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: a.completed
                                      ? const Color(0xFFCACAD2)
                                      : Color(a.course.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            '${dateLabel(selected)} (${weekday(selected)})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (entries.isEmpty) const EmptyState(title: '일정 없음'),
          for (final activity in entries)
            ActivityCard(
              activity: activity,
              today: store.referenceDate,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ActivityDetail(store: store, activity: activity),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
