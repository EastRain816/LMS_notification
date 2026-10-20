import 'package:url_launcher/url_launcher.dart';

typedef LectureUrlLauncher = Future<bool> Function(
  Uri url, {
  required LaunchMode mode,
});

Future<bool> _launch(Uri url, {required LaunchMode mode}) =>
    launchUrl(url, mode: mode);

/// Opens the original LMS page, preserving its authentication and attendance flow.
/// A supported app is preferred; the same HTTPS page is the fallback.
Future<bool> openLectureLink(Uri url, {LectureUrlLauncher? launcher}) async {
  if (url.scheme != 'https' ||
      url.host != 'lms.handong.edu' ||
      url.userInfo.isNotEmpty) {
    return false;
  }
  final launch = launcher ?? _launch;
  for (final mode in [
    LaunchMode.externalNonBrowserApplication,
    LaunchMode.externalApplication,
  ]) {
    try {
      if (await launch(url, mode: mode)) return true;
    } on Exception {
      // Missing app or platform channel: attempt the browser fallback next.
    } on UnsupportedError {
      // Some targets do not implement the non-browser mode.
    }
  }
  return false;
}
