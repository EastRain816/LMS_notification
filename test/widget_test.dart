import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_ai/main.dart';
import 'package:lms_ai/models/activity.dart';
import 'package:lms_ai/state/demo_store.dart';
import 'package:lms_ai/ui/design.dart';
import 'package:lms_ai/ui/shell.dart';

void mobileSize(WidgetTester tester, {Size size = const Size(430, 932)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> launchDemo(WidgetTester tester) async {
  mobileSize(tester);
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.byKey(const Key('google-login')));
  await tester.tap(find.byKey(const Key('google-login')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('lms-token-input')), findsOneWidget);
  await tester.ensureVisible(find.byKey(const Key('confirm-token')));
  await tester.tap(find.byKey(const Key('confirm-token')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Empty login and token open the demo, calendar and settings', (
    tester,
  ) async {
    await launchDemo(tester);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
    expect(find.text('오늘도, 하나씩.'), findsNothing);
    expect(find.text('확인 필요'), findsNothing);
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-month')));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    expect(find.text('${nextMonth.year}년 ${nextMonth.month}월'), findsOneWidget);
    await tester.tap(find.text('오늘').first);
    await tester.pumpAndSettle();
    expect(find.text('리스트와 반복문 실습 과제'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('마감 알림'), findsOneWidget);
    await tester.tap(find.byKey(const Key('global-notifications')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('global-notifications')))
          .value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Completing an activity updates home and calendar together', (
    tester,
  ) async {
    mobileSize(tester);
    final store = DemoStore(now: DateTime(2026, 10, 20, 10));
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: AppShell(store: store, onLogout: () {}),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('리스트와 반복문 실습 과제'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('리스트와 반복문 실습 과제'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('toggle-completion')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('toggle-completion')));
    await tester.pumpAndSettle();
    expect(store.activities.first.completed, isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('리스트와 반복문 실습 과제'), findsNothing);
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('리스트와 반복문 실습 과제'), findsNothing);
    store.setShowCompleted(true);
    await tester.pumpAndSettle();
    expect(find.text('리스트와 반복문 실습 과제'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Small screens can continue without input', (tester) async {
    mobileSize(tester, size: const Size(320, 568));
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.byKey(const Key('google-login')));
    await tester.tap(find.byKey(const Key('google-login')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('confirm-token')));
    await tester.tap(find.byKey(const Key('confirm-token')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-title')), findsOneWidget);
    expect(find.text('오늘도, 하나씩.'), findsNothing);
    expect(find.text('확인 필요'), findsNothing);
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('AI deadlines remain editable and individual reminder settings stay independent', () {
    final store = DemoStore(now: DateTime(2026, 10, 20, 10));
    final activity = store.activities.firstWhere(
      (a) => a.source == DeadlineSource.ai,
    );
    final changed = DateTime(2026, 10, 23, 18);
    store.updateDeadline(activity, changed);
    expect(activity.dueAt, changed);
    expect(activity.deadlineEdited, isTrue);
    expect(activity.source, DeadlineSource.ai);
    store.setActivityReminderMinutes(activity, 60);
    store.setDefaultReminder(180);
    expect(activity.reminderMinutes, 60);
    expect(store.defaultReminderMinutes, 180);
    store.dispose();
  });
  testWidgets(
    'AI deadlines appear on the calendar and allow reminders without approval',
    (tester) async {
      mobileSize(tester);
      final store = DemoStore(now: DateTime(2026, 10, 20, 10));
      final activity = store.activities.firstWhere(
        (a) => a.source == DeadlineSource.ai,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: AppShell(store: store, onLogout: () {}),
        ),
      );
      expect(find.text('확인 필요'), findsNothing);
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-22')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(activity.title));
      await tester.tap(find.text(activity.title));
      await tester.pumpAndSettle();
      expect(find.text('10월 22일 23:59'), findsOneWidget);
      expect(find.text('시간 확인 필요'), findsNothing);
      await tester.tap(find.byTooltip('알림 설정'));
      await tester.pumpAndSettle();
      final reminderSwitch = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(reminderSwitch.value, isTrue);
      expect(reminderSwitch.onChanged, isNotNull);
      await tester.tap(find.text('3시간 전'));
      await tester.pumpAndSettle();
      expect(activity.reminderMinutes, 180);
      expect(tester.takeException(), isNull);
    },
  );
}
