import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../state/demo_store.dart';
import 'design.dart';
import 'lecture_video.dart';

class ActivityDetail extends StatelessWidget {
  const ActivityDetail({
    super.key,
    required this.store,
    required this.activity,
  });
  final DemoStore store;
  final Activity activity;

  Future<void> editDeadline(BuildContext context) async {
    final initial = activity.dueAt ?? store.referenceDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 5),
      lastDate: DateTime(initial.year + 5),
      helpText: '마감 날짜',
      cancelText: '취소',
      confirmText: '다음',
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: '마감 시간',
      cancelText: '취소',
      confirmText: '저장',
    );
    if (time == null || !context.mounted) return;
    store.updateDeadline(
      activity,
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  Future<void> showReminder(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final enabled =
                store.notificationsEnabled && activity.dueAt != null;
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('알림'),
                    subtitle: !enabled
                        ? Text(
                            activity.dueAt == null
                                ? '마감기한 설정 필요'
                                : '설정에서 전체 알림을 켜주세요',
                            style: const TextStyle(fontSize: 12, color: muted),
                          )
                        : null,
                    value: enabled && activity.remindersEnabled,
                    onChanged: enabled
                        ? (value) => store.setActivityReminder(activity, value)
                        : null,
                  ),
                  if (enabled && activity.remindersEnabled)
                    for (final minutes in [60, 180, 1440, 2880])
                      ListTile(
                        title: Text(
                          reminderLabel(minutes),
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing:
                            (activity.reminderMinutes ??
                                    store.defaultReminderMinutes) ==
                                minutes
                            ? const Icon(Icons.check_rounded, color: violet)
                            : null,
                        onTap: () =>
                            store.setActivityReminderMinutes(activity, minutes),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final a = activity;
      final source = a.deadlineEdited
          ? '직접 수정'
          : a.source == DeadlineSource.ai
          ? 'AI 추출'
          : 'LMS 등록';
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              tooltip: '알림 설정',
              onPressed: () => showReminder(context),
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: PageWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                Text(
                  '${a.course.name} · ${a.type.label}',
                  style: TextStyle(
                    color: Color(a.course.colorValue),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  a.title,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 17, color: muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.dueAt == null
                            ? '기한 없음'
                            : '${dateLabel(a.dueAt!)} ${timeLabel(a.dueAt!)}',
                        style: TextStyle(fontSize: 14, color: ink),
                      ),
                    ),
                    TextButton(
                      key: const Key('edit-deadline'),
                      onPressed: () => editDeadline(context),
                      child: Text(
                        a.dueAt == null ? '추가' : '수정',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (a.dueAt != null)
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 16),
                      title: const Text(
                        '기한 정보',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                source,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                              if (a.evidence != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '“${a.evidence}”',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 22),
                if (a.type == ActivityType.lecture) ...[
                  LectureVideo(activity: a),
                  if (a.body.trim().isNotEmpty) const SizedBox(height: 24),
                ],
                if (a.body.trim().isNotEmpty)
                  SelectableText(
                    a.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: PageWidth(
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('toggle-completion'),
                  onPressed: () => store.toggleCompleted(a),
                  child: Text(a.completed ? '완료 취소' : '완료'),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
