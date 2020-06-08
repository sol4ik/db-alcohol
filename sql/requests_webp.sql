-- ALCOHOLIC’s POINT OF VIEW:

--   FUNCTIONS:

-- 1) Invite friends to drink (create a group of alcoholics and choose a drink)
-- input: [] alcoholic_ids, alco_id

new_group_id = SELECT MAX(group_id) FROM group_alcoholic

for alcoholic_id in alcoholic_ids:
	INSERT INTO group_alcoholic (group_id,alcoholic_id) VALUES
	(new_group_id, alcoholic_id)

INSERT INTO group_alcohol (group_id, count_alcoholics, alcohol_id, amount_drunk, date_from, date_to) VALUES
(new_group_id, len(alcoholic_ids), alco_id, 0, NOW()::date, null)

-- 2) Drink ((for a whole group) add amount of drink to an *amount_drunk and check if not max? сontinue: -- mark *conscious False
-- input: input_group_id

faint_ids =
SELECT * FROM group_alcohol
INNER JOIN group_alcohol USING (group_id)
INNER JOIN alcoholic USING (alcoholic_id)
WHERE group_alcoholic.group_id = 3 AND group_alcohol.amount_drunk / group_alcohol.count_alcoholics > max_drink

UPDATE group_alcohol
SET amount_drunk = 0
WHERE group_id = 3

for id in faint_ids:
	INSERT INTO faints VALUES 
	(id, NOW()::date, null)

UPDATE alcohlic
SET coscious = false
WHERE alcoholic_id = -- "one of alcoholic_ids"

-- 3) Join a company (add id to group_alcoholics)
-- input: gr_id, al_id

INSERT INTO group_alcoholic VALUES
(gr_id, al_id)

UPDATE group_alcohol
SET count_alcoholics = count_alcoholics + 1
WHERE group_id = gr_id

-- 4) Escape
-- option is added when alcoholic is closed and removed when he/she is released
-- input: al_id

b_id = 
SELECT bed_id FROM migrations
WHERE alcoholic_id = al_id
ORDER BY migration_date
LIMIT 1;

SELECT * FROM escape
INSERT INTO escape VALUES 
(al_id, b_id, NOW()::date)

UPDATE alcoholic
SET enclosed = false
WHERE alcoholic_id = al_id

--   VISUAL:
-- 1) The most friendly (the one in the biggest number of groups)
-- check every time one joins the company

SELECT alcoholic_id FROM group_alcoholic
GROUP BY group_alcoholic.alcoholic_id
ORDER BY COUNT(DISTINCT group_id) DESC LIMIT 1;

-- 2) The quickest (the one who escaped the biggest number of times)
-- check every time one escapes

SELECT alcoholic_id FROM escape
GROUP BY escape.alcoholic_id
ORDER BY COUNT(DISTINCT escape_id) DESC LIMIT 1;

-- 3) Inspectors’ favourite (the one who was released the biggest n of times)
-- check -- every time one is released

SELECT alcoholic_id FROM migrations
WHERE bed_from IS NULL
GROUP BY migrations.alcoholic_id
ORDER BY COUNT(DISTINCT migration_id) DESC 
LIMIT 1;

-- 4) Inspectors’ disfavorite (the one who was closed the biggest n of times (check -- every time one is closed))

SELECT alcoholic_id FROM migrations
WHERE bed_to IS NULL
GROUP BY migrations.alcoholic_id
ORDER BY COUNT(DISTINCT migration_id) DESC 
LIMIT 1;

-- 5) Drinking master (the one who drank the most (check every time one takes one 
-- more portion of alcohol))
-- don't have this column in a table



-- 6) Drinking amateur (the one who have lost consciousness the bigger n of times 
-- check every time alcoholics drink
-- don't have this column in a table


-- 7) Lost consciousness (marked the time one lost consciousness)
-- needed????????????????????????????????????????????

SELECT alcoholic_id FROM alcoholic
WHERE coscious = false

-- INSPECTOR’s POINT OF VIEW:
--   FUNCTIONS:
-- 1) Enclose an alcoholic
-- option is added when alcoholic loses consciousness
-- input: insp_id, al_id, b_id

UPDATE alcoholic
SET enclosed = true
WHERE alcoholic_id = al_id

INSERT INTO migrations VALUES
(null, b_id, al_id, insp_id, NOW()::date)

-- 2) Release an alcoholic (alcoholic is enclosed? release (change migration 
-- option is added when alcoholic is enclosed
-- option is deleted when alcoholic escaped or got released
-- input: insp_id, al_id

b_id = 
SELECT bed_id FROM migrations
WHERE alcoholic_id = al_id
ORDER BY migration_date DESC
LIMIT 1

UPDATE alcoholic
SET enclosed = false
WHERE alcoholic_id = al_id

INSERT INTO migrations VALUES
(b_id, null, al_id, insp_id, NOW()::date)

-- 3) Move an alcoholic from one bed to another
-- option is added when alcoholic is closed
-- input: al_id, new_bed_id

prev_b_id = 
SELECT bed_id FROM migrations
WHERE alcoholic_id = al_id
ORDER BY migration_date DESC
LIMIT 1

INSERT INTO migrations VALUES
(prev_b_id, new_b_id, al_id, insp_id, NOW()::date)

--   VISUAL:
-- 1) Favourite (the one whom inspector released the biggest n of times)
-- check every time inspector releases someone
-- input: insp_id

SELECT alcoholic_id FROM migrations
WHERE inspector_id = insp_id AND bed_from IS NULL 
GROUP BY migrations.alcoholic_id
ORDER BY COUNT(DISTINCT migration_id) DESC 
LIMIT 1;

-- 2) Disfavorite (the one who was closed the biggest n of times)
-- check every time inspector encloses someone
-- input: insp_id

SELECT alcoholic_id FROM migrations
WHERE inspector_id = insp_id AND bed_to IS NULL
GROUP BY migrations.alcoholic_id
ORDER BY COUNT(DISTINCT migration_id) DESC 
LIMIT 1;

-- 3) Faint 
-- needed????????????????????????????????????????????

SELECT alcoholic_id FROM alcoholic
WHERE coscious = false

-- 4) Closed 
-- make request every time escapes/is closed/released 
-- needed????????????????????????????????????????????

SELECT alcoholic_id FROM alcoholic
WHERE enclosed = true

-- 5) Bed
-- every time one escapes/is closed/released/moved from one bed to another

SELECT alcoholic_id, bed_id FROM alcoholic_bed
WHERE date_to = NULL

