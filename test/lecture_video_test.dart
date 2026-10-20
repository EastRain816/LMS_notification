import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_ai/state/demo_store.dart';
import 'package:lms_ai/services/lecture_links.dart';
import 'package:lms_ai/ui/activity_detail.dart';
import 'package:lms_ai/ui/design.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  final lectureUrl = Uri.parse(
    'https://lms.handong.edu/courses/22233/modules/items/622864?return_url=/courses/22233/external_tools/47',
  );

  test('App routing succeeds without opening a browser', () async {
    final modes = <LaunchMode>[];
    final opened = await openLectureLink(
      lectureUrl,
      launcher: (url, {required mode}) async {
        expect(url, lectureUrl);
        modes.add(mode);
        return true;
      },
    );
    expect(opened, isTrue);
    expect(modes, [LaunchMode.externalNonBrowserApplication]);
  });

  test(
    'Missing app falls back to the exact original HTTPS lecture URL',
    () async {
      final modes = <LaunchMode>[];
      final opened = await openLectureLink(
        lectureUrl,
        launcher: (url, {required mode}) async {
          expect(url.toString(), lectureUrl.toString());
          modes.add(mode);
          return mode == LaunchMode.externalApplication;
        },
      );
      expect(opened, isTrue);
      expect(modes, [
        LaunchMode.externalNonBrowserApplication,
        LaunchMode.externalApplication,
      ]);
    },
  );

  test(
    'Unsupported app launch still tries the browser and handles total failure',
    () async {
      final modes = <LaunchMode>[];
      final opened = await openLectureLink(
        lectureUrl,
        launcher: (url, {required mode}) async {
          modes.add(mode);
          throw PlatformException(code: 'unavailable');
        },
      );
      expect(opened, isFalse);
      expect(modes.length, 2);
    },
  );

  test('Only HTTPS LMS links are launched', () async {
    for (final value in [
      'http://lms.handong.edu/courses/22233',
      'https://other.example/video',
      'https://user:password@lms.handong.edu/video',
    ]) {
      expect(
        await openLectureLink(
          Uri.parse(value),
          launcher: (url, {required mode}) async {
            fail('Unexpected launch');
          },
        ),
        isFalse,
      );
    }
  });

  testWidgets(
    'A lecture displays duration and a direct link without a fabricated body',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = DemoStore();
      final activity = store.activities.firstWhere((a) => a.id == 'a2');
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: ActivityDetail(store: store, activity: activity),
        ),
      );
      expect(find.text('28분 34초'), findsOneWidget);
      expect(find.byType(SelectableText), findsNothing);
      final button = tester.widget<OutlinedButton>(
        find.byKey(const Key('open-lecture-video')),
      );
      expect(button.onPressed, isNotNull);
      expect(activity.videoUrl, lectureUrl);
      expect(activity.completed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('A demo lecture without a source does not fabricate a link', (
    tester,
  ) async {
    final store = DemoStore();
    final activity = store.activities.firstWhere((a) => a.id == 'a6');
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: ActivityDetail(store: store, activity: activity),
      ),
    );
    expect(find.text('32분'), findsOneWidget);
    expect(find.text('강의 링크 미연결'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('open-lecture-video')),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
