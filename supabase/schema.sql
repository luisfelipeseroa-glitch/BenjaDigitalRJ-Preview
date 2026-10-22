-- BenjaDigital.RJ - execute no SQL Editor do projeto Supabase
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 description text not null default '',
 category text not null default 'Artes gráficas',
 price numeric(12,2) not null default 0 check(price >= 0),
 image_url text,
 file_url text,
 active boolean not null default false,
 created_at timestamptz not null default now()
);
create index if not exists products_active_idx on public.products(active,created_at desc);
alter table public.products enable row level security;
create policy "Publico ve produtos ativos" on public.products for select to anon,authenticated using (active = true);
-- Administradores são cadastrados manualmente após criação no Authentication
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.admins enable row level security;
create policy "Admin consulta seu cadastro" on public.admins for select to authenticated using(user_id = (select auth.uid()));
create policy "Admin consulta todos produtos" on public.products for select to authenticated using(exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin insere produtos" on public.products for insert to authenticated with check(exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin altera produtos" on public.products for update to authenticated using(exists(select 1 from public.admins a where a.user_id=(select auth.uid()))) with check(exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin exclui produtos" on public.products for delete to authenticated using(exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
-- Depois de criar seu usuário no Authentication, conceda acesso:
-- insert into public.admins(user_id) values ('UUID-DO-SEU-USUARIO');
-- Nunca exponha a chave service_role no site. Mantenha downloads pagos privados até criar entrega segura.
