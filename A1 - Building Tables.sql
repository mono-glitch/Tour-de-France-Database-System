--
-- Group Number: 22
-- Group Members:
--   1. Moey Sean Jean
--   2. San Wei Rong, Jarren
--   3. Fang Jinfeng
--   4. Toh Jun Yee
--

CREATE TABLE IF NOT EXISTS country (
    ioc_code CHAR(3) PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    region TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS team (
    name TEXT PRIMARY KEY,
    country_code CHAR(3) NOT NULL,
    FOREIGN KEY (country_code)
        REFERENCES country(ioc_code)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS rider (
    bib INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    team_name TEXT NOT NULL,
    country_code CHAR(3),
    FOREIGN KEY (team_name)
        REFERENCES team(name)
        ON UPDATE CASCADE,
    FOREIGN KEY (country_code)
        REFERENCES country(ioc_code)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS location (
    name TEXT PRIMARY KEY,
    country_code CHAR(3) NOT NULL,
    FOREIGN KEY (country_code)
        REFERENCES country(ioc_code)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS stage (
    stage_number INTEGER PRIMARY KEY,
    day DATE NOT NULL UNIQUE,
    start_location TEXT NOT NULL,
    finish_location TEXT NOT NULL,
    length_km NUMERIC NOT NULL CHECK (length_km > 0),
    stage_type TEXT NOT NULL,
    CHECK (stage_type IN (
        'flat',
        'hilly',
        'mountain',
        'individual time-trial',
        'team time-trial'
    )),
    FOREIGN KEY (start_location)
        REFERENCES location(name)
        ON UPDATE CASCADE,
    FOREIGN KEY (finish_location)
        REFERENCES location(name)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS stage_result (
    stage INTEGER NOT NULL,
    bib INTEGER NOT NULL,
    rank INTEGER NOT NULL CHECK (rank >= 1),
    time_seconds NUMERIC NOT NULL CHECK (time_seconds >= 0),
    bonus_seconds NUMERIC NOT NULL DEFAULT 0 CHECK (bonus_seconds >= 0),
    penalty_seconds NUMERIC NOT NULL DEFAULT 0 CHECK (penalty_seconds >= 0),
    PRIMARY KEY (stage, bib),
    FOREIGN KEY (stage)
        REFERENCES stage(stage_number)
        ON UPDATE CASCADE,
    FOREIGN KEY (bib)
        REFERENCES rider(bib)
        ON UPDATE CASCADE,
    UNIQUE (stage, rank)
);

CREATE TABLE IF NOT EXISTS exit_reason (
    reason TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS rider_exit (
    bib INTEGER PRIMARY KEY,
    stage INTEGER NOT NULL,
    reason TEXT NOT NULL,
    FOREIGN KEY (bib)
        REFERENCES rider(bib)
        ON UPDATE CASCADE,
    FOREIGN KEY (stage)
        REFERENCES stage(stage_number)
        ON UPDATE CASCADE,
    FOREIGN KEY (reason)
        REFERENCES exit_reason(reason)
        ON UPDATE CASCADE
);
