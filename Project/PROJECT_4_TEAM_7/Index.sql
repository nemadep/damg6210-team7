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
    dbms_output.put_line(get_available_dorm(1, sysdate));
END;
/

CREATE INDEX dorm_availablity ON
    resident (
        dorm_id,
        to_date
    );

BEGIN
    dbms_output.put_line(get_available_dorm(1, sysdate));
END;
/

DROP INDEX dorm_availablity;