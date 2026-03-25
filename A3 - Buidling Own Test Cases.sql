--
-- Group Number: 22
-- Group Members:
--   1. Moey Sean Jean
--   2. San Wei Rong, Jarren
--   3. Fang Jinfeng
--   4. Toh Jun Yee
--

INSERT INTO countries (code, name, region) VALUES 
    ('FRA', 'France', 'Europe'), 
    ('GER', 'Germany', 'Europe'),
    ('ITA', 'Italy', 'Europe');
INSERT INTO teams (name, country) VALUES 
    ('Bora', 'GER'), 
    ('Lotto', 'FRA');
INSERT INTO riders (bib, name, dob, team) VALUES 
    (101, 'Rider One', '1995-01-01', 'Bora'), 
    (102, 'Rider Two', '1996-02-02', 'Lotto'),
    (103, 'Rider Three', '1997-03-03', 'Bora');
INSERT INTO locations (name, country) VALUES 
    ('Paris', 'FRA'), 
    ('Lyon', 'FRA'), 
    ('Nice', 'FRA'),
    ('Marseille', 'FRA');


-- Constraint 1 & 2

-- SUCCESS
BEGIN;
INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (1, '2025-07-01', 'Paris', 'Lyon', 150, 'flat');
INSERT INTO results (rider, stage, rank, time) VALUES 
    (101, 1, 1, 3600),
    (102, 1, 2, 3700),
    (103, 1, 3, 3800);
COMMIT; 

INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (2, '2025-07-02', 'Lyon', 'Nice', 160, 'mountain');

-- FAILURE
BEGIN;
INSERT INTO results (rider, stage, rank, time) VALUES 
    (101, 2, 1, 4000),
    (102, 2, 3, 4100);
COMMIT;
ROLLBACK;

-- FAILURE
BEGIN;
INSERT INTO results (rider, stage, rank, time) VALUES 
    (101, 2, 2, 4000),
    (102, 2, 3, 4100);
COMMIT;
ROLLBACK;

-- FAILURE
BEGIN;
INSERT INTO results (rider, stage, rank, time) VALUES 
    (101, 2, 1, 4500), 
    (102, 2, 2, 4000); 
COMMIT;
ROLLBACK;

-- Constraint 3

INSERT INTO stages (num, day, start, finish, length, type) VALUES
    (3, '2025-07-03', 'Nice', 'Marseille', 120, 'hilly'),
	(4, '2025-07-04', 'Marseille', 'Paris', 200, 'flat');

-- SUCCESS
BEGIN;
INSERT INTO riders_exits (rider, stage, reason) 
    VALUES (103, 3, 'withdrawal');
COMMIT; 

-- FAILURE
BEGIN;
INSERT INTO results (rider, stage, rank, time) VALUES 
    (103, 3, 1, 3000);
COMMIT;
ROLLBACK;

-- FAILURE
BEGIN;
INSERT INTO results (rider, stage, rank, time) VALUES 
	(103, 4, 1, 3000);
COMMIT;
ROLLBACK;


-- Constraint 4 & 5

-- SUCCESS
BEGIN;
INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (5, '2025-07-06', 'Marseille', 'Paris', 200, 'flat');
COMMIT;

-- FAILURE
BEGIN;
INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (6, '2025-07-09', 'Paris', 'Lyon', 100, 'flat');
COMMIT;
ROLLBACK;

-- FAILURE
BEGIN;
INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (6, '2025-07-08', 'Paris', 'Lyon', 100, 'flat');
INSERT INTO stages (num, day, start, finish, length, type) 
    VALUES (7, '2025-07-10', 'Marseille', 'Nice', 150, 'flat');
COMMIT;
ROLLBACK;
