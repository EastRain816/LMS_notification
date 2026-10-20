import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/lecture_links.dart';
import 'design.dart';

class LectureVideo extends StatefulWidget {
  const LectureVideo({super.key, required this.activity});
  final Activity activity;
  @override
  State<LectureVideo> createState() => _LectureVideoState();
}

class _LectureVideoState extends State<LectureVideo> {
  bool opening = false;

  Future<void> openVideo() async {
    final url = widget.activity.videoUrl;
    if (url == null || opening) return;
    setState(() => opening = true);
    final opened = await openLectureLink(url);
    if (!mounted) return;
    setState(() => opening = false);
    if (!opened) toast(context, '강의 링크를 열 수 없어요. LearningX에서 확인해주세요.');
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                size: 46,
                color: violet,
              ),
              const SizedBox(height: 12),
              Text(
                videoDurationLabel(activity.videoDuration),
                key: const Key('video-duration'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('open-lecture-video'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: line),
          ),
          onPressed: activity.videoUrl != null && !opening ? openVideo : null,
          icon: opening
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.open_in_new_rounded, size: 17),
          label: Text(
            activity.videoUrl == null ? '강의 링크 미연결' : 'LearningX에서 보기',
          ),
        ),
      ],
    );
  }
}
