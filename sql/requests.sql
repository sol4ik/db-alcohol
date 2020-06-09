/*      2) Для алкоголiка A знайти усi лiжка витверезника, де вiн побував за вказаний перiод (з дати F по дату T); */
select bed_id, date_from, date_to
from alcoholic_bed
where ((date_from < '2017-11-21' and date_to > '2017-11-21')
    or (date_from > '2017-11-21' and date_from < '2020-11-21'))
  and alcoholic_id = 10;
/*     4) для алкоголiка A знайти усi лiжка у витверезнику, з яких вiн тiкав за вказаний перiод 
       (з дати F по дату T); */
select bed_id, escape_date
from escape
where alcoholic_id = 10
  and escape_date > '2017-11-21'
  and escape_date < '2022-11-21';

/*     6) знайти усiх iнспекторiв, якi забирали щонайменше N рiзних алкоголiкiв за вказаний перiод 
       (з дати F по дату T); */

select inspector_id
from migrations
where migration_date > '2017-11-21'
  and migration_date < '2022-11-21'
  and bed_from is null
group by inspector_id
having Count(Distinct alcoholic_id) > 0;
/*     8) знайти усi спiльнi подiї для алкоголiка A та iнспектора I за вказаний перiод (з дати F по дату T);*/
select migration_date                                                              as event_date,
       (case
            when bed_from is null then 'Closure event'
            when bed_from is not null and bed_to is not null then 'Migration event'
            when bed_from is not null and bed_to is null then 'Release event' end) as event_name
from migrations
where migration_date > '2017-11-21'
  and migration_date < '2022-11-21'
  and inspector_id = 10
  and alcoholic_id = 10;

/*     10) знайти сумарну кiлькiсть втеч з витверезника по мiсяцях; (за всі роки??)*/
select to_char(escape_date, 'MM') as "Months", count(bed_id)
from escape
group by to_char(escape_date, 'MM')
order by "Months";

/*     12) Вивести алкогольнi напої у порядку спадання сумарної кiлькостi алкоголiкiв, що його розпивала разом з алкоголiком A за вказаний перiод (з дати F по дату T); */
/* Працює не докінця правильно*/

select *
from group_alcoholic;
select *
from group_alcohol;
select alcohol.name, count_alcoholics
from alcohol
         inner join group_alcohol ga on alcohol.alcohol_id = ga.alcohol_id
         inner join (select * from group_alcoholic inner join alcoholic a on group_alcoholic.alcoholic_id = a.alcoholic_id where name =) g on ga.group_id = g.group_id

--          inner join (select * from group_alcoholic where a.name = 10) g on ga.group_id = g.group_id
group by alcohol.name, count_alcoholics
 order by count_alcoholics desc;
-- 1) для алкоголiка A знайти усiх iнспекторiв, якi забирали його у витверезник принаймнi N
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

-- 3) для iнспектора I знайти усiх алкоголiкiв, яких вiн забирав хоча б N разiв за вказаний перiод
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

-- 5) для алкоголiка A знайти усiх iнспекторiв, якi забирали його меншу кiлькiсть разiв нiж
-- випускали;

SELECT inspector.name AS inspector
FROM inspector
         INNER JOIN release USING (inspector_id)
         INNER JOIN closure USING (alcoholic_id)
WHERE alcoholic_id = A
GROUP BY inspector.inspector_id
HAVING COUNT(DISTINCT release_id) > COUNT(DISTINCT closure_id)

-- 7) знайти усiх алкоголiкiв, яких забирали у витверезник хоча б N разiв за вказаний перiод (з
-- дати F по дату T);

SELECT a.name
FROM alcoholic a
         INNER JOIN closure c ON (a.alcoholic_id = c.alcoholic_id)
WHERE c.closure_date > F
  AND c.closure_date < T
GROUP BY c.alcoholic_id, a.name
HAVING COUNT(c.alcoholic_id) >= N

-- 9) для алкоголiка A та кожного спиртого напою, що вiн вживав, знайти скiльки разiв за вказаний
-- перiод (з дати F по дату T) вiн розпивав напiй у групi з щонайменше N алкоголiкiв;
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- SELECT alcohol.name, COUNT() 
-- FROM alcohol
-- INNER JOIN group_alcohol USING alcohol_id
-- INNER JOIN group_alcoholic USING alcoholic_id
-- WHERE date > '2005-07-07'
--     AND date < '2100-07-07'
-- GROUP BY 
