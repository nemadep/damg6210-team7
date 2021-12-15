SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION shiftcreated (
    proc   proctor.proctor_id%TYPE,
    sup    supervisor.supervisor_id%TYPE,
    dor    dorm.dorm_id%TYPE,
    sch    DATE,
    shiftt CHAR
) RETURN NUMBER AS
    successin             NUMBER := 0;
    proctorddonefortheday NUMBER := 0;
    shiftexists           NUMBER := 0;
BEGIN
    /*  
        Check if a shift is already assigned to a proctor for the given day.
        If it is assigned return from the function.
        If not insert a new shift.
    */
    SELECT
        COUNT(*)
    INTO shiftexists
    FROM
        shifts sh
    WHERE
            shiftt = sh.shift_type
        AND dor = sh.dorm_id
        AND to_date(sh.shift_date) = to_date(sch);

    SELECT
        COUNT(*)
    INTO proctorddonefortheday
    FROM
        shifts
    WHERE
            proctor_id = proc
        AND shift_date = sch;

    IF shiftexists = 0 THEN
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
    ELSE
        successin := 2;
    END IF;

    RETURN successin;
END;
/

CREATE OR REPLACE PROCEDURE shiftscheduler (
    schdate DATE
) IS

    CURSOR shifttypes IS
    SELECT
        shift_type
    FROM
        shifts_type_master;

    CURSOR dormids IS
    SELECT
        dorm_id
    FROM
        dorm;

    datecount       NUMBER := 0;
    supid           supervisor.supervisor_id%TYPE;
    procid          proctor.proctor_id%TYPE;
    did             NUMBER;
    stype           CHAR;
    inputcomplete   NUMBER := 0;
    proctorcount    NUMBER := 0;
    supervisorcount NUMBER := 0;
    dormcount       NUMBER := 0;
    shiftmaster     NUMBER := 0;
    no_proctors EXCEPTION;
    no_supervisors EXCEPTION;
    no_dorm EXCEPTION;
    no_shift_master EXCEPTION;
BEGIN
    
    /* Open the cursors */

    SELECT
        COUNT(*)
    INTO proctorcount
    FROM
        proctor;

    SELECT
        COUNT(*)
    INTO supervisorcount
    FROM
        supervisor;

    SELECT
        COUNT(*)
    INTO dormcount
    FROM
        dorm;

    SELECT
        COUNT(*)
    INTO shiftmaster
    FROM
        shifts_type_master;

    IF proctorcount = 0 THEN
        RAISE no_proctors;
    ELSIF supervisorcount = 0 THEN
        RAISE no_supervisors;
    ELSIF dormcount = 0 THEN
        RAISE no_dorm;
    ELSIF shiftmaster = 0 THEN
        RAISE no_shift_master;
    END IF;

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

                DECLARE
                    proctor_limit EXCEPTION;
                    shift_already_done EXCEPTION;
                BEGIN   
                    /*Calling the function to insert shift*/
                    inputcomplete := shiftcreated(procid, supid, did.dorm_id, schdate, stype.shift_type);

                    IF inputcomplete = 2 THEN
                        RAISE shift_already_done;
                    ELSIF inputcomplete = 0 THEN
                        RAISE proctor_limit;
                    END IF;

                EXCEPTION
                    WHEN proctor_limit THEN
                        dbms_output.put_line('Selected proctor already crossed the daily work limit');
                    WHEN shift_already_done THEN
                        dbms_output.put_line('Shift already scheduled for given date and dorm');
                END;

            END LOOP;

        END LOOP;
    END LOOP;

EXCEPTION
    WHEN no_proctors THEN
        dbms_output.put_line('No proctor data found');
    WHEN no_supervisors THEN
        dbms_output.put_line('No supervisor data found');
    WHEN no_dorm THEN
        dbms_output.put_line('No dorm data found');
    WHEN no_shift_master THEN
        dbms_output.put_line('No shift master data found');
END;
/

EXEC shiftscheduler(sysdate + 10);

SELECT
    *
FROM
    shifts;

DELETE FROM shifts;

DELETE FROM proctor;