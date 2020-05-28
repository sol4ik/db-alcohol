-- 0. database creation
DROP DATABASE IF EXISTS sober_up;
CREATE DATABASE sober_up;

-- 1. tables creation

-- subjects of system: alcoholic and inspector
CREATE TABLE alcoholic(
	alcoholic_id serial PRIMARY KEY,
	name varchar(100) NOT NULL,
	max_drink decimal NOT NULL,
	conscious bool DEFAULT True
);
CREATE TABLE inspector(
	inspector_id serial PRIMARY KEY,
	name varchar(100) NOT NULL
);
-- objects of system: bed, alcohol drinks
CREATE TABLE bed(
	bed_id serial PRIMARY KEY,
	alcoholic_id integer DEFAULT NULL,
	taken bool DEFAULT False
);
CREATE TABLE alcohol(
	alcohol_id serial PRIMARY KEY,
	name varchar(100) NOT NULL
);
--actions involving both alcoholic and inspector
CREATE TABLE migrations(
    migration_id serial PRIMARY KEY,
	bed_from integer, -- NULL if closure
	bed_to integer,  -- NULL if release
	alcoholic_id integer NOT NULL,
	inspector_id integer NOT NULL,
	migration_date date,

    foreign key (bed_from) references bed(bed_id),
    foreign key (bed_to) references bed(bed_id),
	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (inspector_id) references inspector(inspector_id)
);
CREATE TABLE alcoholic_bed(
    bed_id integer NOT NULL,
    alcoholic_id integer NOT NULL,
    date_from timestamp NOT NULL,
    date_to timestamp NOT NULL,

    foreign key (bed_id) references bed(bed_id),
    foreign key (alcoholic_id)references alcoholic(alcoholic_id)
);
-- actions involving only alcoholics
CREATE TABLE escape(
    escape_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	bed_id integer NOT NULL,
	escape_date date NOT NULL,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (bed_id) references bed(bed_id)
);
CREATE TABLE faints(
    faint_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	date_from date NOT NULL,
	date_to date NOT NULL,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id)
);
-- alcoholics' groups and collective drinking
-- the more, the merrier :)
CREATE TABLE group_alcohol(
	group_id serial PRIMARY KEY,
	count_alcoholics integer DEFAULT 1,
	alcohol_id integer NOT NULL,
	amount_drunk integer NOT NULL,
	date_from date NOT NULL,
	date_to date NOT NULL,

	foreign key (alcohol_id) references alcohol(alcohol_id)
);
CREATE TABLE group_alcoholic(
	group_id integer NOT NULL,
	alcoholic_id integer NOT NULL,

	foreign key (group_id) references group_alcohol(group_id),
	foreign key (alcoholic_id) references alcoholic(alcoholic_id)
);


-- 2. indexes

-- In our system only unconscious alcoholic can be taken to sober-up, thus, it is more convenient
-- for the inspectors to look for alcoholics that have recently fainted.
CREATE INDEX recent_faints ON faints(date_from);

-- For better system navigation.
CREATE INDEX recent_enclosions ON migrations(migration_date) WHERE bed_from is NULL;

CREATE INDEX recent_releases ON migrations(migration_date) WHERE bed_to is NULL;

-- In order to enclose alcoholic, inspector needs to put him on a free bed.
-- Thus, we need to look for free beds first.
CREATE INDEX free_bed ON bed(bed_id) WHERE taken = False;

-- The alcoholic with small drinking limit are more likely to faint after drinking
-- and thus inspectors need to look for them first.
CREATE INDEX most_vulnerable_alcoholic ON alcoholic(max_drink ASC);

-- 3. triggers


-- 4. data insertion

