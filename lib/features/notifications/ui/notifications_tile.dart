import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../data/notifications_controller.dart';
import '../domain/notifications_status.dart';

/// The one notification setting (plan 33, Q225): a switch for this device,
/// on by default, with a line saying why it can't be turned on when the
/// browser or the phone doesn't allow it.
class NotificationsTile extends ConsumerWidget {
  const NotificationsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final blocked = switch (status) {
      NotificationsStatus.unsupported ||
      NotificationsStatus.needsInstall ||
      NotificationsStatus.denied => true,
      _ => false,
    };
    final subtitle = switch (status) {
      NotificationsStatus.unsupported => l10n.settingsNotificationsUnsupported,
      NotificationsStatus.needsInstall =>
        l10n.settingsNotificationsNeedsInstall,
      NotificationsStatus.denied => l10n.settingsNotificationsDenied,
      NotificationsStatus.toAsk => l10n.settingsNotificationsToAsk,
      NotificationsStatus.off ||
      NotificationsStatus.on => l10n.settingsNotificationsThisDevice,
    };

    return NuniGroupedList(
      children: [
        ListTile(
          leading: const NuniIconTile(
            icon: PhosphorIcons.bell,
            tone: NuniTone.primary,
            size: 36,
          ),
          title: Text(l10n.settingsNotifications),
          subtitle: Text(subtitle),
          trailing: Switch(
            value: status == NotificationsStatus.on,
            onChanged: blocked
                ? null
                : (on) => on ? controller.turnOn() : controller.turnOff(),
          ),
          // "To ask": the switch shows off until the phone says yes; a
          // touch anywhere on the line brings up its window.
          onTap: status == NotificationsStatus.toAsk ? controller.turnOn : null,
        ),
      ],
    );
  }
}
