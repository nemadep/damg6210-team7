--Test Shift schedule when new dorm is inserted
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE testshiftscheduler AS
    CURSOR scheduleddays IS
    SELECT DISTINCT
        ( shift_date )
    FROM
        shifts;

    schday DATE;
    no_shifts EXCEPTION;
BEGIN

    --Insert a new dorm into the dorm table
    insertdormmanagementdata.insertdorm('Dev A', 600, 'Boston', 'MA', '02127',
                                       'Columbus Ave', '');
                                       
    --Schedule shifts for newly inserted dorm
    OPEN scheduleddays;
    LOOP
        FETCH scheduleddays INTO schday;
        IF scheduleddays%rowcount = 0 THEN
            RAISE no_shifts;
        END IF;
        EXIT WHEN scheduleddays%notfound;
        insertdormmanagementdata.shiftscheduler(schday);
    END LOOP;

    CLOSE scheduleddays;
EXCEPTION
    WHEN no_shifts THEN
        dbms_output.put_line('--No shifts scheduled till now--');
END;
/

BEGIN
    dbms_output.put_line('Testcase 1');
    testshiftscheduler;
END;
/

SELECT
    COUNT(*)
FROM
    shifts;

CREATE OR REPLACE PROCEDURE test2_makestudentaresident_insertbased (
    studentname VARCHAR,
    dob         VARCHAR,
    email       VARCHAR,
    isresidence VARCHAR
) IS
    temp_student_id       NUMBER;
    temp_student_resident VARCHAR2(255);
BEGIN
    SELECT
        COUNT(student_id)
    INTO temp_student_id
    FROM
        student
    WHERE
            student_email = email
        AND student_name = studentname
        AND student_dob = dob;

    dbms_output.put_line('Initial Stduent id - Does not exists - ' || temp_student_id);
    dbms_output.put_line('Procedure triggered!');
    BEGIN
        insertdormmanagementdata.insertstudent(studentname, '(273) 5302377', dob, 'F', isresidence,
                                              '26 Miller Drive', email);
    END;

    SELECT
        student_id
    INTO temp_student_id
    FROM
        student
    WHERE
            student_email = email
        AND student_name = studentname
        AND student_dob = dob;

    dbms_output.put_line('Student id generated - ' || temp_student_id);
    SELECT
        is_resident
    INTO temp_student_resident
    FROM
        student
    WHERE
        student_id = temp_student_id;

    SELECT
        COUNT(*)
    INTO temp_student_resident
    FROM
        resident
    WHERE
        student_id = temp_student_id;

    dbms_output.put_line('Stduent Residence Status - ' || temp_student_resident);
    dbms_output.put_line('Exists in Residence Tab - ' || temp_student_resident);
END;
/

BEGIN
    dbms_output.put_line('Testcase 2 ');
    test2_makestudentaresident_insertbased('Prasthamesh Nemade', '23-Jan-1995', 'prathameshh@gmail.com', 'TRUE');
END;
/

CREATE OR REPLACE PROCEDURE test1_makestudentaresident_dormvalidation (
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

    temp_is_dorm_available := insertdormmanagementdata.f_check_dorm_availability(temp_dorm_id, from_date, to_date);
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

BEGIN
    dbms_output.put_line('Testcase 3');
    test1_makestudentaresident_dormvalidation(229, 'Willis Hall', '12-Nov-2021', '03-Aug-2030');
END;
/

CREATE OR REPLACE PROCEDURE test2_makestudentaresident_triggerbased (
    studentid NUMBER
) IS
    temp_student_residence VARCHAR2(10);
    temp_student_resident  NUMBER;
    already_residence EXCEPTION;
BEGIN
    SELECT
        is_resident
    INTO temp_student_residence
    FROM
        student
    WHERE
        student_id = studentid;

    dbms_output.put_line('Initial Stduent id -  ' || studentid);
    dbms_output.put_line('Student Residence Status -  ' || temp_student_residence);
    IF ( temp_student_residence = 'TRUE' ) THEN
        RAISE already_residence;
    END IF;
    EXECUTE IMMEDIATE q'!update student set is_resident = 'TRUE' where student_id = !'
                      || studentid
                      || '';
    COMMIT;
    dbms_output.put_line('Trigger triggered!');
    SELECT
        is_resident
    INTO temp_student_residence
    FROM
        student
    WHERE
        student_id = studentid;

    dbms_output.put_line('Student Residence Status - ' || temp_student_residence);
EXCEPTION
    WHEN already_residence THEN
        dbms_output.put_line('Student is already a Resideny');
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
END;
/

BEGIN
    dbms_output.put_line('Testcase 4');
    test2_makestudentaresident_triggerbased(156);
END;
/

CREATE OR REPLACE PROCEDURE closecase (
    policeid   NUMBER,
    caseid     NUMBER,
    casestatus VARCHAR
) IS

    is_police_available            NUMBER;
    is_case_available              NUMBER;
    is_case_already_closed         NUMBER;
    is_case_mapped_to_given_police NUMBER;
    e_police_valid EXCEPTION;
    e_case_valid EXCEPTION;
    e_case_already_closed EXCEPTION;
    e_case_status_not_valid EXCEPTION;
    e_case_not_mapped_to_given_police EXCEPTION;
BEGIN
    IF casestatus IN ( 'Closed' ) THEN
        -- Check if given case is mapped to the given police
        SELECT
            COUNT(*)
        INTO is_case_mapped_to_given_police
        FROM
            police_incident_mapping
        WHERE
            ( case_id = caseid
              AND police_id = policeid );
    
        -- Check if case is already closed
        SELECT
            COUNT(*)
        INTO is_case_already_closed
        FROM
            police_incident_mapping
        WHERE
            ( case_id = caseid
              AND case_status = casestatus );
        
        -- Check if police exists
        SELECT
            COUNT(*)
        INTO is_police_available
        FROM
            police
        WHERE
            police_id = policeid;
            
        -- Check is case exists
        SELECT
            COUNT(*)
        INTO is_case_available
        FROM
            incident
        WHERE
            case_id = caseid;

        IF is_police_available = 0 THEN
            RAISE e_police_valid;
        ELSIF is_case_available = 0 THEN
            RAISE e_case_valid;
        ELSIF is_case_mapped_to_given_police = 0 THEN
            RAISE e_case_not_mapped_to_given_police;
        ELSIF is_case_already_closed > 0 THEN
            RAISE e_case_already_closed;
        ELSE

            -- Close the case
            UPDATE police_incident_mapping
            SET
                case_status = casestatus
            WHERE
                case_id = caseid;

            dbms_output.put_line('Case closed successfully!');
        END IF;

    ELSE
        RAISE e_case_status_not_valid;
    END IF;
EXCEPTION
    WHEN e_case_already_closed THEN
        dbms_output.put_line('Case already closed!');
    WHEN e_police_valid THEN
        dbms_output.put_line('Police not found!');
    WHEN e_case_valid THEN
        dbms_output.put_line('Case not found!');
    WHEN e_case_status_not_valid THEN
        dbms_output.put_line('Case status is not valid!');
    WHEN e_case_not_mapped_to_given_police THEN
        dbms_output.put_line('Case is not mapped to the given police!');
END;
/

BEGIN
    dbms_output.put_line('Testcase 5');
    closecase(3, 4, 'Closed');
    closecase(38, 2, 'Open');
    closecase(3, 4, 'Closed');
    closecase(143, 54, 'Closed');
    closecase(23, 6, 'Closed');
END;
/

commit;