-- objects and subjects data
INSERT INTO alcoholic (name, max_drink, conscious) VALUES
('Nigel Terrell', 1.0, True),
('Rylee Sykes', 1.5, False),
('Linda Chen', 0.75, False),
('Ayanna Blanchard',0.6, True),
('Hakeem Donovan', 2.0, True),
('Gay Cochran', 2.1, False),
('Kibo Scott', 3.0, False),
('Ivory Swanson',1.9, True),
('Jolie Singleton',1.75, True),
('Cecilia Gutierrez', 0.5, True),
('Jackson Taylor', 1.2,  False),
('Tucker Vega', 0.75, False),
('Jennifer Vincent', 0.6, True),
('Brynn Sweet', 0.75, True),
('Eleanor Foreman', 1.5, False),
('Wynne Sandoval', 3.0, True),
('Colton Carney', 3.3, True),
('Zahir Barker', 1.25, False),
('Hayley Blackwell', 0.25, True),
('Hilel Strong', 0.33, True),
('Galena Banks', 0.5, False),
('Quinn Brennan', 0.5, False),
('Forrest Mcneil', 0.75, False),
('Wing Clayton', 1.5, False),
('Caesar Villarreal', 1.0, False),
('Fredericka Thomas', 2.0, False),
('Nora Rich', 2.25, True),
('Kameko Joyner', 2.5, True),
('Jescie Prince', 1.75, False),
('Ivor Bell', 3.0, False);

INSERT INTO inspector (name) VALUES
('Ezekiel Chandler'),
('Erich Hopper'),
('Grant Richards'),
('Kuame Craig'),
('Peter West'),
('Felix Byrd'),
('Sebastian Ferguson'),
('Channing Conway'),
('Galvin Davis'),
('Lane Mosley'),
('Damon Ramos'),
('Victor Vazquez'),
('Brandon Bates'),
('Lyle Jenkins'),
('Merrill Herrera'),
('Felix Bentley'),
('Caesar Knowles'),
('Tyrone Holden'),
('Tucker Cleveland'),
('Lev Gregory');


INSERT INTO bed (alcoholic_id, taken) VALUES
(9, True),
(1, True),
(30, True),
(12, True),
(15, True),
(16, True),
(NULL, False),
(NULL, False),
(11, True),
(10, True),
(28, True),
(NULL, False),
(27, True),
(14, True),
(NULL, False),
(16, True),
(NULL, False),
(NULL, False),
(21, True),
(8, True);

INSERT INTO alcohol (name) VALUES
('Vodka'),
('Beer'),
('Wine'),
('Ale'),
('Cognac'),
('Tequila'),
('Champagne'),
('Brandy'),
('Rum'),
('Gin');

