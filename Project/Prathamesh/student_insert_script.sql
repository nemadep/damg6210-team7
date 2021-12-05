-- TODO:- Dorm dates validations pending

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
    INTO dorm_capacity
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

CREATE OR REPLACE PROCEDURE p_makestudentaresident (
    studuentid NUMBER,
    dormname   VARCHAR,
    from_date  DATE,
    to_date    DATE
) IS

    is_available           NUMBER;
    temp_dorm_id           NUMBER;
    temp_is_dorm_available NUMBER;
    is_already_resident    CHAR(5);
    e_dorm_valid EXCEPTION;
    already_resident EXCEPTION;
BEGIN
    SELECT
        is_resident
    INTO is_already_resident
    FROM
        student
    WHERE
        student_id = studuentid;

    IF is_already_resident = 'TRUE' THEN
        RAISE already_resident;
    END IF;
    SELECT
        COUNT(*)
    INTO is_available
    FROM
        dorm
    WHERE
        lower(dorm_name) = lower(dormname);

    IF is_available > 0 THEN
        SELECT
            dorm_id
        INTO temp_dorm_id
        FROM
            dorm
        WHERE
            lower(dorm_name) = lower(dormname);

        temp_is_dorm_available := f_check_dorm_availability(temp_dorm_id, from_date, to_date);
        IF temp_is_dorm_available = 1 THEN
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
            dbms_output.put_line('Dorm not available!');
        END IF;

    ELSE
        RAISE e_dorm_valid;
    END IF;

EXCEPTION
    WHEN e_dorm_valid THEN
        dbms_output.put_line('Invalid dorm!');
    WHEN already_resident THEN
        dbms_output.put_line('Already a resident!');
END;
/

CREATE OR REPLACE TRIGGER t_update_resident_status AFTER
    INSERT ON resident
    FOR EACH ROW
BEGIN
    UPDATE student
    SET
        is_resident = 'TRUE'
    WHERE
        student_id = :new.student_id;

END;
/

-- Example:
SET SERVEROUTPUT ON;

EXEC p_makestudentaresident(224, 'White Hall', '12-Mar-2021', '30-Aug-2025');
EXEC p_makestudentaresident(225, 'Hastings Hall', '02-Jun-2021', '03-Aug-2027');
EXEC p_makestudentaresident(226, 'Meserve Hall', '12-Mar-2021', '01-Jan-2023');
EXEC p_makestudentaresident(227, 'Northeastern University Smith Hall', '14-Feb-2023', '14-Aug-2024');
EXEC p_makestudentaresident(228, 'Hurtig Hall', '18-Dec-2021', '05-Sep-2029');
EXEC p_makestudentaresident(229, 'Willis Hall', '12-Nov-2021', '03-Aug-2030');

SELECT
    *
FROM
    student;

SELECT
    *
FROM
    resident;

SELECT
    *
FROM
    dorm;

TRUNCATE TABLE resident;