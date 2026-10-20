import 'package:flutter/material.dart';

import '../state/demo_store.dart';
import 'design.dart';
import 'onboarding.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.onLogout,
  });
  final DemoStore store;
  final VoidCallback onLogout;

  Future<void> editReminder(BuildContext context) async {
    final value = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [60, 180, 1440, 2880])
              ListTile(
                title: Text(reminderLabel(minutes)),
                trailing: store.defaultReminderMinutes == minutes
                    ? const Icon(Icons.check_rounded, color: violet)
                    : null,
                onTap: () => Navigator.pop(context, minutes),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (value != null) store.setDefaultReminder(value);
  }

  Future<void> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃할까요?'),
        content: const Text('일정과 설정이 초기화됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) => PageWidth(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      children: [
        Text('설정', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        const _SectionLabel('알림'),
        SwitchListTile.adaptive(
          key: const Key('global-notifications'),
          contentPadding: EdgeInsets.zero,
          title: const Text('마감 알림', style: TextStyle(fontSize: 14)),
          value: store.notificationsEnabled,
          onChanged: store.setNotifications,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('기본 알림 시점', style: TextStyle(fontSize: 14)),
          trailing: Text(
            reminderLabel(store.defaultReminderMinutes),
            style: TextStyle(
              fontSize: 13,
              color: store.notificationsEnabled ? violet : muted,
            ),
          ),
          onTap: store.notificationsEnabled
              ? () => editReminder(context)
              : null,
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 22),
        const _SectionLabel('화면'),
        SwitchListTile.adaptive(
          key: const Key('show-completed'),
          contentPadding: EdgeInsets.zero,
          title: const Text('완료한 활동 표시', style: TextStyle(fontSize: 14)),
          value: store.showCompleted,
          onChanged: store.setShowCompleted,
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 22),
        const _SectionLabel('계정'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('LMS 토큰', style: TextStyle(fontSize: 14)),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: muted,
            size: 18,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TokenScreen(
                onBack: () => Navigator.pop(context),
                onContinue: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('로그아웃', style: TextStyle(fontSize: 14)),
          onTap: () => confirmLogout(context),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: muted,
            ),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('모아 · 데모'),
                content: const Text(
                  '더미데이터를 사용하는 UI 버전입니다.\n실제 로그인·LMS 연결·AI 분석·알림 전송은 수행하지 않습니다.\n일정과 설정은 앱 재시작 시 초기화됩니다.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
            child: const Text('앱 정보', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontSize: 12, color: muted)),
  );
}
