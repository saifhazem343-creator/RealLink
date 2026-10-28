-- Run this file in Supabase Dashboard > SQL Editor.
create table if not exists public.reallink_units (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  payload jsonb not null,
  created_at timestamptz not null default now()
);
create index if not exists reallink_units_created_at_idx on public.reallink_units (created_at desc);
alter table public.reallink_units enable row level security;
drop policy if exists "Public can read published units" on public.reallink_units;
create policy "Public can read published units" on public.reallink_units for select using (true);
drop policy if exists "Owners can insert their units" on public.reallink_units;
create policy "Owners can insert their units" on public.reallink_units for insert to authenticated with check (auth.uid() = owner_id);
drop policy if exists "Owners can update their units" on public.reallink_units;
create policy "Owners can update their units" on public.reallink_units for update to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
drop policy if exists "Owners can delete their units" on public.reallink_units;
create policy "Owners can delete their units" on public.reallink_units for delete to authenticated using (auth.uid() = owner_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('reallink-images', 'reallink-images', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do nothing;
drop policy if exists "Public can view RealLink images" on storage.objects;
create policy "Public can view RealLink images" on storage.objects for select using (bucket_id = 'reallink-images');
drop policy if exists "Users can upload RealLink images to own folder" on storage.objects;
create policy "Users can upload RealLink images to own folder" on storage.objects for insert to authenticated with check (bucket_id = 'reallink-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users can update own RealLink images" on storage.objects;
create policy "Users can update own RealLink images" on storage.objects for update to authenticated using (bucket_id = 'reallink-images' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id = 'reallink-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users can delete own RealLink images" on storage.objects;
create policy "Users can delete own RealLink images" on storage.objects for delete to authenticated using (bucket_id = 'reallink-images' and (storage.foldername(name))[1] = auth.uid()::text);
