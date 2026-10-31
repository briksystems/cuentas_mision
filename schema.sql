-- =============================================================
-- Cuentas de la misión - Base de datos para Supabase
-- Copia TODO este archivo en Supabase > SQL Editor > New query > Run
-- =============================================================

-- 1. Miembros del equipo y su rol
--    pendiente: se registró pero no ve nada hasta que lo aprueben
--    lector:    solo ve las cuentas
--    editor:    ve y registra movimientos y facturas
--    admin:     todo, más aprobar gente y cambiar datos de la misión
create table public.miembros (
  user_id  uuid primary key references auth.users(id) on delete cascade,
  email    text not null,
  nombre   text,
  rol      text not null default 'pendiente'
           check (rol in ('pendiente','lector','editor','admin')),
  creado   timestamptz not null default now()
);

-- 2. Datos generales de la misión (una sola fila)
create table public.config (
  id          int primary key default 1 check (id = 1),
  nombre      text not null default 'Cuentas de la misión',
  presupuesto bigint not null default 0
);
insert into public.config (id) values (1);

-- 3. Movimientos (entradas y salidas)
--    numero: consecutivo automático. Es el número de soporte que
--    va pegado a la foto de la factura (0001.jpg, 0002.jpg...)
create table public.movimientos (
  id          uuid primary key default gen_random_uuid(),
  numero      bigint generated always as identity unique,
  tipo        text not null check (tipo in ('ingreso','gasto')),
  monto       bigint not null check (monto > 0),
  fecha       date not null default current_date,
  categoria   text not null,
  descripcion text not null default '',
  metodo      text,
  responsable text,
  nota        text,
  foto_path   text,
  foto_tipo   text,
  creado_por  uuid default auth.uid() references auth.users(id) on delete set null,
  creado      timestamptz not null default now(),
  editado     timestamptz not null default now()
);
create index movimientos_fecha_idx on public.movimientos (fecha desc);

-- 4. Función que dice el rol de quien está conectado
create or replace function public.mi_rol()
returns text language sql stable security definer set search_path = public as $$
  select rol from public.miembros where user_id = auth.uid()
$$;

-- 5. Cuando alguien se registra queda como pendiente.
--    El PRIMERO que se registra queda como admin.
create or replace function public.nuevo_miembro()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.miembros (user_id, email, nombre, rol)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'nombre', ''),
    case when exists (select 1 from public.miembros) then 'pendiente' else 'admin' end
  );
  return new;
end $$;

create trigger al_registrarse
  after insert on auth.users
  for each row execute function public.nuevo_miembro();

-- 6. Seguridad por filas (RLS): quién puede ver y quién puede escribir
alter table public.miembros    enable row level security;
alter table public.config      enable row level security;
alter table public.movimientos enable row level security;

create policy "ver mi fila o todo si soy admin" on public.miembros
  for select to authenticated
  using (user_id = auth.uid() or public.mi_rol() = 'admin');
create policy "admin cambia roles" on public.miembros
  for update to authenticated
  using (public.mi_rol() = 'admin') with check (public.mi_rol() = 'admin');
create policy "admin borra miembros" on public.miembros
  for delete to authenticated
  using (public.mi_rol() = 'admin');

create policy "miembros ven config" on public.config
  for select to authenticated
  using (public.mi_rol() in ('lector','editor','admin'));
create policy "admin cambia config" on public.config
  for update to authenticated
  using (public.mi_rol() = 'admin') with check (public.mi_rol() = 'admin');

create policy "miembros ven movimientos" on public.movimientos
  for select to authenticated
  using (public.mi_rol() in ('lector','editor','admin'));
create policy "editores crean" on public.movimientos
  for insert to authenticated
  with check (public.mi_rol() in ('editor','admin'));
create policy "editores cambian" on public.movimientos
  for update to authenticated
  using (public.mi_rol() in ('editor','admin'))
  with check (public.mi_rol() in ('editor','admin'));
create policy "editores borran" on public.movimientos
  for delete to authenticated
  using (public.mi_rol() in ('editor','admin'));

-- 7. Carpeta privada para las fotos de facturas
insert into storage.buckets (id, name, public)
values ('facturas', 'facturas', false)
on conflict (id) do nothing;

create policy "miembros ven facturas" on storage.objects
  for select to authenticated
  using (bucket_id = 'facturas' and public.mi_rol() in ('lector','editor','admin'));
create policy "editores suben facturas" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'facturas' and public.mi_rol() in ('editor','admin'));
create policy "editores cambian facturas" on storage.objects
  for update to authenticated
  using (bucket_id = 'facturas' and public.mi_rol() in ('editor','admin'));
create policy "editores borran facturas" on storage.objects
  for delete to authenticated
  using (bucket_id = 'facturas' and public.mi_rol() in ('editor','admin'));

-- 8. Cambios en vivo (si alguien registra un gasto, los demás lo ven al momento)
alter publication supabase_realtime add table public.movimientos, public.config;
