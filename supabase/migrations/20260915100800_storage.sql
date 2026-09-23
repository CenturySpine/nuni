-- Storage buckets and policies (plan 03). Public read (paths are UUID-based, not guessable),
-- authenticated write restricted to the owner of the path's first folder segment.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('holes', 'holes', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('session-photos', 'session-photos', true)
on conflict (id) do nothing;

-- avatars/<user_id>/...
create policy "avatars_public_read" on storage.objects for select
  using (bucket_id = 'avatars');

create policy "avatars_owner_insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars_owner_update" on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars_owner_delete" on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- holes/<owner_id>/...
create policy "holes_bucket_public_read" on storage.objects for select
  using (bucket_id = 'holes');

create policy "holes_bucket_owner_insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'holes' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "holes_bucket_owner_update" on storage.objects for update to authenticated
  using (bucket_id = 'holes' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'holes' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "holes_bucket_owner_delete" on storage.objects for delete to authenticated
  using (bucket_id = 'holes' and (storage.foldername(name))[1] = auth.uid()::text);

-- session-photos/<session_id>/...: ownership follows the session, not the uploader.
create policy "session_photos_bucket_public_read" on storage.objects for select
  using (bucket_id = 'session-photos');

create policy "session_photos_bucket_owner_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'session-photos'
    and is_session_owner((storage.foldername(name))[1]::uuid)
  );

create policy "session_photos_bucket_owner_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'session-photos'
    and is_session_owner((storage.foldername(name))[1]::uuid)
  );

-- association-logos/<association_id>/... (plan 18): written by that association's approved local
-- manager or a super_admin, public read like the other buckets.
insert into storage.buckets (id, name, public)
values ('association-logos', 'association-logos', true)
on conflict (id) do nothing;

create policy "association_logos_public_read" on storage.objects for select
  using (bucket_id = 'association-logos');

create policy "association_logos_manager_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'association-logos'
    and (
      is_association_manager((storage.foldername(name))[1]::uuid)
      or is_super_admin()
    )
  );

create policy "association_logos_manager_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'association-logos'
    and (
      is_association_manager((storage.foldername(name))[1]::uuid)
      or is_super_admin()
    )
  );
