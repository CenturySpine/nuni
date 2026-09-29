// NUNI's service worker (plan 33): shows the planning notifications sent by the send-push
// Edge Function, and brings the app to the event's page when one is touched. No cache, nothing
// else: Flutter's own service worker is not loaded (see flutter_bootstrap.js).

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

self.addEventListener('push', (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_) {
    // Not ours or unreadable: still show something, as browsers require for every push.
  }
  event.waitUntil(
    self.registration.showNotification(data.title || 'NUNI', {
      body: data.body || '',
      icon: 'icons/Icon-192.png',
      // Same tag = replaces the previous notification of that kind (Q232), with a sound again.
      tag: data.tag,
      renotify: Boolean(data.tag),
      data: { url: data.url || '/' },
    }),
  );
});

// An open NUNI window is focused and told where to go (the app routes in place, no reload);
// otherwise a new one opens on the event's page.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const path = (event.notification.data && event.notification.data.url) || '/';
  event.waitUntil(
    (async () => {
      const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
      for (const client of windows) {
        if (new URL(client.url).origin === self.location.origin) {
          await client.focus();
          client.postMessage({ type: 'nuni-open', path });
          return;
        }
      }
      await self.clients.openWindow(new URL(path, self.location.origin).href);
    })(),
  );
});
