{{flutter_js}}
{{flutter_build_config}}

// Flutter's own service worker is left out on purpose (plan 33): the one Flutter now publishes
// only unregisters itself, and it would replace NUNI's, which shows the notifications.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('nuni_sw.js').catch(() => {});
}

_flutter.loader.load();
