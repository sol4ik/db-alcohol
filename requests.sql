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