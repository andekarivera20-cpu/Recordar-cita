-- RecordaCita - esquema base de Supabase
-- Este archivo documenta la estructura necesaria para la web y el panel.
-- NO contiene tokens, contraseñas ni credenciales de WhatsApp.
-- El envío automático de WhatsApp en segundo plano todavía no está desplegado.

create table if not exists public.reminder_businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  name text not null default 'Mi negocio',
  timezone text not null default 'Europe/Madrid',
  whatsapp_phone_number_id text,
  whatsapp_template_name text not null default 'appointment_reminder',
  whatsapp_template_language text not null default 'es',
  whatsapp_configured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reminder_appointments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.reminder_businesses(id) on delete cascade,
  client_name text not null,
  phone text not null,
  worker text,
  service text,
  appointment_at timestamptz not null,
  reminder_hours integer not null default 24 check (reminder_hours between 1 and 168),
  reminder_at timestamptz not null,
  channel text not null default 'whatsapp' check (channel in ('whatsapp','sms','email')),
  reminder_status text not null default 'pending' check (
    reminder_status in ('pending','processing','sent','failed','cancelled','waiting_provider')
  ),
  sent_at timestamptz,
  provider_message_id text,
  attempts integer not null default 0,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists reminder_appointments_due_idx
on public.reminder_appointments(reminder_status, reminder_at);

alter table public.reminder_businesses enable row level security;
alter table public.reminder_appointments enable row level security;

drop policy if exists "owners_read_business" on public.reminder_businesses;
create policy "owners_read_business"
on public.reminder_businesses for select
to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "owners_update_business" on public.reminder_businesses;
create policy "owners_update_business"
on public.reminder_businesses for update
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

drop policy if exists "owners_read_appointments" on public.reminder_appointments;
create policy "owners_read_appointments"
on public.reminder_appointments for select
to authenticated
using (
  exists (
    select 1
    from public.reminder_businesses b
    where b.id = business_id
      and b.owner_id = (select auth.uid())
  )
);

drop policy if exists "owners_insert_appointments" on public.reminder_appointments;
create policy "owners_insert_appointments"
on public.reminder_appointments for insert
to authenticated
with check (
  exists (
    select 1
    from public.reminder_businesses b
    where b.id = business_id
      and b.owner_id = (select auth.uid())
  )
);

drop policy if exists "owners_update_appointments" on public.reminder_appointments;
create policy "owners_update_appointments"
on public.reminder_appointments for update
to authenticated
using (
  exists (
    select 1
    from public.reminder_businesses b
    where b.id = business_id
      and b.owner_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.reminder_businesses b
    where b.id = business_id
      and b.owner_id = (select auth.uid())
  )
);

drop policy if exists "owners_delete_appointments" on public.reminder_appointments;
create policy "owners_delete_appointments"
on public.reminder_appointments for delete
to authenticated
using (
  exists (
    select 1
    from public.reminder_businesses b
    where b.id = business_id
      and b.owner_id = (select auth.uid())
  )
);

create table if not exists public.recordacita_leads (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 80),
  phone text not null check (char_length(trim(phone)) between 6 and 30),
  business_type text not null check (char_length(trim(business_type)) between 2 and 80),
  city text check (city is null or char_length(trim(city)) <= 100),
  message text check (message is null or char_length(message) <= 1000),
  consent boolean not null default false check (consent = true),
  source text not null default 'recordacita_web',
  status text not null default 'new' check (status in ('new','contacted','won','lost')),
  created_at timestamptz not null default now()
);

alter table public.recordacita_leads enable row level security;

drop policy if exists "public_can_submit_recordacita_lead" on public.recordacita_leads;
create policy "public_can_submit_recordacita_lead"
on public.recordacita_leads for insert
to anon, authenticated
with check (
  consent = true
  and source = 'recordacita_web'
  and status = 'new'
);

drop policy if exists "recordacita_owner_read_leads" on public.recordacita_leads;
create policy "recordacita_owner_read_leads"
on public.recordacita_leads for select
to authenticated
using (
  lower(coalesce((select auth.jwt()->>'email'), '')) = 'andekarivera20@gmail.com'
);

drop policy if exists "recordacita_owner_update_leads" on public.recordacita_leads;
create policy "recordacita_owner_update_leads"
on public.recordacita_leads for update
to authenticated
using (
  lower(coalesce((select auth.jwt()->>'email'), '')) = 'andekarivera20@gmail.com'
)
with check (
  lower(coalesce((select auth.jwt()->>'email'), '')) = 'andekarivera20@gmail.com'
);

revoke all on public.recordacita_leads from anon, authenticated;
grant insert (name, phone, business_type, city, message, consent) on public.recordacita_leads to anon, authenticated;
grant select on public.recordacita_leads to authenticated;
grant update (status) on public.recordacita_leads to authenticated;
