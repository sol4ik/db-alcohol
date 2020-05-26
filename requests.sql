/*      2) Для алкоголiка A знайти усi лiжка витверезника, де вiн побував за вказаний перiод (з дати F по дату T); */
select bed_id
from (select bed_from as bed_id, migration_date
      from migration
      where alcoholic_id = 10 /* Cecilia Gutierrez */
      union all
      select bed_to as bed_id, migration_date
      from migration
      where alcoholic_id = 10) as res
where migration_date > '2019-11-21'
  and migration_date < '2020-11-21';
/*     4) для алкоголiка A знайти усi лiжка у витверезнику, з яких вiн тiкав за вказаний перiод 
       (з дати F по дату T); */
select bed_id
from escape
where alcoholic_id = 10
  and escape_date > '2017-11-21'
  and escape_date < '2022-11-21';

/*     6) знайти усiх iнспекторiв, якi забирали щонайменше N рiзних алкоголiкiв за вказаний перiод 
       (з дати F по дату T); */
select inspector_id
from closure
where closure_date > '2017-11-21'
  and closure_date < '2022-11-21'
group by inspector_id
having Count(Distinct alcoholic_id) > 1;
/*     8) знайти усi спiльнi подiї для алкоголiка A та iнспектора I за вказаний перiод (з дати F по дату T);*/
select closure_date as event_date, 'Closure event' as event_name
from closure
where closure_date > '2017-11-21'
  and closure_date < '2022-11-21'
  and inspector_id = 10
  and alcoholic_id = 10
union all
select migration_date as event_date, 'Migration event' as event_name
from migration
where migration_date > '2017-11-21'
  and migration_date < '2022-11-21'
  and inspector_id = 10
  and alcoholic_id = 10
union all
select release_date as event_date, 'Release event' as event_name
from release
where release_date > '2017-11-21'
  and release_date < '2022-11-21'
  and inspector_id = 10
  and alcoholic_id = 10;

/*     10) знайти сумарну кiлькiсть втеч з витверезника по мiсяцях; (за всі роки??)*/
select to_char(escape_date, 'MM') as "Months", count(bed_id)
from escape
group by to_char(escape_date, 'MM')
order by "Months";

/*     12) Вивести алкогольнi напої у порядку спадання сумарної кiлькостi алкоголiкiв, що його розпивала разом з алкоголiком A за вказаний перiод (з дати F по дату T); */
/* Працює не докінця правильно*/
select name, count(alcoholic_id) as "participants"
from alcohol
         inner join group_alcohol ga on alcohol.alcohol_id = ga.alcohol_id
         inner join group_alcoholic g on ga.group_id = g.group_id
-- where g.alcoholic_id in (
--     select g.alcoholic_id
--     from group_alcoholic
--     where g.alcoholic_id = 10
-- )
group by alcohol.name
order by "participants";

-- для алкоголiка A знайти усiх iнспекторiв, якi забирали його у витверезник принаймнi N
-- разiв за вказаний перiод (з дати F по дату T);
	
SELECT i.name AS inspector
FROM inspector i
INNER JOIN closure c ON (i.inspector_id = c.inspector_id)
INNER JOIN alcoholic a ON (c.alcoholic_id = a.alcoholic_id)
WHERE c.closure_date > F
    AND c.closure_date < T
GROUP BY i.inspector_id, a.name
HAVING COUNT(c.inspector_id) >= N
    AND a.name = A

-- для iнспектора I знайти усiх алкоголiкiв, яких вiн забирав хоча б N разiв за вказаний перiод
-- (з дати F по дату T);

SELECT a.name AS alcoholic
FROM alcoholic a
INNER JOIN closure c ON (i.alcoholic_id = c.alcoholic_id)
INNER JOIN inspector a ON (c.inspector_id = a.inspector_id)
WHERE c.closure_date > F
    AND c.closure_date < T
GROUP BY a.alcoholic_id, i.name
HAVING COUNT(c.alcoholic_id) >= N
    AND i.name = I

-- для алкоголiка A знайти усiх iнспекторiв, якi забирали його меншу кiлькiсть разiв нiж
-- випускали;

SELECT inspector.name AS inspector
FROM inspector
INNER JOIN release USING (inspector_id)
INNER JOIN closure USING (alcoholic_id)
WHERE alcoholic_id = A
GROUP BY inspector.inspector_id
HAVING COUNT(DISTINCT release_id) > COUNT(DISTINCT closure_id)

-- знайти усiх алкоголiкiв, яких забирали у витверезник хоча б N разiв за вказаний перiод (з
-- дати F по дату T);

SELECT a.name
FROM alcoholic a
INNER JOIN closure c ON (a.alcoholic_id = c.alcoholic_id)
WHERE c.closure_date > F
    AND c.closure_date < T
GROUP BY c.alcoholic_id, a.name
HAVING COUNT(c.alcoholic_id) >= N

-- для алкоголiка A та кожного спиртого напою, що вiн вживав, знайти скiльки разiв за вказаний 
-- перiод (з дати F по дату T) вiн розпивав напiй у групi з щонайменше N алкоголiкiв;
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- SELECT alcohol.name, COUNT() 
-- FROM alcohol
-- INNER JOIN group_alcohol USING alcohol_id
-- INNER JOIN group_alcoholic USING alcoholic_id
-- WHERE date > '2005-07-07'
--     AND date < '2100-07-07'
-- GROUP BY 
