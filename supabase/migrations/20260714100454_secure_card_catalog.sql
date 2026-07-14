create table if not exists public.cards (
  id text primary key,
  name text not null,
  issuer text not null,
  image_url text,
  apply_url text
);

create table if not exists public.card_benefits (
  id uuid primary key default gen_random_uuid(),
  card_id text not null references public.cards(id) on delete cascade,
  category text not null,
  benefit_type text not null,
  rate numeric(5, 2) not null,
  conditions text,
  merchants text[]
);

alter table public.card_benefits
  add column if not exists merchants text[];

alter table public.cards enable row level security;
alter table public.card_benefits enable row level security;

revoke all on table public.cards from anon, authenticated;
revoke all on table public.card_benefits from anon, authenticated;
grant select on table public.cards to anon, authenticated;
grant select on table public.card_benefits to anon, authenticated;

drop policy if exists "Public cards are readable" on public.cards;
create policy "Public cards are readable"
on public.cards
for select
to anon, authenticated
using (true);

drop policy if exists "Public card benefits are readable" on public.card_benefits;
create policy "Public card benefits are readable"
on public.card_benefits
for select
to anon, authenticated
using (true);
