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

SELECT inspector_id FROM migrations
WHERE bed_to IS NOT NULL
  AND bed_from IS NULL
  AND migration_date > F
  AND migration_date < T
GROUP BY inspector_id, alcoholic_id
HAVING COUNT(inspector_id) >= N
  AND alcoholic_id = A

-- 3) для iнспектора I знайти усiх алкоголiкiв, яких вiн забирав хоча б N разiв за вказаний перiод
-- (з дати F по дату T);

SELECT alcoholic_id FROM migrations
WHERE bed_to IS NOT NULL
  AND bed_from IS NULL
  AND migration_date > F
  AND migration_date < T
GROUP BY alcoholic_id, inspector_id
HAVING COUNT(alcoholic_id) >= N
  AND inspector_id = I

-- 5) для алкоголiка A знайти усiх iнспекторiв, якi забирали його меншу кiлькiсть разiв нiж
-- випускали;

SELECT alcoholic_id, COUNT(bed_to) AS closure_count, COUNT(*) - COUNT(bed_to) as release_count
FROM migrations 
WHERE bed_from IS NULL OR bed_to IS NULL
GROUP BY migrations.alcoholic_id

-- 7) знайти усiх алкоголiкiв, яких забирали у витверезник хоча б N разiв за вказаний перiод (з
-- дати F по дату T);

SELECT alcoholic_id FROM migrations
WHERE bed_to IS NOT NULL
  AND bed_from IS NULL
  AND migration_date > F
  AND migration_date < T
GROUP BY alcoholic_id
HAVING COUNT(migration_id) >= N

-- 9) для алкоголiка A та кожного спиртого напою, що вiн вживав, знайти скiльки разiв за вказаний 
-- перiод (з дати F по дату T) вiн розпивав напiй у групi з щонайменше N алкоголiкiв;

SELECT alcoholic_id, alcohol_id, COUNT(DISTINCT alcohol_id)
FROM group_alcoholic
INNER JOIN group_alcohol USING (group_id)
WHERE group_alcohol.count_alcoholics >= N
GROUP BY group_alcoholic.alcoholic_id, group_alcohol.alcohol_id

-- 11) вивести лiжка витверезника у порядку спадання середньої кiлькостi втрат свiдомостi для
-- усiх алкоголiкiв, що були приведенi на лiжко iнспектором I за вказаний перiод (з дати F по
-- дату T);

SELECT bed_to AS bed_id FROM migrations m
INNER JOIN faints USING (alcoholic_id)
WHERE m.bed_to IS NOT NULL
  AND m.bed_from IS NULL
  AND m.inspector_id = I
GROUP BY m.bed_to
ORDER BY COUNT(DISTINCT faint_id) DESC
