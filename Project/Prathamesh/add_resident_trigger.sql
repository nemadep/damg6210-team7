CREATE OR REPLACE FUNCTION f_get_first_available_dorm RETURN NUMBER IS
    is_available NUMBER(1) := 0;
BEGIN
    SELECT
        dm.dorm_id
    INTO is_available
    FROM
        dorm dm
    WHERE
        dm.dorm_capacity > (
            SELECT
                COUNT(*)
            FROM
                resident rs
            WHERE
                rs.dorm_id = dm.dorm_id
            GROUP BY
                rs.dorm_id
        );

    RETURN is_available;
END f_get_first_available_dorm;
/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE p_resident_addition(studentID NUMBER) IS
    available_dorm NUMBER;
    available_name VARCHAR(50);
BEGIN
    dbms_output.put_line('!!!!!!Made as resident');
    IF ( :new.is_resident = 'TRUE' ) THEN
        available_dorm := f_get_first_available_dorm;
        SELECT
            dorm_name
        INTO available_name
        FROM
            dorm
        WHERE
            dorm_id = available_dorm;

        EXECUTE IMMEDIATE 'insertdormmanagementdata.p_makestudentaresident(:new.student_id, available_name, current_timestamp, add_months(current_timestamp, 12))';
        dbms_output.put_line('Made as resident');
    END IF;

END;
/

SELECT
    *
FROM
    resident;

EXEC insertdormmanagementdata.insertstudent('Nooooak Muslim', '(841) 7717372', '09-Mar-2001', 'M', 'FALSE',
                                           '310 Summer Ridge Way', 'nmuuuuuuslimrr@comcast.net');