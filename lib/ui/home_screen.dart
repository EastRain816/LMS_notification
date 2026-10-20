import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../state/demo_store.dart';
import 'activity_detail.dart';
import 'design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ActivityType? type;
  String? courseId;

  void open(Activity activity) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ActivityDetail(store: widget.store, activity: activity),
    ),
  );

  String groupFor(Activity a) {
    if (a.completed) return '완료';
    if (a.dueAt == null) return '기한 없음';
    final days = dayOnly(a.dueAt!)
        .difference(dayOnly(widget.store.referenceDate))
        .inDays;
    if (days < 0) return '기한 지남';
    if (days == 0) return '오늘';
    if (days == 1) return '내일';
    if (days < 7) return '일주일 안에';
    return '이후';
  }

  Future<void> chooseCourse() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('전체 과목'),
                trailing: courseId == null
                    ? const Icon(Icons.check, color: violet)
                    : null,
                onTap: () => Navigator.pop(context, 'all'),
              ),
              for (final course in widget.store.courses)
                ListTile(
                  leading: CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(course.colorValue),
                  ),
                  title: Text(course.name),
                  trailing: courseId == course.id
                      ? const Icon(Icons.check, color: violet)
                      : null,
                  onTap: () => Navigator.pop(context, course.id),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => courseId = selected == 'all' ? null : selected);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final now = store.referenceDate;
    final visible =
        store.activities
            .where(
              (a) =>
                  (store.showCompleted || !a.completed) &&
                  (type == null || a.type == type) &&
                  (courseId == null || a.course.id == courseId),
            )
            .toList()
          ..sort((a, b) {
            if (a.completed != b.completed) return a.completed ? 1 : -1;
            if (a.dueAt == null) return b.dueAt == null ? 0 : 1;
            if (b.dueAt == null) return -1;
            return a.dueAt!.compareTo(b.dueAt!);
          });
    final groups = <String, List<Activity>>{};
    for (final activity in visible) {
      groups.putIfAbsent(groupFor(activity), () => []).add(activity);
    }
    final selectedCourse = courseId == null
        ? '전체 과목'
        : store.courses.firstWhere((c) => c.id == courseId).name;
    return PageWidth(
      child: RefreshIndicator(
        onRefresh: () async => store.refreshDemo(),
        child: ListView(
          key: const PageStorageKey('home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          children: [
            Text(
              '할 일',
              key: const Key('home-title'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Container(
              key: const Key('remaining-tasks-card'),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF806BDD), Color(0xFF6952C3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '남은 할 일',
                    style: TextStyle(color: Color(0xFFE6E0FF), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${store.pendingCount}개',
                    key: const Key('remaining-tasks-count'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '전체',
                          selected: type == null,
                          onTap: () => setState(() => type = null),
                        ),
                        for (final item in ActivityType.values)
                          _FilterChip(
                            label: item.label,
                            selected: type == item,
                            onTap: () => setState(() => type = item),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 112),
                  child: TextButton(
                    onPressed: chooseCourse,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            selectedCourse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: muted),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty) const EmptyState(title: '활동 없음'),
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 2),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: entry.key == '기한 지남'
                        ? const Color(0xFFCA7373)
                        : muted,
                  ),
                ),
              ),
              for (final activity in entry.value)
                ActivityCard(
                  activity: activity,
                  today: now,
                  onTap: () => open(activity),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: lavender,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? violet : muted,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(color: selected ? lavender : line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );
}
