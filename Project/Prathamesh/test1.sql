-- cron for shifts

CREATE OR REPLACE PROCEDURE test1_makestudentaresident (
    studuentid NUMBER,
    dormname   VARCHAR,
    from_date  DATE,
    to_date    DATE
) IS

    temp_dummy_dorm_capacity    NUMBER;
    temp_original_dorm_capacity NUMBER;
    temp_is_dorm_available      NUMBER;
    temp_dorm_id                NUMBER;

    PROCEDURE nested_block (
        dcapacity NUMBER,
        did       NUMBER
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        UPDATE dorm
        SET
            dorm_capacity = dcapacity
        WHERE
            dorm_id = did;

        COMMIT;
    END;

BEGIN
    SELECT
        dorm_id
    INTO temp_dorm_id
    FROM
        dorm
    WHERE
        lower(dorm_name) = lower(dormname);

    SELECT
        dorm_capacity
    INTO temp_original_dorm_capacity
    FROM
        dorm
    WHERE
        lower(dorm_name) = lower(dormname);

    UPDATE dorm
    SET
        dorm_capacity = 0
    WHERE
        dorm_id = temp_dorm_id;

    SELECT
        dorm_capacity
    INTO temp_dummy_dorm_capacity
    FROM
        dorm
    WHERE
        dorm_id = temp_dorm_id;

    temp_is_dorm_available := f_check_dorm_availability(temp_dorm_id, from_date, to_date);
    dbms_output.put_line('Initial Capacity ' || temp_dummy_dorm_capacity);
    dbms_output.put_line('Original Capacity ' || temp_original_dorm_capacity);
    IF ( temp_is_dorm_available = 0 ) THEN
        -- p_makestudentaresident(studuentid, dormname, from_date, to_date);
        COMMIT; -- or else deadlock
        nested_block(temp_original_dorm_capacity, temp_dorm_id);
        ROLLBACK;
        dbms_output.put_line('Does not exists!');
    END IF;

END;
/

EXEC test1_makestudentaresident(229, 'Willis Hall', '12-Nov-2021', '03-Aug-2030');

SELECT
    *
FROM
    dorm
WHERE
    dorm_name = 'Willis Hall';

-- studentId, dormname, form, to