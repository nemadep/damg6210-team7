CREATE OR REPLACE FUNCTION shiftcreated (
    proc   proctor.proctor_id%TYPE,
    sup    supervisor.supervisor_id%TYPE,
    dor    dorm.dorm_id%TYPE,
    sch    DATE,
    shiftt CHAR
) RETURN NUMBER AS
    successin             NUMBER := 0;
    proctorddonefortheday NUMBER := 0;
BEGIN
    /*  
        Check if a shift is already assigned to a proctor for the given day.
        If it is assigned return from the function.
        If not insert a new shift.
    */
    SELECT
        COUNT(*)
    INTO proctorddonefortheday
    FROM
        shifts
    WHERE
            proctor_id = proc
        AND shift_date = sch;

    IF proctorddonefortheday = 0 THEN
        INSERT INTO shifts (
            shift_type,
            proctor_id,
            shift_date,
            create_at,
            update_at,
            supervisor_id,
            dorm_id
        ) VALUES (
            shiftt,
            proc,
            sch,
            sysdate,
            sysdate,
            sup,
            dor
        );

        successin := 1;
    END IF;

    RETURN successin;
END;
/

CREATE OR REPLACE PROCEDURE shiftscheduler (
    schdate DATE
) IS

    datecount     NUMBER := 0;
    CURSOR shifttypes IS
    SELECT
        shift_type
    FROM
        shifts_type_master;

    CURSOR proctors IS
    SELECT
        proctor_id
    FROM
        proctor;

    CURSOR supervisors IS
    SELECT
        supervisor_id
    FROM
        supervisor;

    CURSOR dormids IS
    SELECT
        dorm_id
    FROM
        dorm;

    supid         supervisor.supervisor_id%TYPE;
    procid        proctor.proctor_id%TYPE;
    did           NUMBER;
    stype         CHAR;
    inputcomplete NUMBER := 0;
BEGIN
    
    /* Open the cursors */
    OPEN proctors;
    OPEN supervisors;
    
    /*  
        Check if shifts are already scheduled for given date.
        If not created generate new shifts for the given date
        else raise a warning and exit.
    */
    SELECT
        COUNT(*)
    INTO datecount
    FROM
        shifts
    WHERE
        to_date(shift_date) = to_date(schdate);

    IF datecount = 0 THEN
        /*loop over all the dorms in the cursor*/
        FOR did IN dormids LOOP
            /*loop over all the types of shift*/
            FOR stype IN shifttypes LOOP
                inputcomplete := 0;
                /*Try to insert a unique */
                WHILE inputcomplete = 0 LOOP
                    /*Picking a random supervisor for the table*/
                    SELECT
                        supervisor_id
                    INTO supid
                    FROM
                        (
                            SELECT
                                supervisor_id
                            FROM
                                supervisor
                            ORDER BY
                                dbms_random.value
                        )
                    WHERE
                        ROWNUM = 1;
                    
                    /*Picking a random proctor for the table*/
                    SELECT
                        proctor_id
                    INTO procid
                    FROM
                        (
                            SELECT
                                proctor_id
                            FROM
                                proctor
                            ORDER BY
                                dbms_random.value
                        )
                    WHERE
                        ROWNUM = 1;
                    
                    /*Calling the function to insert shift*/
                   inputcomplete := shiftcreated(procid, supid, did.dorm_id, schdate, stype.shift_type);

                END LOOP;

            END LOOP;
        END LOOP;
    ELSE
        raise_application_error(-20004, 'Shifts already created');
    END IF;

    /*Close the cursors*/
    CLOSE proctors;
    CLOSE supervisors;
END;
/



EXEC shiftscheduler(sysdate + 7);


select * from shifts;
select count(*) from proctor;