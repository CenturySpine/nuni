import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/notifications/domain/notifications_status.dart';

void main() {
  group('notificationsStatus', () {
    test('what the browser forbids wins over the switch', () {
      for (final enabled in [true, false]) {
        expect(
          notificationsStatus(
            permission: PushPermission.unsupported,
            enabled: enabled,
          ),
          NotificationsStatus.unsupported,
        );
        expect(
          notificationsStatus(
            permission: PushPermission.needsInstall,
            enabled: enabled,
          ),
          NotificationsStatus.needsInstall,
        );
        expect(
          notificationsStatus(
            permission: PushPermission.denied,
            enabled: enabled,
          ),
          NotificationsStatus.denied,
        );
      }
    });

    test('on by default, but only once the phone said yes', () {
      expect(
        notificationsStatus(permission: PushPermission.prompt, enabled: true),
        NotificationsStatus.toAsk,
      );
      expect(
        notificationsStatus(permission: PushPermission.granted, enabled: true),
        NotificationsStatus.on,
      );
    });

    test('turned off by the user stays off', () {
      expect(
        notificationsStatus(permission: PushPermission.granted, enabled: false),
        NotificationsStatus.off,
      );
      expect(
        notificationsStatus(permission: PushPermission.prompt, enabled: false),
        NotificationsStatus.off,
      );
    });
  });

  group('shouldAskOnFirstTouch', () {
    bool ask({
      PushPermission permission = PushPermission.prompt,
      bool enabled = true,
      bool alreadyAsked = false,
      bool signedIn = true,
    }) => shouldAskOnFirstTouch(
      permission: permission,
      enabled: enabled,
      alreadyAsked: alreadyAsked,
      signedIn: signedIn,
    );

    test('asks a signed-in user whose phone never answered', () {
      expect(ask(), isTrue);
    });

    test('asks only once per device', () {
      expect(ask(alreadyAsked: true), isFalse);
    });

    test('never before sign-in, nor once turned off', () {
      expect(ask(signedIn: false), isFalse);
      expect(ask(enabled: false), isFalse);
    });

    test('never once the phone answered, nor where it cannot', () {
      for (final permission in [
        PushPermission.granted,
        PushPermission.denied,
        PushPermission.unsupported,
        PushPermission.needsInstall,
      ]) {
        expect(ask(permission: permission), isFalse);
      }
    });
  });
}
