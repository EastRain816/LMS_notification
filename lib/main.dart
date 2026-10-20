import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'state/demo_store.dart';
import 'ui/design.dart';
import 'ui/onboarding.dart';
import 'ui/shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '모아 · 나의 학습 일정',
    locale: const Locale('ko'),
    supportedLocales: const [Locale('ko'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: const AppEntry(),
  );
}

enum _EntryStage { welcome, token, app }

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});
  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  _EntryStage stage = _EntryStage.welcome;
  DemoStore store = DemoStore();
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  void logout() {
    setState(() {
      stage = _EntryStage.welcome;
      final oldStore = store;
      store = DemoStore();
      WidgetsBinding.instance.addPostFrameCallback((_) => oldStore.dispose());
    });
  }

  @override
  Widget build(BuildContext context) => switch (stage) {
    _EntryStage.welcome => WelcomeScreen(
      onContinue: () => setState(() => stage = _EntryStage.token),
    ),
    _EntryStage.token => TokenScreen(
      onContinue: () => setState(() => stage = _EntryStage.app),
      onBack: () => setState(() => stage = _EntryStage.welcome),
    ),
    _EntryStage.app => AppShell(store: store, onLogout: logout),
  };
}
