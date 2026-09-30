-- PostGIS's spatial_ref_sys lives in the exposed public schema without RLS (the
-- table belongs to supabase_admin, so RLS cannot be enabled on it). Default grants
-- let anon and authenticated insert, update and delete through the Data API:
-- anyone holding the public anon key could delete SRID 4326 and break every
-- geography function the app relies on. Keep it readable, make it read-only.
revoke insert, update, delete, truncate on public.spatial_ref_sys from anon, authenticated;
