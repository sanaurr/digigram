import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
extension Dateformatter on DateTime {
  String get formattedTime {
    var local = toLocal();
    var duration = DateTime.now().difference(local);
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inSeconds > 10) {
      return '${duration.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
