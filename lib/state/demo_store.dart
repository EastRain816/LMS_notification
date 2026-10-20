import 'package:flutter/foundation.dart';

import '../models/activity.dart';

/// In-memory preview state. Never authenticates or stores LMS credentials.
class DemoStore extends ChangeNotifier {
  DemoStore({DateTime? now}) : referenceDate = now ?? DateTime.now() {
    activities = createDemoActivities(referenceDate);
  }
  final DateTime referenceDate;
  late final List<Activity> activities;
  bool notificationsEnabled = true;
  bool showCompleted = false;
  int defaultReminderMinutes = 1440;
  DateTime? lastSynced;

  List<Course> get courses =>
      {for (final a in activities) a.course.id: a.course}.values.toList();
  int get pendingCount =>
      activities.where((a) => !a.completed && a.dueAt != null).length;

  void toggleCompleted(Activity activity) {
    activity.completed = !activity.completed;
    notifyListeners();
  }

  void updateDeadline(Activity activity, DateTime date) {
    activity.dueAt = date;
    activity.deadlineEdited = true;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setShowCompleted(bool value) {
    showCompleted = value;
    notifyListeners();
  }

  void setDefaultReminder(int value) {
    defaultReminderMinutes = value;
    notifyListeners();
  }

  void setActivityReminder(Activity activity, bool value) {
    activity.remindersEnabled = value;
    notifyListeners();
  }

  void setActivityReminderMinutes(Activity activity, int value) {
    activity.reminderMinutes = value;
    notifyListeners();
  }

  void refreshDemo() {
    lastSynced = DateTime.now();
    notifyListeners();
  }
}
