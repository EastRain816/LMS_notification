import 'package:flutter/material.dart';

import 'design.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: PageWidth(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > 320
                    ? constraints.maxHeight - 56
                    : 264,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: lavender,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          color: violet,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '모아',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 12),
                    child: FilledButton(
                      key: const Key('google-login'),
                      onPressed: onContinue,
                      child: const Text('Google로 시작하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key, required this.onContinue, this.onBack});
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  bool obscured = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: widget.onBack == null
          ? null
          : IconButton(
              onPressed: widget.onBack,
              tooltip: '뒤로',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
    ),
    body: SafeArea(
      child: PageWidth(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('LMS 연결', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('한동대학교', style: TextStyle(fontSize: 13, color: muted)),
              const SizedBox(height: 32),
              TextField(
                key: const Key('lms-token-input'),
                obscureText: obscured,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: '액세스 토큰',
                  suffixIcon: IconButton(
                    tooltip: obscured ? '토큰 표시' : '토큰 숨기기',
                    onPressed: () => setState(() => obscured = !obscured),
                    icon: Icon(
                      obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: const ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(bottom: 16),
                  title: Text(
                    '토큰 발급 방법',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'LMS 로그인 → 계정 설정 → 새 액세스 토큰',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('confirm-token'),
                onPressed: widget.onContinue,
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