--actions and events data
INSERT INTO migrations (bed_from, bed_to, alcoholic_id, inspector_id, migration_date) VALUES
-- closures
(null, 1,  9, 1, '2019-11-20'),
(null, 2, 1, 3, '2020-03-20'),
(null, 3, 30, 2, '2020-11-05'),
(null, 4, 12, 12, '2020-02-10'),
(null, 5, 15, 5, '2020-07-10'),
(null, 6, 16, 6, '2021-03-20'),
(null, 7, 7, 10, '2021-04-10'),
(null, 8, 8, 8, '2021-03-20'),
(null, 9, 11, 9, '2019-12-10'),
(null, 10, 10, 10, '2020-02-10'),
(null, 11, 28, 11, '2020-07-10'),
(null, 12, 12, 4, '2020-08-10'),
(null, 13, 27, 13, '2020-11-10'),
(null, 14, 14, 14, '2021-03-30'),
(null, 15, 15, 15, '2020-05-15'),
(null, 16, 16, 16, '2021-05-18'),
(null, 17, 17, 17, '2020-05-10'),
(null, 18, 6, 18, '2020-12-20'),
(null, 19, 21, 19, '2019-07-20'),
(null, 20, 8, 20, '2020-02-20'),
-- bed migrations
(1, 2, 9, 1, '2019-11-21'),
(2, 1, 1, 3, '2020-03-22'),
(3, 4, 30, 2, '2020-11-07'),
(4, 5, 12, 12, '2020-02-13'),
(5, 3, 15, 5, '2020-07-14'),
(6, 5, 16, 6, '2021-03-22'),
(7, 4, 6, 10, '2021-04-13'),
(8, 1, 8, 8, '2021-03-23'),
(9, 8, 11, 9, '2019-12-14'),
(10, 9, 10, 10, '2020-02-13'),
(11, 10, 28, 11, '2020-07-11'),
(12, 11, 12, 4, '2020-08-12'),
(13, 11, 27, 13, '2020-11-11'),
(14, 13, 14, 14, '2021-03-31'),
(15, 11, 15, 15, '2020-05-19'),
-- releases
(2, null, 9, 1, '2019-11-30'),
(1, null, 1, 3, '2020-03-30'),
(4, null, 30, 2, '2020-11-15'),
(5, null, 12, 12, '2020-02-20'),
(3, null, 15, 5, '2020-07-25'),
(5, null, 16, 6, '2021-03-30'),
(4, null, 6, 10, '2021-04-25'),
(1, null, 8, 8, '2021-03-30'),
(8, null, 11, 9, '2019-12-25'),
(9, null, 10, 10, '2020-02-20'),
(10, null, 28, 11, '2020-07-15'),
(11, null, 12, 4, '2020-08-23'),
(11, null, 27, 13, '2020-11-20'),
(13, null, 14, 14, '2021-04-10'),
(11, null, 15, 15, '2020-05-28'),
(16, null, 16, 16, '2021-05-25'),
(17, null, 17, 17, '2020-05-20'),
(18, null, 6, 18, '2020-12-29'),
(19, null, 21, 19, '2019-07-31'),
(20, null, 8, 20, '2020-02-21');

INSERT INTO alcoholic_bed (bed_id, alcoholic_id, date_from, date_to) VALUES
(1, 9, '2019-11-20', '2019-11-21'),
(2, 1, '2020-03-20', '2020-03-22'),
(3, 30, '2020-11-05', '2020-11-07'),
(4, 12, '2020-02-10', '2020-02-13'),
(5, 15, '2020-07-10', '2020-07-14'),
(6, 16,'2021-03-20', '2021-03-22'),
(7, 7, '2021-04-10', '2021-04-13'),
(8, 8, '2021-03-20', '2021-03-23'),
(9, 11, '2019-12-10', '2019-12-14'),
(10, 10, '2020-02-10', '2020-02-13'),
(11, 28, '2020-07-10', '2020-07-11'),
(12, 12, '2020-08-10', '2020-08-12'),
(13, 27, '2020-11-10', '2020-11-11'),
(14, 14, '2021-03-30', '2021-03-31'),
(15, 15, '2020-05-15', '2020-05-19'),
(16, 16, '2021-05-18', '2021-05-25'),
(17, 17, '2020-05-10', '2020-05-20'),
(18, 6, '2020-12-20', '2020-12-29'),
(19, 21, '2019-07-20', '2019-07-31'),
(20, 8, '2020-02-20', '2020-02-21'),
(2, 9,'2019-11-21', '2019-11-30'),
(1, 1, '2020-03-22', '2020-03-30'),
(4, 30, '2020-11-07', '2020-11-15'),
(5, 12, '2020-02-13', '2020-02-20'),
(3, 15, '2020-07-14', '2020-07-25'),
(5, 16, '2021-03-22', '2021-03-30'),
(4, 6, '2021-04-13', '2021-04-25'),
(1, 8, '2021-03-23', '2021-03-30'),
(8, 11, '2019-12-14', '2019-12-25'),
(9, 10, '2020-02-13', '2020-02-20'),
(10, 28, '2020-07-11', '2020-07-15'),
(11, 12, '2020-08-12', '2020-08-23'),
(11, 27, '2020-11-11', '2020-11-20'),
(13, 14, '2021-03-31', '2021-04-10'),
(11, 15, '2020-05-19', '2020-05-28');

