SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION get_available_dorm (
    dormid NUMBER,
    todate DATE
) RETURN NUMBER AS
    dorm_occupancy NUMBER := 0;
    dorm_available NUMBER := 0;
    is_available   NUMBER := 1;
BEGIN
    SELECT
        dorm_capacity
    INTO dorm_available
    FROM
        dorm
    WHERE
        dorm_id = dormid;

    SELECT
        COUNT(*)
    INTO dorm_occupancy
    FROM
        resident
    WHERE
            dorm_id = dormid
        AND to_date >= todate;

    IF ( dorm_occupancy >= dorm_available ) THEN
        dbms_output.put_line('Dorm is fully occupied');
        is_available := 0;
    ELSE
        dbms_output.put_line('Dorm is available');
    END IF;

    RETURN is_available;
END;
/

BEGIN
    dbms_output.put_line('***************************');
    DECLARE
        already_exists EXCEPTION;
        PRAGMA exception_init ( already_exists, -2001 );
    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX dorm_availablity ON
        resident (
            dorm_id,
            to_date
        )';
        dbms_output.put_line('INDEX - dorm_availablity created!');
    EXCEPTION
        WHEN already_exists THEN
            dbms_output.put_line('WARN - Index Already Exists');
            dbms_output.put_line(sqlerrm);
        WHEN OTHERS THEN
            dbms_output.put_line('FAIL - Already Exists!');
            dbms_output.put_line(sqlerrm);
    END;

    DECLARE
        already_exists EXCEPTION;
        PRAGMA exception_init ( already_exists, -2001 );
    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX indx_swipe_logs_dorm_id ON
        swipe_log (
            dorm_id
        )';
        dbms_output.put_line('INDEX - indx_swipe_logs_dorm_id created!');
    EXCEPTION
        WHEN already_exists THEN
            dbms_output.put_line('WARN - Index Already Exists');
            dbms_output.put_line(sqlerrm);
        WHEN OTHERS THEN
            dbms_output.put_line('FAIL - Already Exists!');
            dbms_output.put_line(sqlerrm);
    END;

    dbms_output.put_line('***************************');
    --dbms_output.put_line(get_available_dorm(1, sysdate));
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line(sqlerrm);
END;
/