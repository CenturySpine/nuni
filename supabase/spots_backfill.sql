-- One-shot takeover of the places typed before plan 28 (Q185), run once after the reconstruction
-- that creates the spots table (docs/DEV.md, step 6b), then never again: from then on the spots
-- live in the data seed like any other row. Without effect when replayed (no name is created
-- twice, nothing already linked is touched).
--
-- Every distinct place of an association (events' places, sessions' zones, ignoring case and
-- surrounding spaces) becomes a spot: all of them are playing spots (PO, 2026-09-25). The PO's
-- review renamed a few and merged two (the mapping below): the old text, when it was an address,
-- becomes the spot's address. The point is the most recent event point (placed on purpose), else
-- the most recent session point (where its creator stood), else none ("to complete"); a spot
-- marked variable in the mapping (Q186, "Surprise") has neither point nor address. The city is
-- the mapping's, else the most recent session city, so the sessions' city doesn't change. Then
-- every session and event with one of the names is linked to its spot (the triggers of
-- triggers.sql copy the spot's name and city back).
begin;

create temporary table spot_mapping (
  old_name text, new_name text, address text, city text, variable boolean
) on commit drop;
insert into spot_mapping values
  ('Campus de la Doua, Campus de, 69100 Villeurbanne, France', 'INSA',
   'Campus de la Doua, Campus de, 69100 Villeurbanne, France', null, false),
  ('INSA', 'INSA', 'Campus de la Doua, Campus de, 69100 Villeurbanne, France', null, false),
  ('Hôpital de la Croix-Rousse - HCL, 103 Gd Rue de la Croix-Rousse, 69004 Lyon, France',
   'Croix-Rousse',
   'Hôpital de la Croix-Rousse - HCL, 103 Gd Rue de la Croix-Rousse, 69004 Lyon, France', 'Lyon',
   false),
  ('DOCKS 40, 40 Quai Rambaud, 69002 Lyon, France', 'Confluence',
   'DOCKS 40, 40 Quai Rambaud, 69002 Lyon, France', 'Lyon', false),
  ('Surprise', 'Surprise', null, null, true);

create temporary table spot_used on commit drop as
select u.association_id, coalesce(m.new_name, u.name) as name, u.name as old_name,
       m.address, coalesce(m.city, u.city) as city, u.location, u.source_rank, u.used_at,
       coalesce(m.variable, false) as variable
from (
  select association_id, btrim(spot) as name, location, null::text as city,
         1 as source_rank, updated_at as used_at
  from events
  where spot is not null and btrim(spot) <> ''
  union all
  select association_id, btrim(zone), location, city, 2, coalesce(started_at, created_at)
  from sessions
  where zone is not null and btrim(zone) <> ''
) u
left join spot_mapping m on lower(m.old_name) = lower(u.name);

insert into spots (association_id, name, address, city, location, variable_location)
select
  association_id,
  left((array_agg(name order by used_at desc))[1], 80),
  case when not bool_or(variable) then
    (array_agg(address) filter (where address is not null))[1]
  end,
  case when not bool_or(variable) then
    (array_agg(city order by used_at desc) filter (where city is not null))[1]
  end,
  case when not bool_or(variable) then
    (array_agg(location order by source_rank, used_at desc)
       filter (where location is not null))[1]
  end,
  bool_or(variable)
from spot_used
group by association_id, lower(name)
on conflict do nothing;

update sessions se set spot_id = sp.id
from spot_used u
join spots sp on sp.association_id = u.association_id and lower(sp.name) = lower(left(u.name, 80))
where se.spot_id is null
  and se.association_id = u.association_id
  and lower(btrim(se.zone)) = lower(u.old_name);

update events ev set spot_id = sp.id
from spot_used u
join spots sp on sp.association_id = u.association_id and lower(sp.name) = lower(left(u.name, 80))
where ev.spot_id is null
  and ev.association_id = u.association_id
  and lower(btrim(ev.spot)) = lower(u.old_name);

commit;