INSERT INTO escape (bed_id, alcoholic_id, escape_date) VALUES
(1, 9, '2019-11-18'),
(2, 1, '2020-03-28'),
(3, 30, '2020-11-08'),
(4, 12, '2020-02-17'),
(5, 15, '2020-07-16'),
(6, 16, '2021-03-25'),
(7, 7, '2021-04-19'),
(8, 8,'2021-03-21'),
(9, 11, '2019-12-18'),
(10, 10, '2020-02-19'),
(11, 28, '2020-07-15'),
(12, 12, '2020-08-17'),
(13, 27, '2020-11-14'),
(14, 14, '2021-04-01'),
(15, 15, '2020-05-20'),
(16, 16, '2021-05-21'),
(17, 17, '2020-05-17'),
(18, 6, '2020-12-22'),
(19, 21, '2019-07-24'),
(20, 8, '2020-02-27');

INSERT INTO faints (alcoholic_id, date_from, date_to) VALUES
(1, '2019-11-04 21:00:30', '2019-11-04 21:59:30'),
(2, '2019-01-04 23:51:52', '2019-01-05 00:02:40'),
(3, '2019-08-30 04:26:25', '2019-08-30 04:36:47'),
(4, '2020-04-13 15:51:01', '2020-04-13 20:15:44'),
(6, '2019-08-20 04:10:43', '2019-08-20 05:47:16'),
(7, '2019-01-09 17:24:11', '2019-01-10 01:12:46'),
(9, '2019-10-30 19:35:41', '2019-10-31 11:42:27'),
(10, '2020-09-28 06:07:29', '2020-09-28 06:43:17'),
(11, '2019-11-02 23:26:59', '2019-11-03 01:33:06'),
(13, '2018-10-01 02:16:48', '2018-10-01 01:21:39'),
(14, '2018-07-18 01:08:58', '2018-07-18 02:20:25'),
(15, '2020-03-08 01:53:24', '2020-03-08 02:55:24'),
(16, '2019-07-07 05:36:12', '2019-07-07 06:06:58'),
(17, '2020-11-10 09:50:20', '2020-11-10 10:13:13'),
(20, '2020-02-16 00:12:19', '2020-08-28 01:13:31'),
(21, '2020-04-06 22:13:25', '2020-04-06 23:09:21'),
(28, '2019-10-15 04:24:41', '2019-10-15 03:57:33'),
(29, '2019-07-07 14:11:10', '2019-07-07 13:22:09'),
(30, '2020-07-26 10:49:45', '2020-07-26 11:59:43');

-- collective drinking data
INSERT INTO group_alcohol (alcohol_id, count_alcoholics, amount_drunk, date_from, date_to) VALUES
(2, 3, 39, '2020-01-01', '2020-01-03'),
(3, 3, 33, '1999-03-08', '2020-03-09 '),
(1, 2, 39, '2010-09-01', '2010-09-10'),
(5, 4, 37, '2020-04-19', '2020-04-20'),
(6, 3, 24, '2020-02-14', '2020-02-14'),
(7, 3, 23, '2019-10-10', '2019-10-13'),
(8, 3, 40, '2018-12-18', '2018-12-25'),
(1, 3, 36, '2019-12-31', '2020-01-02'),
(9, 3, 40, '2020-02-02', '2020-02-02'),
(10, 3, 31, '2017-06-01', '2017-06-04');

INSERT INTO group_alcoholic (group_id,alcoholic_id) VALUES
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 5),
(2, 6),
(3, 7),
(3, 8),
(4, 9),
(4, 10),
(4, 11),
(4, 12),
(5, 13),
(5, 14),
(5, 15),
(6, 16),
(6, 17),
(6, 19),
(7, 18),
(7, 20),
(7, 21),
(8, 22),
(8, 23),
(8, 25),
(9, 24),
(9, 26),
(9, 27),
(10, 29),
(10, 28),
(10, 30);
