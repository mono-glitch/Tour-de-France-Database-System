--
-- Group Number: 22
-- Group Members:
--   1. Moey Sean Jean
--   2. San Wei Rong, Jarren
--   3. Fang Jinfeng
--   4. Toh Jun Yee
--

CREATE OR REPLACE FUNCTION check_rank_gaps_func() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM results
        GROUP BY stage
        HAVING MIN(rank) != 1 OR MAX(rank) != COUNT(*)
    ) THEN
        RAISE EXCEPTION 'Constraint Violated: Ranks for each stage must be consecutive and start at 1.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_rank_gaps ON results;
CREATE CONSTRAINT TRIGGER trigger_check_rank_gaps
AFTER INSERT OR UPDATE ON results
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rank_gaps_func();

CREATE OR REPLACE FUNCTION check_rank_time_func() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM results r1
        JOIN results r2 ON r1.stage = r2.stage
        WHERE r1.rank < r2.rank AND r1.time > r2.time
    ) THEN
        RAISE EXCEPTION 'Constraint Violated: A rider with a better rank cannot have a longer race time.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_rank_time ON results;
CREATE CONSTRAINT TRIGGER trigger_check_rank_time
AFTER INSERT OR UPDATE ON results
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rank_time_func();

CREATE OR REPLACE FUNCTION check_rider_exit_func() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM results r
        JOIN riders_exits e ON r.rider = e.rider
        WHERE r.stage >= e.stage
    ) THEN
        RAISE EXCEPTION 'Constraint Violated: A rider cannot have a race result in or after the stage they exited.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_rider_exit_results ON results;
CREATE CONSTRAINT TRIGGER trigger_check_rider_exit_results
AFTER INSERT OR UPDATE ON results
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rider_exit_func();

DROP TRIGGER IF EXISTS trigger_check_rider_exit_exits ON riders_exits;
CREATE CONSTRAINT TRIGGER trigger_check_rider_exit_exits
AFTER INSERT OR UPDATE ON riders_exits
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rider_exit_func();

CREATE OR REPLACE FUNCTION check_rest_days_func() 
RETURNS TRIGGER AS $$
DECLARE
    max_gap INTEGER;
    total_rest_days INTEGER;
BEGIN
    SELECT COALESCE(MAX(day - prev_day), 1) INTO max_gap
    FROM (
        SELECT day, LAG(day) OVER (ORDER BY day) as prev_day
        FROM stages
    ) s;

    IF max_gap > 2 THEN
        RAISE EXCEPTION 'Constraint Violated: Consecutive rest days are not allowed.';
    END IF;

    SELECT (MAX(day) - MIN(day)) - COUNT(*) + 1 INTO total_rest_days
    FROM stages;

    IF total_rest_days > 2 THEN
        RAISE EXCEPTION 'Constraint Violated: A maximum of two rest days are allowed for the entire competition.';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_rest_days ON stages;
CREATE CONSTRAINT TRIGGER trigger_check_rest_days
AFTER INSERT OR UPDATE ON stages
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rest_days_func();