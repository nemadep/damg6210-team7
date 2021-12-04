CREATE OR REPLACE PROCEDURE p_makestudentaresident (
    studuentid NUMBER,
    dormname   VARCHAR,
    from_date  DATE,
    to_date    DATE
) IS
    is_available      NUMBER;
    temp_dorm_id      NUMBER;
    is_dorm_available NUMBER;
    e_dorm_valid EXCEPTION;
BEGIN
    SELECT
        COUNT(*)
    INTO is_available
    FROM
        dorm
    WHERE
        lower(name) = lower(dormname);

    IF is_available = 1 THEN
        --check availability-check availability-check availability-check availability
        SELECT
            dorm_id
        INTO temp_dorm_id
        FROM
            dorm
        WHERE
            lower(name) = lower(dormname);

        is_dorm_available(temp_dorm_id, from_date, to_date);
        INSERT INTO resident (
            dorm_id,
            student_id,
            to_date,
            from_date
        ) VALUES (
            temp_dorm_id,
            studuentid,
            to_date,
            from_date
        );

    ELSE
        RAISE e_dorm_valid;
    END IF;

EXCEPTION
    WHEN dorm_valid THEN
        dbms_output.put_line('Invalid dorm!');
END;
/




CREATE OR REPLACE FUNCTION f_check_dorm_availability (
    dormid   IN NUMBER,
    fromdate IN DATE,
    todate   IN DATE
) RETURN NUMBER IS
    dorm_capacity       NUMBER;
    total_dorm_consumed NUMBER;
    is_available        NUMBER(1) := 0;
BEGIN
    SELECT
        dorm_capacity
    INTO dorm_availability
    FROM
        dorm
    WHERE
        dorm_id = dormid;

    SELECT
        COUNT(*)
    INTO total_dorm_consumed
    FROM
        resident
    WHERE
            dorm_id = dormid
        AND from_date >= fromdate
        AND to_date <= todate;

    IF dorm_capacity > total_dorm_consumed THEN
        is_available := 1;
    END IF;
    RETURN is_available;
END f_check_dorm_availability;
/