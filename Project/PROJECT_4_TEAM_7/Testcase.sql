--Test Shift schedule when new dorm is inserted
SET SERVEROUTPUT ON;

dbms_output.put_line('Testcase 1');

Create or replace procedure testShiftScheduler as
CURSOR scheduledDays is select distinct(shift_date) from shifts;
schDay date;
no_shifts exception;
BEGIN
    --Insert a new dorm into the dorm table
    insertdormmanagementdata.insertdorm('Dev A', 600, 'Boston', 'MA', '02127',
                                       'Columbus Ave', '');
                                       
    --Schedule shifts for newly inserted dorm
    open scheduledDays;
    loop
        fetch scheduledDays into schDay;
        if scheduledDays%ROWCOUNT = 0 then
            raise no_shifts;
        end if;    
        EXIT WHEN scheduledDays%NOTFOUND;
        insertdormmanagementdata.shiftscheduler(schDay);
    end loop;
    
    close scheduledDays;
    
    exception
        when no_shifts then
            dbms_output.put_line('--No shifts scheduled till now--');
    

END;

begin
testshiftscheduler;
end;
/

select count(*) from shifts;






dbms_output.put_line('Testcase 2 ');

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
    test2_makestudentaresident_insertbased('Prasthamesh Nemade', '23-Jan-1995', 'prathameshh@gmail.com', 'TRUE');
END;
/



dbms_output.put_line('Testcase 3');
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

EXEC test1_makestudentaresident_dormvalidation(229, 'Willis Hall', '12-Nov-2021', '03-Aug-2030');




dbms_output.put_line('Testcase 4');



