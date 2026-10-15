create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,email text,role text not null default 'member' check(role in ('member','admin')),created_at timestamptz not null default now());
create table if not exists public.site_settings(id integer primary key default 1 check(id=1),site_name text not null default 'CloudMint',maintenance_mode boolean not null default false,max_validity_days integer not null default 120 check(max_validity_days between 1 and 120),min_withdrawal numeric(12,2) not null default 5 check(min_withdrawal>=5),updated_at timestamptz not null default now());
insert into public.site_settings(id) values(1) on conflict(id) do nothing;
create table if not exists public.payment_requests(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,kind text not null check(kind in ('deposit','withdrawal')),amount numeric(12,2) not null check(amount>0),reference text,wallet_address text,status text not null default 'pending' check(status in ('pending','approved','rejected','paid')),created_at timestamptz not null default now(),reviewed_at timestamptz);
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
alter table public.profiles enable row level security; alter table public.site_settings enable row level security; alter table public.payment_requests enable row level security;
create policy "profile self or admin read" on public.profiles for select to authenticated using(id=auth.uid() or public.is_admin());
create policy "public settings read" on public.site_settings for select to anon,authenticated using(true);
create policy "admin settings update" on public.site_settings for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "user creates own pending request" on public.payment_requests for insert to authenticated with check(user_id=auth.uid() and status='pending');
create policy "user or admin reads requests" on public.payment_requests for select to authenticated using(user_id=auth.uid() or public.is_admin());
create policy "admin reviews requests" on public.payment_requests for update to authenticated using(public.is_admin()) with check(public.is_admin());
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,email,role) values(new.id,new.email,'member') on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
-- After signing up, get your UUID from Supabase Authentication > Users, then run:
-- update public.profiles set role='admin' where id='YOUR-USER-UUID';
