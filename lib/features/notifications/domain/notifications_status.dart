/// What the browser allows for notifications on this device (plan 33).
enum PushPermission {
  /// No Web Push in this browser, or no notification key in this build.
  unsupported,

  /// iPhone or iPad with NUNI opened in the browser: iOS only lets an app
  /// installed on the home screen receive notifications.
  needsInstall,

  /// The phone's "Allow / Don't allow" window was never answered.
  prompt,
  granted,

  /// "Don't allow": final for the app, only the phone's settings undo it.
  denied,
}

/// What the Settings switch shows, from the browser's permission and the
/// user's choice on this device (on by default, Q225).
enum NotificationsStatus { unsupported, needsInstall, denied, toAsk, off, on }

NotificationsStatus notificationsStatus({
  required PushPermission permission,
  required bool enabled,
}) => switch (permission) {
  PushPermission.unsupported => NotificationsStatus.unsupported,
  PushPermission.needsInstall => NotificationsStatus.needsInstall,
  PushPermission.denied => NotificationsStatus.denied,
  PushPermission.prompt =>
    enabled ? NotificationsStatus.toAsk : NotificationsStatus.off,
  PushPermission.granted =>
    enabled ? NotificationsStatus.on : NotificationsStatus.off,
};

/// Whether the first touch in the app should bring up the phone's window
/// (Q235): once per device, signed in, notifications left on, never
/// answered yet.
bool shouldAskOnFirstTouch({
  required PushPermission permission,
  required bool enabled,
  required bool alreadyAsked,
  required bool signedIn,
}) =>
    signedIn && enabled && !alreadyAsked && permission == PushPermission.prompt;
