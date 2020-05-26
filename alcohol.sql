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
CREATE TABLE closure(
    closure_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	inspector_id integer NOT NULL,
	bed_id integer NOT NULL,
	closure_date date,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (inspector_id) references inspector(inspector_id),
    foreign key (bed_id) references bed(bed_id)
);
CREATE TABLE release(
    release_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	inspector_id integer NOT NULL,
	release_date date,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (inspector_id) references inspector(inspector_id)
);
CREATE TABLE migration(
    migration_id serial PRIMARY KEY,
	bed_from integer NOT NULL,
	bed_to integer NOT NULL,
	alcoholic_id integer NOT NULL,
	inspector_id integer NOT NULL,
	migration_date date,

    foreign key (bed_from) references bed(bed_id),
    foreign key (bed_to) references bed(bed_id),
	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (inspector_id) references inspector(inspector_id)
);
-- actions involving only alcoholics
CREATE TABLE escape(
    escape_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	bed_id integer NOT NULL,
	escape_date date,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id),
	foreign key (bed_id) references bed(bed_id)
);
CREATE TABLE faints(
    faint_id serial PRIMARY KEY,
	alcoholic_id integer NOT NULL,
	start_date timestamp NOT NULL,
	end_date timestamp NOT NULL,

	foreign key (alcoholic_id) references alcoholic(alcoholic_id)
);
-- alcoholics' groups and collective drinking
-- the more, the merrier :)
CREATE TABLE group_alcohol(
	group_id serial PRIMARY KEY,
	alcohol_id integer NOT NULL,
	amount_drunk integer NOT NULL,

	foreign key (alcohol_id) references alcohol(alcohol_id)
);
CREATE TABLE group_alcoholic(
	group_id integer NOT NULL,
	alcoholic_id integer NOT NULL,

	foreign key (group_id) references group_alcohol(group_id),
	foreign key (alcoholic_id) references alcoholic(alcoholic_id)
);


-- 2. indices


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
INSERT INTO closure (bed_id, alcoholic_id, inspector_id, closure_date) VALUES
(1, 9, 1, '2019-11-20'),
(2, 1, 3, '2020-03-20'),
(3, 30, 2, '2020-11-05'),
(4, 12, 12, '2020-02-10'),
(5, 15, 5, '2020-07-10'),
(6, 16, 6, '2021-03-20'),
(7, 7, 10, '2021-04-10'),
(8, 8,8, '2021-03-20'),
(9, 11, 9, '2019-12-10'),
(10, 10, 10, '2020-02-10'),
(11, 28, 11, '2020-07-10'),
(12, 12, 4, '2020-08-10'),
(13, 27, 13, '2020-11-10'),
(14, 14, 14, '2021-03-30'),
(15, 15, 15, '2020-05-15'),
(16, 16, 16, '2021-05-18'),
(17, 17, 17, '2020-05-10'),
(18, 6, 18, '2020-12-20'),
(19, 21, 19, '2019-07-20'),
(20, 8, 20, '2020-02-20');

INSERT INTO release (alcoholic_id, inspector_id, release_date) VALUES
(9, 1, '2019-11-30'),
(1, 3, '2020-03-30'),
(30, 2, '2020-11-15'),
(12, 12, '2020-02-20'),
(15, 5, '2020-07-25'),
(16, 6, '2021-03-30'),
(6, 10, '2021-04-25'),
(8, 8, '2021-03-30'),
(11, 9, '2019-12-25'),
(10, 10, '2020-02-20'),
(28, 11, '2020-07-15'),
(12, 4, '2020-08-23'),
(27, 13, '2020-11-20'),
(14, 14, '2021-04-10'),
(15, 15, '2020-05-28'),
(16, 16, '2021-05-25'),
(17, 17, '2020-05-20'),
(6, 18, '2020-12-29'),
(21, 19, '2019-07-31'),
(8, 20, '2020-02-21');

INSERT INTO migration (bed_from, bed_to,alcoholic_id,inspector_id, migration_date) VALUES
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
(15, 11, 15, 15, '2020-05-19');

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

INSERT INTO faints (alcoholic_id, start_date, end_date) VALUES
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
INSERT INTO group_alcohol (alcohol_id, amount_drunk) VALUES
(2, 39),
(3, 33),
(1, 39),
(5, 37),
(6, 24),
(7, 23),
(8, 40),
(1, 36),
(9, 40),
(10, 31);

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
