import 'dart:io';

import 'package:commet/config/build_config.dart';
import 'package:commet/ui/pages/setup/menus/unified_push_setup.dart';
import 'package:commet/utils/first_time_setup.dart';
import 'package:commet/utils/notification/android/firebase_push_notifier.dart';
import 'package:commet/utils/notification/android/unified_push_notifier.dart';
import 'package:commet/utils/notification/linux/linux_notifier.dart';
import 'package:commet/utils/notification/notification_content.dart';
import 'package:commet/utils/notification/notification_modifiers.dart';
import 'package:commet/utils/notification/notifier.dart';
import 'package:commet/utils/notification/windows/windows_notifier.dart';

class NotificationManager {
  late final Notifier? _notifier;

  NotificationManager() {
    if (Platform.isLinux) {
      _notifier = LinuxNotifier();
      return;
    }

    if (Platform.isAndroid) {
      if (BuildConfig.ENABLE_GOOGLE_SERVICES) {
        _notifier = FirebasePushNotifier();
      } else {
        _notifier = UnifiedPushNotifier();
      }
      return;
    }

    if (Platform.isWindows) {
      _notifier = WindowsNotifier();
    }
  }

  final List<NotificationModifier> _modifiers = List.empty(growable: true);

  Future<void> init() async {
    _modifiers.clear;
    addModifier(NotificationModifierDontNotifyActiveRoom());
    await _notifier?.init();
  }

  void addModifier(NotificationModifier modifier) {
    _modifiers.add(modifier);
  }

  void removeModifier(NotificationModifier modifier) {
    _modifiers.remove(modifier);
  }

  Future<void> notify(NotificationContent notification,
      {bool bypassModifiers = false}) async {
    if (_notifier == null) return;

    NotificationContent? content = notification;

    if (!bypassModifiers) {
      for (var modifier in _modifiers) {
        content = modifier.process(content!);
        if (content == null) return;
      }
    }

    await _notifier!.notify(notification);
  }
}
