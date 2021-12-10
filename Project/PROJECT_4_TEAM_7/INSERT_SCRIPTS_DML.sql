----------------------- INSERT SQL SCRIPTS DML ------------------------------

--PACKAGE CREATION
CREATE OR REPLACE PACKAGE insertdormmanagementdata AS
    PROCEDURE insertutilitymaster (
        uname VARCHAR,
        udesc VARCHAR
    );

    PROCEDURE insertdorm (
        dname     VARCHAR,
        dcapacity NUMBER,
        dcity     VARCHAR,
        dstate    VARCHAR,
        dzip      VARCHAR,
        daddress1 VARCHAR,
        daddress2 VARCHAR
    );

    PROCEDURE insertstudent (
        sname       VARCHAR,
        scontact    VARCHAR,
        sdob        DATE,
        sgender     CHAR,
        resident    CHAR,
        permaddress VARCHAR2,
        semail      VARCHAR2
    );

    PROCEDURE insertshiftmaster (
        stype  CHAR,
        sstart TIMESTAMP,
        send   TIMESTAMP
    );

    PROCEDURE insertproctor (
        pname    VARCHAR,
        pcontact VARCHAR,
        pemail   VARCHAR,
        paddress VARCHAR,
        pdob     VARCHAR
    );

    PROCEDURE insertsupervisor (
        supname    VARCHAR,
        supaddress VARCHAR,
        supcontact VARCHAR,
        supemail   VARCHAR
    );

    FUNCTION f_is_valid_utility (
        utilityid IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE p_utility_entry (
        utilityid  NUMBER,
        residentid NUMBER
    );

    FUNCTION shiftcreated (
        proc   proctor.proctor_id%TYPE,
        sup    supervisor.supervisor_id%TYPE,
        dor    dorm.dorm_id%TYPE,
        sch    DATE,
        shiftt CHAR
    ) RETURN NUMBER;

    PROCEDURE shiftscheduler (
        schdate DATE
    );

    PROCEDURE shiftscheduler (
        schdate DATE,
        tillday NUMBER
    );

    PROCEDURE insertpolice (
        policename    VARCHAR,
        policegender  CHAR,
        policecontact VARCHAR
    );

    PROCEDURE generatecase (
        dormid          NUMBER,
        casetype        VARCHAR,
        casedescription VARCHAR
    );

    PROCEDURE mapcasetopolice (
        policeid   NUMBER,
        caseid     NUMBER,
        casestatus VARCHAR
    );

    FUNCTION f_check_dorm_availability (
        dormid   IN NUMBER,
        fromdate IN DATE,
        todate   IN DATE
    ) RETURN NUMBER;

    PROCEDURE p_makestudentaresident (
        studuentid NUMBER,
        dormname   VARCHAR,
        from_date  DATE,
        to_date    DATE
    );

    FUNCTION f_is_valid_resident (
        residentid IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE p_guest_entry (
        guestname    VARCHAR,
        guestcontact VARCHAR,
        residentid   NUMBER
    );

    PROCEDURE p_swipe_me (
        residentid NUMBER,
        dormid     NUMBER
    );

END;
/

--PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY insertdormmanagementdata AS

    PROCEDURE insertutilitymaster (
        uname VARCHAR,
        udesc VARCHAR
    ) IS
        alreadyInserted number := 0;
    BEGIN
        SELECT COUNT(*) INTO alreadyInserted 
        FROM utility_type_master utm 
        WHERE uname = utm.utility_name;
        IF alreadyInserted = 0 then
            INSERT INTO utility_type_master (
                utility_name,
                utility_desc
            ) VALUES (
                uname,
                udesc
            );
        ELSE
            dbms_output.put_line('----Utility type already exists----');
        END IF; 

    END;

/*Insert procedure for Dorm Table*/
    PROCEDURE insertdorm (
        dname     VARCHAR,
        dcapacity NUMBER,
        dcity     VARCHAR,
        dstate    VARCHAR,
        dzip      VARCHAR,
        daddress1 VARCHAR,
        daddress2 VARCHAR
    ) IS
        alreadyInserted number := 0;
    BEGIN
        SELECT COUNT(*) INTO alreadyInserted 
        FROM dorm d 
        WHERE dname = d.dorm_name AND dzip = d.dorm_zip;
        IF alreadyInserted = 0 then
            INSERT INTO dorm (
                dorm_name,
                dorm_capacity,
                dorm_city,
                dorm_state,
                dorm_zip,
                dorm_address_line1,
                dorm_address_line2
            ) VALUES (
                dname,
                dcapacity,
                dcity,
                dstate,
                dzip,
                daddress1,
                daddress2
            );
        ELSE
            dbms_output.put_line('----Dorm already exists----');
        END IF;

    END;

    PROCEDURE insertstudent (
        sname       VARCHAR,
        scontact    VARCHAR,
        sdob        DATE,
        sgender     CHAR,
        resident    CHAR,
        permaddress VARCHAR2,
        semail      VARCHAR2
    ) IS
        alreadyInserted number := 0;
    BEGIN
        SELECT COUNT(*) INTO alreadyInserted 
        FROM student s 
        WHERE sname = s.student_name AND sdob = s.student_dob AND semail = s.student_email;
        IF alreadyInserted = 0 then
            INSERT INTO student (
                student_name,
                student_contact,
                student_dob,
                student_gender,
                is_resident,
                permanent_address,
                student_email
            ) VALUES (
                sname,
                scontact,
                sdob,
                sgender,
                resident,
                permaddress,
                semail
            );
        ELSE
            dbms_output.put_line('----Student already exists----');
        END IF;
    END;

    FUNCTION f_check_dorm_availability (
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

    PROCEDURE p_makestudentaresident (
        studuentid NUMBER,
        dormname   VARCHAR,
        from_date  DATE,
        to_date    DATE
    ) IS
    
        is_already_exists      NUMBER;
        is_available           NUMBER;
        temp_dorm_id           NUMBER;
        temp_is_dorm_available NUMBER;
        is_already_resident    CHAR(5);
        e_dorm_valid EXCEPTION;
        already_resident EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO is_already_exists FROM resident WHERE student_id = studuentid;
        IF is_already_exists = 0 THEN
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
    ELSE
        dbms_output.put_line('Dorm already allocated!');
    END IF;
    EXCEPTION
        WHEN e_dorm_valid THEN
            dbms_output.put_line('Invalid dorm!');
        WHEN already_resident THEN
            dbms_output.put_line('Already a resident!');
    END;

    FUNCTION f_is_valid_resident (
        residentid IN NUMBER
    ) RETURN NUMBER IS
        is_valid_resident NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_valid_resident
        FROM
            resident
        WHERE
            resident_id = residentid;

        RETURN is_valid_resident;
    END;

    PROCEDURE p_guest_entry (
        guestname    VARCHAR,
        guestcontact VARCHAR,
        residentid   NUMBER
    ) AS
        is_valid_resident NUMBER;
        e_valid_resident EXCEPTION;
    BEGIN
        is_valid_resident := f_is_valid_resident(residentid);
        IF is_valid_resident = 0 THEN
            RAISE e_valid_resident;
        END IF;
        INSERT INTO guest (
            guest_name,
            guest_contact,
            visit_date,
            resident_id
        ) VALUES (
            guestname,
            guestcontact,
            current_timestamp,
            residentid
        );

    EXCEPTION
        WHEN e_valid_resident THEN
            dbms_output.put_line('Invalid resdient. Resident doesnt exists!');
    END;

    PROCEDURE p_swipe_me (
        residentid NUMBER,
        dormid     NUMBER
    ) AS
    BEGIN
        INSERT INTO swipe_log (
            resident_id,
            swipe_time,
            dorm_id
        ) VALUES (
            residentid,
            current_timestamp,
            dormid
        );

    END;

    PROCEDURE insertshiftmaster (
        stype  CHAR,
        sstart TIMESTAMP,
        send   TIMESTAMP
    ) IS
        alreadyinserted NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            shifts_type_master stm
        WHERE
            stype = stm.shift_type;

        IF alreadyinserted = 0 THEN
            INSERT INTO shifts_type_master (
                shift_type,
                start_time,
                end_time
            ) VALUES (
                stype,
                sstart,
                send
            );

        ELSE
            dbms_output.put_line('----Shift type already exists----');
        END IF;

    END;

    PROCEDURE insertproctor (
        pname    VARCHAR,
        pcontact VARCHAR,
        pemail   VARCHAR,
        paddress VARCHAR,
        pdob     VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            proctor proc
        WHERE
                pname = proc.proctor_name
            AND pcontact = proc.proctor_contact;

        IF alreadyinserted = 0 THEN
            INSERT INTO proctor (
                proctor_name,
                proctor_contact,
                proctor_email,
                proctor_address,
                proctor_dob
            ) VALUES (
                pname,
                pcontact,
                pemail,
                paddress,
                pdob
            );

        ELSE
            dbms_output.put_line('----Proctor already exists----');
        END IF;

    END;

    PROCEDURE insertsupervisor (
        supname    VARCHAR,
        supaddress VARCHAR,
        supcontact VARCHAR,
        supemail   VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            supervisor sup
        WHERE
                supname = sup.supervisor_name
            AND supcontact = sup.supervisor_contact;

        IF alreadyinserted = 0 THEN
            INSERT INTO supervisor (
                supervisor_name,
                supervisor_address,
                supervisor_contact,
                supervisor_email
            ) VALUES (
                supname,
                supaddress,
                supcontact,
                supemail
            );

        ELSE
            dbms_output.put_line('----Supervisor already exists----');
        END IF;

    END;

    FUNCTION f_is_valid_utility (
        utilityid IN NUMBER
    ) RETURN NUMBER IS
        is_valid_utility NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_valid_utility
        FROM
            utility_type_master
        WHERE
            utility_id = utilityid;

        RETURN is_valid_utility;
    END;

    PROCEDURE p_utility_entry (
        utilityid  NUMBER,
        residentid NUMBER
    ) AS
        is_valid_utility  NUMBER;
        is_valid_resident NUMBER;
        e_valid_resident EXCEPTION;
        e_valid_utility EXCEPTION;
        dormid            NUMBER;
    BEGIN
        is_valid_utility := f_is_valid_utility(utilityid);
        IF is_valid_utility = 0 THEN
            RAISE e_valid_utility;
        END IF;
        is_valid_resident := f_is_valid_resident(residentid);
        IF is_valid_resident = 0 THEN
            RAISE e_valid_resident;
        END IF;
        SELECT
            dorm_id
        INTO dormid
        FROM
            resident
        WHERE
            resident_id = residentid;

        INSERT INTO utility (
            utility_id,
            access_date,
            dorm_id,
            resident_id
        ) VALUES (
            utilityid,
            sysdate,
            dormid,
            residentid
        );

    EXCEPTION
        WHEN e_valid_resident THEN
            dbms_output.put_line('Invalid resdient. Resident doesnt exists!');
        WHEN e_valid_utility THEN
            dbms_output.put_line('Invalid utility. Utility doesnt exists!');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    FUNCTION shiftcreated (
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

    PROCEDURE shiftscheduler (
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
            dbms_output.put_line('---Shifts already created---');
        END IF;

    /*Close the cursors*/
        CLOSE proctors;
        CLOSE supervisors;
    END;

    PROCEDURE shiftscheduler (
        schdate  DATE,
        tillday NUMBER
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
    
    /*loop over days*/
        FOR schday IN 0..tillday LOOP
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
                to_date(shift_date) = to_date(schdate + schday);

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
                            inputcomplete := shiftcreated(procid, supid, did.dorm_id, schdate + schday, stype.shift_type);

                        END LOOP;

                    END LOOP;
                END LOOP;

            ELSE
                dbms_output.put_line('---Shifts already created---');
            END IF;

        END LOOP;

    /*Close the cursors*/
        CLOSE proctors;
        CLOSE supervisors;
    END;

    PROCEDURE insertpolice (
        policename    VARCHAR,
        policegender  CHAR,
        policecontact VARCHAR
    ) IS
    alreadyInserted number := 0;
    BEGIN

        SELECT COUNT(*) INTO 
            alreadyInserted 
            FROM police pol 
            WHERE policename = pol.police_name 
            AND policecontact = pol.police_contact;

        IF alreadyInserted = 0 THEN
            INSERT INTO police (
                police_name,
                police_gender,
                police_contact
            ) VALUES (
                policename,
                policegender,
                policecontact
            );
        ELSE
            dbms_output.put_line('----Police already exists----');
        END IF;


        

    END;

    PROCEDURE generatecase (
        dormid          NUMBER,
        casetype        VARCHAR,
        casedescription VARCHAR
    ) IS
        is_available NUMBER;
        e_dorm_valid EXCEPTION;
    BEGIN

    -- Check if dorm exists
        SELECT
            COUNT(*)
        INTO is_available
        FROM
            dorm
        WHERE
            dorm_id = dormid;

        IF is_available > 0 THEN
            INSERT INTO incident (
                dorm_id,
                case_type,
                case_description
            ) VALUES (
                dormid,
                casetype,
                casedescription
            );

        ELSE
            RAISE e_dorm_valid;
        END IF;

    EXCEPTION
        WHEN e_dorm_valid THEN
            raise_application_error(-20210, 'Invalid dorm!');
    END;

    PROCEDURE mapcasetopolice (
        policeid   NUMBER,
        caseid     NUMBER,
        casestatus VARCHAR
    ) IS
        is_police_available    NUMBER;
        is_case_available      NUMBER;
        is_case_already_mapped NUMBER;
        e_police_valid EXCEPTION;
        e_case_valid EXCEPTION;
        e_case_already_mapped EXCEPTION;
    BEGIN
    
    -- Check if case is already assigned to a police
        SELECT
            COUNT(*)
        INTO is_case_already_mapped
        FROM
            police_incident_mapping
        WHERE
            case_id = caseid;
        
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

        IF is_case_already_mapped = 0 THEN
            IF is_police_available = 0 THEN
                RAISE e_police_valid;
            ELSIF is_case_available = 0 THEN
                RAISE e_case_valid;
            ELSE
                INSERT INTO police_incident_mapping (
                    police_id,
                    case_id,
                    case_status
                ) VALUES (
                    policeid,
                    caseid,
                    casestatus
                );

            END IF;
        ELSE
            RAISE e_case_already_mapped;
        END IF;

    EXCEPTION
        WHEN e_case_already_mapped THEN
            raise_application_error(-20310, 'Case already mapped to police!');
        WHEN e_police_valid THEN
            raise_application_error(-20320, 'Invalid police!');
        WHEN e_case_valid THEN
            raise_application_error(-20330, 'Invalid case!');
    END;

END;
/

--PACKAGE EXECUTION
SET SERVEROUTPUT ON;

EXEC insertdormmanagementdata.insertutilitymaster('Washer-101', 'This Washer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-102', 'This Washer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-103', 'This Washer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-104', 'This Washer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-105', 'This Washer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-101', 'This Dryer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-102', 'This Dryer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-103', 'This Dryer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-104', 'This Dryer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-105', 'This Dryer is in Laundry Room 1 Ell Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-201', 'This Washer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-202', 'This Washer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-203', 'This Washer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-204', 'This Washer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-205', 'This Washer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-201', 'This Dryer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-202', 'This Dryer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-203', 'This Dryer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-204', 'This Dryer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-205', 'This Dryer is in Laundry Room 2 White Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-301', 'This Washer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-302', 'This Washer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-303', 'This Washer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-304', 'This Washer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Washer-305', 'This Washer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-301', 'This Dryer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-302', 'This Dryer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-303', 'This Dryer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-304', 'This Dryer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Dryer-305', 'This Dryer is in Laundry Room 3 Hayden Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Pool Table-101', 'This Pool table is in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Pool Table-102', 'This Pool tableis in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Pool Table-201', 'This Pool table is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Pool Table-202', 'This Pool table is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Table Tennis-101', 'This Table Tennis is in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Table Tennis-102', 'This Table Tennis is in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Table Tennis-201', 'This Table Tennis is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Table Tennis-202', 'This Table Tennis is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('PS5-101', 'This PS5 is in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('PS5-102', 'This PS5 is in Clubhouse 1 Hurtig Hall');

EXEC insertdormmanagementdata.insertutilitymaster('PS5-201', 'This PS5 is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('PS5-202', 'This PS5 is in Clubhouse 2 Nightingale Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Swimming Pool-001', 'This Swimming Pool is in Burstein Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Swimming Pool-002', 'This Swimming Pool is in Burstein Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Swimming Pool-003', 'This Swimming Pool is in Burstein Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Gym-001', 'This Gym is in Meserve Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Gym-002', 'This Swimming Pool is in Lake Hall');

EXEC insertdormmanagementdata.insertutilitymaster('Gym-003', 'This Swimming Pool is in Kerr Hall');

BEGIN
insertdormmanagementdata.insertdorm('Hastings Hall', 200, 'Boston', 'MA', '02139',
                                        '316 Huntington Ave', '');

insertdormmanagementdata.insertdorm('Meserve Hall', 400, 'Boston', 'MA', '02127',
                                        '35 Leon St', '');

insertdormmanagementdata.insertdorm('Northeastern University Smith Hall', 150, 'Boston', 'MA', '02149',
                                        '129 Hemenway St', '');

insertdormmanagementdata.insertdorm('Lake Hall', 300, 'Boston', 'MA', '02115',
                                        '43 Leon St', '');

insertdormmanagementdata.insertdorm('Nightingale Hall', 300, 'Boston', 'MA', '02131',
                                        '360 Huntington Ave', '');

insertdormmanagementdata.insertdorm('Blackman Auditorium', 500, 'Boston', 'MA', '02130',
                                        'Ell Hall', '342 Huntington Ave');

insertdormmanagementdata.insertdorm('Willis Hall', 150, 'Boston', 'MA', '02115',
                                        '50 Leon St', '');

insertdormmanagementdata.insertdorm('White Hall', 200, 'Boston', 'MA', '02139',
                                        'White Hall', '21 Forsyth St');

insertdormmanagementdata.insertdorm('Hurtig Hall', 300, 'Boston', 'MA', '02147',
                                        '10 Gainsborough St', '');

insertdormmanagementdata.insertdorm('Northeastern University Dining Services', 500, 'Boston', 'MA', '02740',
                                        '106 St Stephen St', '');

insertdormmanagementdata.insertdorm('Light Hall', 200, 'Boston', 'MA', '02703',
                                        '81-83 St Stephen St', '');

insertdormmanagementdata.insertdorm('Robinson Hall', 150, 'Boston', 'MA', '02130',
                                        '336 Huntington Ave', '');

insertdormmanagementdata.insertdorm('Richards Hall', 300, 'Boston', 'MA', '02149',
                                        '360 Huntington Ave', '');

insertdormmanagementdata.insertdorm('Loftman Hall', 300, 'Boston', 'MA', '02127',
                                        'Northeastern University', '157 Hemenway St');

insertdormmanagementdata.insertdorm('Shillman Hall', 300, 'Boston', 'MA', '02741',
                                        'Northeastern University', '115 Forsyth St');

insertdormmanagementdata.insertdorm('Kerr Hall', 300, 'Boston', 'MA', '02740',
                                        '96 Fenway', '');

insertdormmanagementdata.insertdorm('Hayden Hall', 300, 'Boston', 'MA', '02703',
                                        '360 Huntington Ave', '');

insertdormmanagementdata.insertdorm('East Village Residence Hall', 300, 'Boston', 'MA', '02131',
                                        '291 St Botolph St', '');

insertdormmanagementdata.insertdorm('Northeastern Univ. International Village', 300, 'Boston', 'MA', '02151',
                                        '1155 Tremont St', '');

insertdormmanagementdata.insertdorm('Burstein Hall', 300, 'Boston', 'MA', '02741',
                                        '458 Huntington Ave', '');

insertdormmanagementdata.insertstudent('Jobyna Godilington', '(273) 5302377', '09-Oct-2001', 'F', 'FALSE',
                                           '26 Miller Drive', 'jgodilington0@mtv.com');

insertdormmanagementdata.insertstudent('Ingar Feechan', '(681) 5294047', '25-Oct-1996', 'M', 'FALSE',
                                           '005 Rutledge Place', 'ifeechan1@yahoo.co.jp');

insertdormmanagementdata.insertstudent('Jesus Eakly', '(158) 5027900', '30-Dec-1991', 'M', 'FALSE',
                                           '1509 Farragut Terrace', 'jeakly2@yellowbook.com');

insertdormmanagementdata.insertstudent('Liza Spedding', '(693) 7502112', '17-May-2002', 'F', 'FALSE',
                                           '7 Elmside Plaza', 'lspedding3@fastcompany.com');

insertdormmanagementdata.insertstudent('Nataline Mityukov', '(423) 7130660', '21-May-1995', 'F', 'FALSE',
                                           '6718 Beilfuss Pass', 'nmityukov4@goo.gl');

insertdormmanagementdata.insertstudent('Tisha Bonny', '(948) 5235156', '03-Aug-1996', 'F', 'FALSE',
                                           '6623 Burning Wood Pass', 'tbonny5@behance.net');

insertdormmanagementdata.insertstudent('Sheba Gillies', '(594) 9095565', '15-Apr-1994', 'F', 'FALSE',
                                           '96715 Bartelt Plaza', 'sgillies6@weebly.com');

insertdormmanagementdata.insertstudent('Nichole Reyner', '(533) 4046344', '28-Jun-1993', 'F', 'FALSE',
                                           '08918 Summit Plaza', 'nreyner7@gmpg.org');

insertdormmanagementdata.insertstudent('Harland Kulas', '(342) 6826052', '03-Mar-2001', 'M', 'FALSE',
                                           '0 Northwestern Way', 'hkulas8@blog.com');

insertdormmanagementdata.insertstudent('Sergei Labrenz', '(562) 8678279', '15-Sep-2001', 'M', 'FALSE',
                                           '81 Carpenter Hill', 'slabrenz9@netlog.com');

insertdormmanagementdata.insertstudent('Rolf Kobierski', '(510) 9674787', '28-Apr-1993', 'M', 'FALSE',
                                           '9315 Barby Park', 'rkobierskia@naver.com');

insertdormmanagementdata.insertstudent('Kaspar Panyer', '(498) 2089508', '20-Jun-1996', 'M', 'FALSE',
                                           '0966 Mockingbird Plaza', 'kpanyerb@uol.com.br');

insertdormmanagementdata.insertstudent('Nert Turbill', '(282) 6155525', '16-Oct-1993', 'F', 'FALSE',
                                           '17745 Rusk Parkway', 'nturbillc@unicef.org');

insertdormmanagementdata.insertstudent('Hillie Docwra', '(885) 5179456', '14-Aug-1998', 'M', 'FALSE',
                                           '58 Jenifer Avenue', 'hdocwrad@vk.com');

insertdormmanagementdata.insertstudent('Holly Eaklee', '(517) 1033444', '22-Apr-2000', 'M', 'FALSE',
                                           '5060 Birchwood Lane', 'heakleee@boston.com');

insertdormmanagementdata.insertstudent('Fedora Micallef', '(188) 5802143', '28-Oct-1996', 'F', 'FALSE',
                                           '7160 Ruskin Place', 'fmicalleff@themeforest.net');

insertdormmanagementdata.insertstudent('Malanie McCome', '(800) 6722192', '11-Mar-1998', 'F', 'FALSE',
                                           '67 Becker Terrace', 'mmccomeg@sun.com');

insertdormmanagementdata.insertstudent('Glyn Verbruggen', '(345) 9205903', '19-Oct-2000', 'M', 'FALSE',
                                           '3 Anderson Junction', 'gverbruggenh@reverbnation.com');

insertdormmanagementdata.insertstudent('Perla Fransoni', '(669) 4302202', '20-Nov-1995', 'F', 'FALSE',
                                           '11 Golf Course Court', 'pfransonii@multiply.com');

insertdormmanagementdata.insertstudent('Christyna Enocksson', '(186) 5637265', '11-Dec-1999', 'F', 'FALSE',
                                           '8406 Doe Crossing Center', 'cenockssonj@angelfire.com');

insertdormmanagementdata.insertstudent('Mariann Seamons', '(311) 5318891', '26-Jan-1991', 'F', 'FALSE',
                                           '15 Birchwood Alley', 'mseamonsk@geocities.jp');

insertdormmanagementdata.insertstudent('Delilah Rove', '(192) 5663451', '30-Jul-2002', 'F', 'FALSE',
                                           '519 Duke Hill', 'drovel@java.com');

insertdormmanagementdata.insertstudent('Emmye Woodall', '(687) 4877820', '25-Jan-1998', 'F', 'FALSE',
                                           '4176 Little Fleur Terrace', 'ewoodallm@webeden.co.uk');

insertdormmanagementdata.insertstudent('Ros Kenryd', '(805) 7016347', '10-Jun-1994', 'F', 'FALSE',
                                           '5 Warrior Parkway', 'rkenrydn@webnode.com');

insertdormmanagementdata.insertstudent('Suellen Fidgin', '(203) 4869108', '26-Sep-1992', 'F', 'FALSE',
                                           '7983 Sundown Alley', 'sfidgino@cam.ac.uk');

insertdormmanagementdata.insertstudent('Staffard Woolen', '(780) 7697289', '08-Jan-1995', 'M', 'FALSE',
                                           '2512 Algoma Point', 'swoolenp@plala.or.jp');

insertdormmanagementdata.insertstudent('Murdoch Stolze', '(994) 5858566', '04-Mar-1994', 'M', 'FALSE',
                                           '4 Southridge Way', 'mstolzeq@smugmug.com');

insertdormmanagementdata.insertstudent('Joseito Kender', '(524) 7031010', '16-Aug-1992', 'M', 'FALSE',
                                           '44441 Mayfield Pass', 'jkenderr@salon.com');

insertdormmanagementdata.insertstudent('Ivonne Crennell', '(865) 7727490', '02-Jan-2002', 'F', 'FALSE',
                                           '03249 Rusk Terrace', 'icrennells@about.com');

insertdormmanagementdata.insertstudent('Budd Hyman', '(521) 6183134', '25-May-1996', 'M', 'FALSE',
                                           '6 Sycamore Drive', 'bhymant@sina.com.cn');

insertdormmanagementdata.insertstudent('Franny Boutellier', '(158) 3855822', '27-Jan-2000', 'M', 'FALSE',
                                           '7 Badeau Drive', 'fboutellieru@bbc.co.uk');

insertdormmanagementdata.insertstudent('Shelby Gurg', '(842) 1298868', '06-Sep-1999', 'M', 'FALSE',
                                           '1 Old Gate Avenue', 'sgurgv@hc360.com');

insertdormmanagementdata.insertstudent('Velvet McKague', '(396) 7395231', '26-Oct-1995', 'F', 'FALSE',
                                           '4 Pleasure Alley', 'vmckaguew@twitpic.com');

insertdormmanagementdata.insertstudent('Lidia Wrintmore', '(547) 4922602', '02-Nov-2002', 'F', 'FALSE',
                                           '42486 Golf Avenue', 'lwrintmorex@imdb.com');

insertdormmanagementdata.insertstudent('Nonna Annand', '(886) 7855667', '04-Mar-1993', 'F', 'FALSE',
                                           '64537 Eastlawn Court', 'nannandy@feedburner.com');

insertdormmanagementdata.insertstudent('Weidar Drummer', '(878) 7641411', '11-Mar-1999', 'M', 'FALSE',
                                           '8 Moulton Trail', 'wdrummerz@surveymonkey.com');

insertdormmanagementdata.insertstudent('Fletch Bansal', '(873) 1148355', '22-Jun-1998', 'M', 'FALSE',
                                           '739 Farragut Place', 'fbansal10@canalblog.com');

insertdormmanagementdata.insertstudent('Giuseppe Chominski', '(729) 8433234', '13-Dec-2000', 'M', 'FALSE',
                                           '672 Amoth Park', 'gchominski11@mashable.com');

insertdormmanagementdata.insertstudent('Roanne Hick', '(439) 1145503', '12-Jul-1991', 'F', 'FALSE',
                                           '92285 Pawling Court', 'rhick12@auda.org.au');

insertdormmanagementdata.insertstudent('Kimmie Bonifas', '(818) 2898262', '03-Jul-1991', 'F', 'FALSE',
                                           '2865 Hermina Terrace', 'kbonifas13@github.io');

insertdormmanagementdata.insertstudent('Beryle Worviell', '(578) 8014067', '28-May-1995', 'F', 'FALSE',
                                           '2532 Harbort Parkway', 'bworviell14@tinyurl.com');

insertdormmanagementdata.insertstudent('Tybalt Moffett', '(940) 1974980', '19-Apr-1994', 'M', 'FALSE',
                                           '5575 Shoshone Terrace', 'tmoffett15@youtube.com');

insertdormmanagementdata.insertstudent('Tristam Djorvic', '(129) 7828713', '09-Jul-1996', 'M', 'FALSE',
                                           '40 Lillian Trail', 'tdjorvic16@merriam-webster.com');

insertdormmanagementdata.insertstudent('Michel Valler', '(577) 1351147', '07-Aug-1995', 'F', 'FALSE',
                                           '36604 6th Point', 'mvaller17@paypal.com');

insertdormmanagementdata.insertstudent('Guilbert Sheardown', '(420) 4633831', '03-Sep-1996', 'M', 'FALSE',
                                           '76440 Cody Crossing', 'gsheardown18@sun.com');

insertdormmanagementdata.insertstudent('Glenn Boakes', '(417) 3437910', '08-Sep-1994', 'F', 'FALSE',
                                           '352 Annamark Crossing', 'gboakes19@hud.gov');

insertdormmanagementdata.insertstudent('Evey McLevie', '(735) 6584256', '21-Feb-1993', 'F', 'FALSE',
                                           '98844 Larry Place', 'emclevie1a@google.ru');

insertdormmanagementdata.insertstudent('Ichabod Sorrill', '(342) 5473037', '04-Sep-2000', 'M', 'FALSE',
                                           '570 Fieldstone Parkway', 'isorrill1b@virginia.edu');

insertdormmanagementdata.insertstudent('Teddi Yurygyn', '(949) 1415807', '05-Mar-1991', 'F', 'FALSE',
                                           '5914 Delladonna Way', 'tyurygyn1c@macromedia.com');

insertdormmanagementdata.insertstudent('Marje Aspital', '(828) 9550892', '30-Jul-1998', 'F', 'FALSE',
                                           '6 Farmco Circle', 'maspital1d@miitbeian.gov.cn');

insertdormmanagementdata.insertstudent('Ivonne Knoles', '(474) 7143332', '13-Feb-1990', 'F', 'FALSE',
                                           '52 Anderson Road', 'iknoles1e@opensource.org');

insertdormmanagementdata.insertstudent('Corey Boomes', '(604) 2891771', '21-Dec-1991', 'M', 'FALSE',
                                           '85986 6th Parkway', 'cboomes1f@people.com.cn');

insertdormmanagementdata.insertstudent('Thayne Wortt', '(281) 3933091', '24-Dec-1995', 'M', 'FALSE',
                                           '6 Mccormick Trail', 'twortt1g@wikia.com');

insertdormmanagementdata.insertstudent('Matthew Killelea', '(175) 1381239', '08-Oct-1994', 'M', 'FALSE',
                                           '36 Spohn Street', 'mkillelea1h@hugedomains.com');

insertdormmanagementdata.insertstudent('Carolee Hames', '(189) 4352033', '11-Dec-1996', 'F', 'FALSE',
                                           '494 Debra Park', 'chames1i@usnews.com');

insertdormmanagementdata.insertstudent('Augustina Ciementini', '(804) 4959085', '12-Jul-2002', 'F', 'FALSE',
                                           '72515 Harper Center', 'aciementini1j@wsj.com');

insertdormmanagementdata.insertstudent('Fraser Zaniolini', '(287) 6784872', '03-Jul-2000', 'M', 'FALSE',
                                           '978 Hoffman Alley', 'fzaniolini1k@taobao.com');

insertdormmanagementdata.insertstudent('Hadrian Gomme', '(142) 1903198', '05-Jan-2001', 'M', 'FALSE',
                                           '41051 Hintze Circle', 'hgomme1l@goo.gl');

insertdormmanagementdata.insertstudent('Babbette Dunmore', '(515) 3201767', '10-Apr-1996', 'F', 'FALSE',
                                           '3499 Longview Point', 'bdunmore1m@apple.com');

insertdormmanagementdata.insertstudent('Eugen Hember', '(168) 5941909', '09-Mar-1998', 'M', 'FALSE',
                                           '7 Warner Point', 'ehember1n@si.edu');

insertdormmanagementdata.insertstudent('Sioux Fletcher', '(952) 4104504', '31-Jul-1991', 'F', 'FALSE',
                                           '01 Magdeline Street', 'sfletcher1o@gmpg.org');

insertdormmanagementdata.insertstudent('Jermaine Oldam', '(897) 5583981', '10-Mar-1994', 'M', 'FALSE',
                                           '229 Village Green Street', 'joldam1p@goo.gl');

insertdormmanagementdata.insertstudent('Jenifer Gawthorp', '(381) 9456386', '15-May-2002', 'F', 'FALSE',
                                           '936 Linden Alley', 'jgawthorp1q@auda.org.au');

insertdormmanagementdata.insertstudent('Dominica Igglesden', '(186) 7694784', '24-Mar-2001', 'F', 'FALSE',
                                           '2739 Michigan Pass', 'digglesden1r@uol.com.br');

insertdormmanagementdata.insertstudent('Fergus Menham', '(787) 7921830', '15-Dec-2001', 'M', 'FALSE',
                                           '959 Toban Court', 'fmenham1s@virginia.edu');

insertdormmanagementdata.insertstudent('Derby Paris', '(174) 2816568', '06-Jun-2000', 'M', 'FALSE',
                                           '4 Towne Court', 'dparis1t@reddit.com');

insertdormmanagementdata.insertstudent('Emmy Assante', '(597) 6825765', '26-May-1997', 'F', 'FALSE',
                                           '88 Drewry Place', 'eassante1u@jiathis.com');

insertdormmanagementdata.insertstudent('Howey Kinkaid', '(564) 3797442', '11-Feb-2000', 'M', 'FALSE',
                                           '334 Gale Way', 'hkinkaid1v@elpais.com');

insertdormmanagementdata.insertstudent('Giana Hollington', '(988) 1191777', '11-Jun-1992', 'F', 'FALSE',
                                           '314 Lotheville Street', 'ghollington1w@icq.com');

insertdormmanagementdata.insertstudent('Ada Binder', '(500) 1538277', '19-Dec-1992', 'F', 'FALSE',
                                           '483 Ridge Oak Parkway', 'abinder1x@ustream.tv');

insertdormmanagementdata.insertstudent('Grace Phette', '(821) 1564720', '05-Apr-2000', 'M', 'FALSE',
                                           '05 Rusk Way', 'gphette1y@senate.gov');

insertdormmanagementdata.insertstudent('Jemima Hamsson', '(259) 3073001', '21-Nov-2000', 'F', 'FALSE',
                                           '7766 Cascade Street', 'jhamsson1z@histats.com');

insertdormmanagementdata.insertstudent('Jude Foye', '(648) 9063925', '28-Oct-1995', 'M', 'FALSE',
                                           '33 Bonner Pass', 'jfoye20@purevolume.com');

insertdormmanagementdata.insertstudent('Pryce Ughelli', '(446) 3332793', '21-Feb-2001', 'M', 'FALSE',
                                           '8 Dakota Road', 'pughelli21@ed.gov');

insertdormmanagementdata.insertstudent('Clywd Thirtle', '(440) 6969376', '13-Feb-1990', 'M', 'FALSE',
                                           '57918 Westend Road', 'cthirtle22@arizona.edu');

insertdormmanagementdata.insertstudent('Jenna Magill', '(676) 3692022', '11-Sep-1992', 'F', 'FALSE',
                                           '2116 Towne Road', 'jmagill23@edublogs.org');

insertdormmanagementdata.insertstudent('Sig Hick', '(830) 8772462', '19-Sep-2001', 'M', 'FALSE',
                                           '2037 Melvin Plaza', 'shick24@tripadvisor.com');

insertdormmanagementdata.insertstudent('Wilmer Peploe', '(706) 2907878', '27-Dec-1992', 'M', 'FALSE',
                                           '10870 Eagan Hill', 'wpeploe25@gravatar.com');

insertdormmanagementdata.insertstudent('Filmore Castelin', '(317) 9216012', '11-Jan-1991', 'M', 'FALSE',
                                           '4971 Declaration Place', 'fcastelin26@sourceforge.net');

insertdormmanagementdata.insertstudent('Kimmie Whitty', '(990) 6497566', '28-Mar-2001', 'F', 'FALSE',
                                           '50561 Quincy Circle', 'kwhitty27@sciencedaily.com');

insertdormmanagementdata.insertstudent('Aldrich Aldis', '(112) 6792871', '30-Apr-1990', 'M', 'FALSE',
                                           '06919 Leroy Lane', 'aaldis28@goo.gl');

insertdormmanagementdata.insertstudent('Clement Currall', '(758) 1076185', '28-Dec-1992', 'M', 'FALSE',
                                           '6234 Grim Street', 'ccurrall29@nydailynews.com');

insertdormmanagementdata.insertstudent('Washington Gobert', '(845) 8623610', '20-Sep-1994', 'M', 'FALSE',
                                           '004 Dovetail Point', 'wgobert2a@weather.com');

insertdormmanagementdata.insertstudent('Jase Turfin', '(359) 8444686', '05-Feb-1999', 'M', 'FALSE',
                                           '967 4th Center', 'jturfin2b@dailymail.co.uk');

insertdormmanagementdata.insertstudent('Roz Slott', '(259) 4039955', '17-Apr-1991', 'F', 'FALSE',
                                           '602 Amoth Street', 'rslott2c@pinterest.com');

insertdormmanagementdata.insertstudent('Clayborne Brusby', '(151) 1104275', '22-Jan-1996', 'M', 'FALSE',
                                           '27 Artisan Parkway', 'cbrusby2d@hc360.com');

insertdormmanagementdata.insertstudent('Kendal Origin', '(113) 9975147', '26-Jul-2001', 'M', 'FALSE',
                                           '4120 Vernon Hill', 'korigin2e@hao123.com');

insertdormmanagementdata.insertstudent('Cecily Cleife', '(816) 5871772', '12-Jan-1997', 'F', 'FALSE',
                                           '7 Pennsylvania Place', 'ccleife2f@bloomberg.com');

insertdormmanagementdata.insertstudent('Wake Shorey', '(412) 5277777', '03-Jan-1997', 'M', 'FALSE',
                                           '1 Ryan Trail', 'wshorey2g@house.gov');

insertdormmanagementdata.insertstudent('Brock Heaker', '(183) 8828692', '07-Jul-1994', 'M', 'FALSE',
                                           '09 Kennedy Place', 'bheaker2h@networkadvertising.org');

insertdormmanagementdata.insertstudent('Anya Walcar', '(463) 8639365', '05-Oct-2000', 'F', 'FALSE',
                                           '03 School Center', 'awalcar2i@independent.co.uk');

insertdormmanagementdata.insertstudent('Emelda Jonk', '(752) 3403014', '06-Dec-1991', 'F', 'FALSE',
                                           '4 Stuart Avenue', 'ejonk2j@omniture.com');

insertdormmanagementdata.insertstudent('Ediva Middup', '(102) 1812962', '10-Jun-1990', 'F', 'FALSE',
                                           '9168 Independence Drive', 'emiddup2k@simplemachines.org');

insertdormmanagementdata.insertstudent('Yorker Thirlwall', '(650) 7660751', '30-Apr-1990', 'M', 'FALSE',
                                           '2965 Thierer Plaza', 'ythirlwall2l@hp.com');

insertdormmanagementdata.insertstudent('Chauncey Karys', '(596) 7470614', '09-Aug-1996', 'M', 'FALSE',
                                           '61870 Bellgrove Drive', 'ckarys2m@ning.com');

insertdormmanagementdata.insertstudent('Katherina Clemot', '(728) 2089069', '30-Jul-1990', 'F', 'FALSE',
                                           '1077 Scott Plaza', 'kclemot2n@webnode.com');

insertdormmanagementdata.insertstudent('Royce Gellately', '(243) 2169667', '16-Aug-1995', 'M', 'FALSE',
                                           '72 Messerschmidt Avenue', 'rgellately2o@youku.com');

insertdormmanagementdata.insertstudent('Zebadiah Dowell', '(540) 3770243', '22-Dec-1992', 'M', 'FALSE',
                                           '41323 Delladonna Alley', 'zdowell2p@tripod.com');

insertdormmanagementdata.insertstudent('Ira Szimon', '(595) 3971248', '11-Jul-1996', 'M', 'FALSE',
                                           '8746 Nobel Alley', 'iszimon2q@cbc.ca');

insertdormmanagementdata.insertstudent('Corie Gibbieson', '(607) 6355516', '15-Jun-1992', 'F', 'FALSE',
                                           '773 Marcy Court', 'cgibbieson2r@com.com');

insertdormmanagementdata.insertstudent('Blakeley Radley', '(714) 1514911', '13-May-1997', 'F', 'FALSE',
                                           '2 Warner Terrace', 'bradley2s@google.com');

insertdormmanagementdata.insertstudent('Emmy Van der Spohr', '(187) 9516637', '28-May-1997', 'F', 'FALSE',
                                           '9804 Waywood Center', 'evan2t@vinaora.com');

insertdormmanagementdata.insertstudent('Natalee Munkton', '(518) 1912555', '19-Aug-1999', 'F', 'FALSE',
                                           '761 Raven Crossing', 'nmunkton2u@army.mil');

insertdormmanagementdata.insertstudent('Dulcine Kuschel', '(712) 4814584', '13-Apr-1995', 'F', 'FALSE',
                                           '3678 Maple Junction', 'dkuschel2v@springer.com');

insertdormmanagementdata.insertstudent('Nelli Creegan', '(742) 5929908', '01-Jul-2000', 'F', 'FALSE',
                                           '723 Stone Corner Junction', 'ncreegan2w@google.cn');

insertdormmanagementdata.insertstudent('Waverly Paddefield', '(725) 6486910', '21-Jun-1991', 'M', 'FALSE',
                                           '52 Bowman Avenue', 'wpaddefield2x@cyberchimps.com');

insertdormmanagementdata.insertstudent('Enrika Bukac', '(911) 8151008', '24-Dec-1991', 'F', 'FALSE',
                                           '79849 Riverside Point', 'ebukac2y@answers.com');

insertdormmanagementdata.insertstudent('Tommie Alforde', '(865) 5359595', '10-Feb-1991', 'M', 'FALSE',
                                           '70866 Longview Court', 'talforde2z@wordpress.com');

insertdormmanagementdata.insertstudent('Dirk Meah', '(516) 1149695', '04-Aug-2002', 'M', 'FALSE',
                                           '36 Becker Road', 'dmeah30@reference.com');

insertdormmanagementdata.insertstudent('Freddie Cattell', '(190) 1981517', '25-Feb-2002', 'F', 'FALSE',
                                           '8 Johnson Alley', 'fcattell31@t-online.de');

insertdormmanagementdata.insertstudent('Alyce Possell', '(213) 9877617', '15-Jun-1998', 'F', 'FALSE',
                                           '67 Clarendon Lane', 'apossell32@yahoo.com');

insertdormmanagementdata.insertstudent('Tamera Catcherside', '(560) 7431396', '03-Jul-1995', 'F', 'FALSE',
                                           '123 Dapin Avenue', 'tcatcherside33@storify.com');

insertdormmanagementdata.insertstudent('Eugenio Hayne', '(744) 4825929', '17-Jul-1995', 'M', 'FALSE',
                                           '7612 Grasskamp Center', 'ehayne34@eepurl.com');

insertdormmanagementdata.insertstudent('Babb Shadrack', '(837) 5784797', '12-Apr-2000', 'F', 'FALSE',
                                           '1585 Anderson Park', 'bshadrack35@tamu.edu');

insertdormmanagementdata.insertstudent('Kathi Powers', '(327) 6167397', '22-Mar-1991', 'F', 'FALSE',
                                           '2387 Kropf Trail', 'kpowers36@latimes.com');

insertdormmanagementdata.insertstudent('Gustaf Houtby', '(599) 7067873', '01-Mar-2000', 'M', 'FALSE',
                                           '4639 Jana Drive', 'ghoutby37@gmpg.org');

insertdormmanagementdata.insertstudent('Evan Muirhead', '(859) 6849213', '23-Feb-1994', 'M', 'FALSE',
                                           '7 Upham Lane', 'emuirhead38@techcrunch.com');

insertdormmanagementdata.insertstudent('Haze Maestrini', '(693) 9712146', '31-Jul-2001', 'M', 'FALSE',
                                           '35 Division Crossing', 'hmaestrini39@home.pl');

insertdormmanagementdata.insertstudent('Reagan Lifsey', '(678) 1727183', '10-Dec-1998', 'M', 'FALSE',
                                           '9 Dapin Terrace', 'rlifsey3a@wunderground.com');

insertdormmanagementdata.insertstudent('Lutero MacCarter', '(766) 9829453', '22-Jan-1990', 'M', 'FALSE',
                                           '01280 Loomis Court', 'lmaccarter3b@printfriendly.com');

insertdormmanagementdata.insertstudent('Ricard Peterffy', '(170) 9485871', '16-May-1992', 'M', 'FALSE',
                                           '49113 Russell Parkway', 'rpeterffy3c@huffingtonpost.com');

insertdormmanagementdata.insertstudent('Fionnula Mayward', '(124) 8512007', '18-May-1999', 'F', 'FALSE',
                                           '94 Beilfuss Parkway', 'fmayward3d@squidoo.com');

insertdormmanagementdata.insertstudent('Kerry Pardi', '(284) 4660595', '22-Apr-1996', 'M', 'FALSE',
                                           '2501 Graedel Plaza', 'kpardi3e@slideshare.net');

insertdormmanagementdata.insertstudent('Charla Wofenden', '(328) 3043439', '17-Nov-1994', 'F', 'FALSE',
                                           '799 Paget Road', 'cwofenden3f@dedecms.com');

insertdormmanagementdata.insertstudent('Eli Criag', '(538) 5615040', '03-Sep-1995', 'M', 'FALSE',
                                           '3 Canary Place', 'ecriag3g@guardian.co.uk');

insertdormmanagementdata.insertstudent('Di Tuckett', '(520) 8726590', '25-Jul-1998', 'F', 'FALSE',
                                           '5 Hovde Avenue', 'dtuckett3h@vkontakte.ru');

insertdormmanagementdata.insertstudent('Lovell Stansall', '(260) 4410085', '03-Nov-1999', 'M', 'FALSE',
                                           '88 Hermina Center', 'lstansall3i@cbslocal.com');

insertdormmanagementdata.insertstudent('Sheilah Caras', '(823) 4512848', '10-Jul-1991', 'F', 'FALSE',
                                           '880 Lakeland Street', 'scaras3j@dot.gov');

insertdormmanagementdata.insertstudent('Felicio Bogart', '(714) 4854876', '31-Jul-1994', 'M', 'FALSE',
                                           '191 Fair Oaks Terrace', 'fbogart3k@plala.or.jp');

insertdormmanagementdata.insertstudent('Remy Olivi', '(261) 3946918', '30-Oct-2002', 'F', 'FALSE',
                                           '24 Kenwood Avenue', 'rolivi3l@stumbleupon.com');

insertdormmanagementdata.insertstudent('Danie Armin', '(260) 5979826', '21-Feb-1992', 'M', 'FALSE',
                                           '37428 Armistice Trail', 'darmin3m@domainmarket.com');

insertdormmanagementdata.insertstudent('Donnajean McConaghy', '(353) 8914162', '30-May-1994', 'F', 'FALSE',
                                           '3289 Delaware Park', 'dmcconaghy3n@accuweather.com');

insertdormmanagementdata.insertstudent('Stephanie Lanbertoni', '(817) 2754858', '22-Apr-1993', 'F', 'FALSE',
                                           '9051 Florence Way', 'slanbertoni3o@hugedomains.com');

insertdormmanagementdata.insertstudent('Abbie Jaggi', '(146) 8347940', '18-Aug-2001', 'M', 'FALSE',
                                           '7554 Riverside Parkway', 'ajaggi3p@miitbeian.gov.cn');

insertdormmanagementdata.insertstudent('Ariadne Whetton', '(841) 4951310', '10-Apr-1990', 'F', 'FALSE',
                                           '75 Lakeland Center', 'awhetton3q@hud.gov');

insertdormmanagementdata.insertstudent('Natividad Flecknoe', '(972) 5963409', '16-Nov-2002', 'F', 'FALSE',
                                           '9879 Susan Junction', 'nflecknoe3r@jigsy.com');

insertdormmanagementdata.insertstudent('Martica Roft', '(782) 6923237', '21-Mar-1992', 'F', 'FALSE',
                                           '882 Moose Street', 'mroft3s@youku.com');

insertdormmanagementdata.insertstudent('Kiel Jimson', '(498) 9997132', '08-Feb-1994', 'M', 'FALSE',
                                           '8 Hagan Hill', 'kjimson3t@springer.com');

insertdormmanagementdata.insertstudent('Reeba Tiley', '(287) 1471086', '30-Sep-2000', 'F', 'FALSE',
                                           '39847 Main Road', 'rtiley3u@mac.com');

insertdormmanagementdata.insertstudent('Mariellen Peele', '(290) 5781063', '23-Jan-1991', 'F', 'FALSE',
                                           '100 Mosinee Road', 'mpeele3v@youtu.be');

insertdormmanagementdata.insertstudent('Ferris Newall', '(511) 4472399', '25-May-2001', 'M', 'FALSE',
                                           '53487 Ludington Way', 'fnewall3w@foxnews.com');

insertdormmanagementdata.insertstudent('Nissy Falkous', '(212) 7326352', '11-Jul-1990', 'F', 'FALSE',
                                           '72355 Welch Hill', 'nfalkous3x@cdc.gov');

insertdormmanagementdata.insertstudent('Mauricio Hurrion', '(923) 9350363', '05-Jul-2002', 'M', 'FALSE',
                                           '4270 Miller Trail', 'mhurrion3y@google.de');

insertdormmanagementdata.insertstudent('Sharleen Karys', '(170) 3187268', '24-Jul-1990', 'F', 'FALSE',
                                           '226 Graedel Crossing', 'skarys3z@mashable.com');

insertdormmanagementdata.insertstudent('Lucille Scad', '(179) 5410107', '21-Sep-1998', 'F', 'FALSE',
                                           '6702 Stephen Point', 'lscad40@wordpress.org');

insertdormmanagementdata.insertstudent('Frederik Swinfon', '(820) 3571598', '10-Oct-1991', 'M', 'FALSE',
                                           '81743 6th Road', 'fswinfon41@geocities.com');

insertdormmanagementdata.insertstudent('Archaimbaud Gilberthorpe', '(203) 6850880', '08-Sep-2001', 'M', 'FALSE',
                                           '70192 Milwaukee Crossing', 'agilberthorpe42@gov.uk');

insertdormmanagementdata.insertstudent('Lucio Swanson', '(699) 1312102', '31-Aug-1994', 'M', 'FALSE',
                                           '97296 Randy Junction', 'lswanson43@about.com');

insertdormmanagementdata.insertstudent('Jethro Sweetzer', '(867) 9521553', '30-Oct-1995', 'M', 'FALSE',
                                           '2 Cordelia Point', 'jsweetzer44@360.cn');

insertdormmanagementdata.insertstudent('Cindra Amy', '(511) 3096127', '08-Dec-2001', 'F', 'FALSE',
                                           '6835 Upham Center', 'camy45@telegraph.co.uk');

insertdormmanagementdata.insertstudent('Rochella Harriskine', '(538) 2675256', '24-Feb-2002', 'F', 'FALSE',
                                           '7 Algoma Plaza', 'rharriskine46@bizjournals.com');

insertdormmanagementdata.insertstudent('Ruggiero Malshinger', '(284) 9565662', '07-Jul-1992', 'M', 'FALSE',
                                           '166 Merry Avenue', 'rmalshinger47@topsy.com');

insertdormmanagementdata.insertstudent('Gordy Burcombe', '(887) 6580474', '16-Jul-1993', 'M', 'FALSE',
                                           '4378 Dawn Alley', 'gburcombe48@oakley.com');

insertdormmanagementdata.insertstudent('Maude Charlton', '(354) 6889699', '23-Jan-1992', 'F', 'FALSE',
                                           '3318 Lake View Crossing', 'mcharlton49@who.int');

insertdormmanagementdata.insertstudent('Annabelle Arnault', '(210) 7567063', '29-Jun-2000', 'F', 'FALSE',
                                           '0 Sauthoff Place', 'aarnault4a@slate.com');

insertdormmanagementdata.insertstudent('Marc Shevlane', '(961) 3244407', '17-Dec-1995', 'M', 'FALSE',
                                           '92064 Talisman Pass', 'mshevlane4b@squidoo.com');

insertdormmanagementdata.insertstudent('Shannon Matijevic', '(817) 1469106', '16-May-1996', 'M', 'FALSE',
                                           '8 Iowa Center', 'smatijevic4c@google.pl');

insertdormmanagementdata.insertstudent('Rene Keohane', '(811) 9058011', '17-Mar-1993', 'M', 'FALSE',
                                           '8579 Buhler Terrace', 'rkeohane4d@amazonaws.com');

insertdormmanagementdata.insertstudent('Phillida Cuell', '(712) 3130782', '10-Mar-1998', 'F', 'FALSE',
                                           '6074 Messerschmidt Center', 'pcuell4e@soundcloud.com');

insertdormmanagementdata.insertstudent('Aymer Focke', '(205) 8564789', '17-Aug-2000', 'M', 'FALSE',
                                           '62 Kingsford Lane', 'afocke4f@flavors.me');

insertdormmanagementdata.insertstudent('Kalil Davidowsky', '(404) 1740891', '30-Jul-1997', 'M', 'FALSE',
                                           '87 Corry Road', 'kdavidowsky4g@yellowpages.com');

insertdormmanagementdata.insertstudent('Augusta Lillford', '(545) 2645763', '01-Jan-1992', 'F', 'FALSE',
                                           '195 Sunfield Street', 'alillford4h@craigslist.org');

insertdormmanagementdata.insertstudent('Dylan Eddleston', '(875) 5879384', '14-Mar-2001', 'M', 'FALSE',
                                           '87004 John Wall Point', 'deddleston4i@admin.ch');

insertdormmanagementdata.insertstudent('Vanni Halley', '(165) 6219895', '02-Nov-2001', 'F', 'FALSE',
                                           '3495 Cardinal Plaza', 'vhalley4j@flickr.com');

insertdormmanagementdata.insertstudent('Fredra Brugh', '(202) 5019277', '03-Feb-1997', 'F', 'FALSE',
                                           '4 Old Gate Court', 'fbrugh4k@rambler.ru');

insertdormmanagementdata.insertstudent('Victoria Sauvain', '(827) 4507063', '05-May-1994', 'F', 'FALSE',
                                           '8 Sutteridge Pass', 'vsauvain4l@prweb.com');

insertdormmanagementdata.insertstudent('Victoir Delaney', '(514) 6379892', '26-Mar-1991', 'M', 'FALSE',
                                           '10 Fairview Street', 'vdelaney4m@kickstarter.com');

insertdormmanagementdata.insertstudent('Neville Esmonde', '(574) 6610432', '28-Aug-1995', 'M', 'FALSE',
                                           '062 Kingsford Pass', 'nesmonde4n@mapy.cz');

insertdormmanagementdata.insertstudent('Waylin Castledine', '(415) 8186976', '11-Jan-2000', 'M', 'FALSE',
                                           '0 Superior Pass', 'wcastledine4o@auda.org.au');

insertdormmanagementdata.insertstudent('Giorgio Pavel', '(428) 3996926', '25-Mar-1991', 'M', 'FALSE',
                                           '49373 Anderson Center', 'gpavel4p@canalblog.com');

insertdormmanagementdata.insertstudent('Clarie O''Teague', '(338) 6287704', '16-Dec-1998', 'F', 'FALSE',
                                           '29508 Hollow Ridge Place', 'coteague4q@nasa.gov');

insertdormmanagementdata.insertstudent('Vivi Scotchbrook', '(489) 6363125', '10-Dec-1996', 'F', 'FALSE',
                                           '99 Dryden Parkway', 'vscotchbrook4r@noaa.gov');

insertdormmanagementdata.insertstudent('Eloise Facchini', '(415) 7115026', '14-Aug-2001', 'F', 'FALSE',
                                           '8 Northwestern Crossing', 'efacchini4s@facebook.com');

insertdormmanagementdata.insertstudent('Jeane Steere', '(407) 8155041', '22-Mar-1992', 'F', 'FALSE',
                                           '52890 Cordelia Terrace', 'jsteere4t@msu.edu');

insertdormmanagementdata.insertstudent('Glynn Dugan', '(501) 8746232', '16-Sep-2000', 'M', 'FALSE',
                                           '6057 Swallow Lane', 'gdugan4u@nifty.com');

insertdormmanagementdata.insertstudent('Geraldine Defont', '(720) 6275064', '09-Jun-2001', 'F', 'FALSE',
                                           '1 Trailsway Plaza', 'gdefont4v@quantcast.com');

insertdormmanagementdata.insertstudent('Evan Clemendot', '(802) 1191532', '21-Jan-2000', 'M', 'FALSE',
                                           '8969 Scofield Street', 'eclemendot4w@quantcast.com');

insertdormmanagementdata.insertstudent('Roma Eltun', '(774) 4830394', '07-Dec-1993', 'M', 'FALSE',
                                           '29427 Delaware Court', 'reltun4x@prweb.com');

insertdormmanagementdata.insertstudent('Bryana Kingh', '(238) 5537489', '21-Sep-1995', 'F', 'FALSE',
                                           '3 Saint Paul Parkway', 'bkingh4y@quantcast.com');

insertdormmanagementdata.insertstudent('Reggie Hedley', '(945) 2356796', '26-Nov-1999', 'M', 'FALSE',
                                           '28466 Erie Way', 'rhedley4z@geocities.jp');

insertdormmanagementdata.insertstudent('Amalia MacConnel', '(437) 3124834', '17-Jan-1998', 'F', 'FALSE',
                                           '61 Lakewood Gardens Circle', 'amacconnel50@miitbeian.gov.cn');

insertdormmanagementdata.insertstudent('Rodolfo Gentle', '(573) 7477568', '07-Nov-1992', 'M', 'FALSE',
                                           '63440 Columbus Plaza', 'rgentle51@weibo.com');

insertdormmanagementdata.insertstudent('Nikolaus Limpricht', '(971) 3520252', '15-Oct-2001', 'M', 'FALSE',
                                           '1793 Moulton Trail', 'nlimpricht52@privacy.gov.au');

insertdormmanagementdata.insertstudent('Delores Gabbitis', '(138) 3590769', '08-Nov-1991', 'F', 'FALSE',
                                           '91 Cardinal Court', 'dgabbitis53@linkedin.com');

insertdormmanagementdata.insertstudent('Vernice Cruise', '(266) 5880510', '14-Apr-1991', 'F', 'FALSE',
                                           '2943 Butternut Street', 'vcruise54@cmu.edu');

insertdormmanagementdata.insertstudent('Levi Ramard', '(182) 6036735', '08-Aug-1995', 'M', 'FALSE',
                                           '51606 Redwing Point', 'lramard55@furl.net');

insertdormmanagementdata.insertstudent('Stacee Dollman', '(524) 9487423', '28-Jan-1998', 'M', 'FALSE',
                                           '460 Fremont Alley', 'sdollman56@twitter.com');

insertdormmanagementdata.insertstudent('Giffard Timblett', '(983) 4989698', '24-Sep-2000', 'M', 'FALSE',
                                           '8 Lawn Place', 'gtimblett57@dropbox.com');

insertdormmanagementdata.insertstudent('Gaylor Jarmyn', '(137) 3411224', '24-Nov-1995', 'M', 'FALSE',
                                           '4 Maple Terrace', 'gjarmyn58@studiopress.com');

insertdormmanagementdata.insertstudent('Marketa Brewis', '(296) 4911794', '01-Oct-2000', 'F', 'FALSE',
                                           '83 Sauthoff Circle', 'mbrewis59@mozilla.org');

insertdormmanagementdata.insertstudent('Victoir Cousens', '(534) 4641584', '02-May-1991', 'M', 'FALSE',
                                           '5994 Nobel Park', 'vcousens5a@ustream.tv');

insertdormmanagementdata.insertstudent('Mal O''Roan', '(467) 7136694', '31-Mar-1998', 'M', 'FALSE',
                                           '8 Meadow Valley Parkway', 'moroan5b@woothemes.com');

insertdormmanagementdata.insertstudent('Lin Hollingdale', '(855) 3861280', '26-Dec-1991', 'M', 'FALSE',
                                           '34117 Hoepker Alley', 'lhollingdale5c@cbslocal.com');

insertdormmanagementdata.insertstudent('Abbe Rosenblad', '(565) 6030373', '12-Apr-1999', 'F', 'FALSE',
                                           '891 Burning Wood Drive', 'arosenblad5d@barnesandnoble.com');

insertdormmanagementdata.insertstudent('Sherwood Willmore', '(232) 6896694', '10-Nov-1998', 'M', 'FALSE',
                                           '1843 Portage Road', 'swillmore5e@reuters.com');

insertdormmanagementdata.insertstudent('Lotti Micco', '(858) 4657547', '18-Feb-2000', 'F', 'FALSE',
                                           '43 Summer Ridge Park', 'lmicco5f@vk.com');

insertdormmanagementdata.insertstudent('Weider Burkart', '(987) 3684645', '29-Jan-1990', 'M', 'FALSE',
                                           '243 Pepper Wood Court', 'wburkart5g@jimdo.com');

insertdormmanagementdata.insertstudent('Annadiane Bramah', '(860) 5173626', '31-Mar-2000', 'F', 'FALSE',
                                           '14 Veith Junction', 'abramah5h@cargocollective.com');

insertdormmanagementdata.insertstudent('Selena Redit', '(620) 7226921', '02-May-1991', 'F', 'FALSE',
                                           '1 Pankratz Trail', 'sredit5i@cdc.gov');

insertdormmanagementdata.insertstudent('Hercule O''Moylane', '(464) 8946355', '15-Apr-1992', 'M', 'FALSE',
                                           '30 Pine View Terrace', 'homoylane5j@msu.edu');

insertdormmanagementdata.insertstudent('Alanah Priest', '(160) 3370671', '06-Apr-1993', 'F', 'FALSE',
                                           '84227 Arrowood Drive', 'apriest5k@blogs.com');

insertdormmanagementdata.insertstudent('Billie Haydney', '(476) 6398279', '17-Jul-1992', 'M', 'FALSE',
                                           '27311 Cherokee Lane', 'bhaydney5l@theatlantic.com');

insertdormmanagementdata.insertstudent('Nataline Puzey', '(769) 1438666', '17-Aug-1990', 'F', 'FALSE',
                                           '8642 Little Fleur Way', 'npuzey5m@soundcloud.com');

insertdormmanagementdata.insertstudent('Ardis Housin', '(563) 7564781', '24-Nov-1994', 'F', 'FALSE',
                                           '5 Vermont Terrace', 'ahousin5n@si.edu');

insertdormmanagementdata.insertstudent('Leeanne Linay', '(281) 3741149', '16-Jul-1990', 'F', 'FALSE',
                                           '864 Toban Trail', 'llinay5o@w3.org');

insertdormmanagementdata.insertstudent('Lorrie Giraudat', '(990) 5180014', '08-Oct-2001', 'M', 'FALSE',
                                           '27931 Green Point', 'lgiraudat5p@topsy.com');

insertdormmanagementdata.insertstudent('Raychel Helliwell', '(475) 4229569', '28-Oct-2002', 'F', 'FALSE',
                                           '6992 Longview Court', 'rhelliwell5q@constantcontact.com');

insertdormmanagementdata.insertstudent('Granville Twohig', '(309) 5321937', '17-Sep-1993', 'M', 'FALSE',
                                           '6120 Heffernan Circle', 'gtwohig5r@newyorker.com');

insertdormmanagementdata.insertstudent('Alan Tizard', '(520) 9997345', '27-Sep-1992', 'M', 'FALSE',
                                           '5 Dakota Alley', 'atizard5s@adobe.com');

insertdormmanagementdata.insertstudent('Denys Allard', '(408) 1377601', '06-Dec-1990', 'M', 'FALSE',
                                           '8520 Sullivan Center', 'dallard5t@bing.com');

insertdormmanagementdata.insertstudent('Jodi Thynn', '(631) 4536863', '17-Mar-1999', 'F', 'FALSE',
                                           '54 Twin Pines Road', 'jthynn5u@apple.com');

insertdormmanagementdata.insertstudent('Werner Edling', '(679) 3796243', '01-Jul-2000', 'M', 'FALSE',
                                           '38 Mifflin Place', 'wedling5v@weebly.com');

insertdormmanagementdata.insertstudent('Ugo Ten Broek', '(127) 6288846', '31-Jan-2002', 'M', 'FALSE',
                                           '225 Westerfield Place', 'uten5w@e-recht24.de');

insertdormmanagementdata.insertstudent('Emilee Bertwistle', '(110) 7161586', '28-May-1996', 'F', 'FALSE',
                                           '529 Monica Parkway', 'ebertwistle5x@meetup.com');

insertdormmanagementdata.insertstudent('Penelopa Balle', '(917) 7579671', '12-Feb-1998', 'F', 'FALSE',
                                           '2839 Cordelia Road', 'pballe5y@geocities.com');

insertdormmanagementdata.insertstudent('Kendricks Milbourne', '(297) 4918744', '09-Oct-1994', 'M', 'FALSE',
                                           '4771 Duke Park', 'kmilbourne5z@xrea.com');

insertdormmanagementdata.insertstudent('Yuri Drinkeld', '(635) 1641446', '16-Dec-1995', 'M', 'FALSE',
                                           '84 Moland Alley', 'ydrinkeld60@epa.gov');

insertdormmanagementdata.insertstudent('Lonni Loughead', '(324) 8571146', '05-May-1992', 'F', 'FALSE',
                                           '825 Springs Trail', 'lloughead61@myspace.com');

insertdormmanagementdata.insertstudent('Anallise Lippi', '(620) 6968060', '20-Jan-1991', 'F', 'FALSE',
                                           '2922 Armistice Street', 'alippi62@mashable.com');

insertdormmanagementdata.insertstudent('Velma Anthon', '(495) 1889219', '11-Aug-1997', 'F', 'FALSE',
                                           '77 Blue Bill Park Street', 'vanthon63@unc.edu');

insertdormmanagementdata.insertstudent('Ludvig Handke', '(441) 7551024', '11-Jan-1995', 'M', 'FALSE',
                                           '6 7th Junction', 'lhandke64@hhs.gov');

insertdormmanagementdata.insertstudent('Hana Oldroyde', '(218) 7513800', '20-Jul-1997', 'F', 'FALSE',
                                           '395 Haas Court', 'holdroyde65@yellowpages.com');

insertdormmanagementdata.insertstudent('Meriel Ivanenko', '(412) 8376533', '20-Aug-1999', 'F', 'FALSE',
                                           '45674 Morningstar Lane', 'mivanenko66@wired.com');

insertdormmanagementdata.insertstudent('Karlen Farnin', '(111) 9912753', '02-Sep-1996', 'F', 'FALSE',
                                           '08120 Thompson Street', 'kfarnin67@accuweather.com');

insertdormmanagementdata.insertstudent('Hillier Pead', '(541) 3988187', '30-Nov-1991', 'M', 'FALSE',
                                           '633 Warrior Circle', 'hpead68@squarespace.com');

insertdormmanagementdata.insertstudent('Donella Horsewood', '(716) 6262894', '16-Oct-1996', 'F', 'FALSE',
                                           '2 Kipling Trail', 'dhorsewood69@friendfeed.com');

insertdormmanagementdata.insertstudent('Seward Snarie', '(711) 9857622', '20-Aug-1997', 'M', 'FALSE',
                                           '5 Morning Park', 'ssnarie6a@redcross.org');

insertdormmanagementdata.insertstudent('Jasmina Finn', '(350) 3131132', '10-Apr-2002', 'F', 'FALSE',
                                           '85678 Oxford Junction', 'jfinn6b@apple.com');

insertdormmanagementdata.insertstudent('Tessie Tapper', '(332) 7005771', '06-Nov-2001', 'F', 'FALSE',
                                           '63557 Surrey Street', 'ttapper6c@thetimes.co.uk');

insertdormmanagementdata.insertstudent('Reed Fattori', '(881) 5448488', '18-Aug-2000', 'M', 'FALSE',
                                           '4 Homewood Drive', 'rfattori6d@odnoklassniki.ru');

insertdormmanagementdata.insertstudent('Steward Belfelt', '(936) 8201070', '11-Jun-2001', 'M', 'FALSE',
                                           '14909 Moulton Parkway', 'sbelfelt6e@livejournal.com');

insertdormmanagementdata.insertstudent('Shurlock Cosgreave', '(989) 6591978', '29-Aug-1992', 'M', 'FALSE',
                                           '88 Evergreen Drive', 'scosgreave6f@google.com.hk');

insertdormmanagementdata.insertstudent('Kaylil Lumpkin', '(942) 4762700', '08-Mar-1994', 'F', 'FALSE',
                                           '19525 Elka Trail', 'klumpkin6g@wired.com');

insertdormmanagementdata.insertstudent('Melina Northall', '(545) 1933700', '11-Feb-1994', 'F', 'FALSE',
                                           '601 Mesta Terrace', 'mnorthall6h@state.gov');

insertdormmanagementdata.insertstudent('Ulberto Henniger', '(380) 4345284', '04-Nov-1991', 'M', 'FALSE',
                                           '3905 Farragut Circle', 'uhenniger6i@bbb.org');

insertdormmanagementdata.insertstudent('Adelheid Urpeth', '(257) 8650391', '01-Nov-2000', 'F', 'FALSE',
                                           '6165 Coleman Park', 'aurpeth6j@yandex.ru');

insertdormmanagementdata.insertstudent('Martyn McCready', '(393) 2808663', '13-Jun-1990', 'M', 'FALSE',
                                           '0188 Manley Crossing', 'mmccready6k@diigo.com');

insertdormmanagementdata.insertstudent('Poul Strawbridge', '(227) 5472478', '03-Dec-2001', 'M', 'FALSE',
                                           '47260 Talmadge Lane', 'pstrawbridge6l@hugedomains.com');

insertdormmanagementdata.insertstudent('Barris Marskell', '(282) 5209562', '27-Feb-2002', 'M', 'FALSE',
                                           '8940 Independence Avenue', 'bmarskell6m@topsy.com');

insertdormmanagementdata.insertstudent('Valencia Drescher', '(403) 6982047', '04-Oct-1992', 'F', 'FALSE',
                                           '9588 Hagan Way', 'vdrescher6n@myspace.com');

insertdormmanagementdata.insertstudent('Anna-diane Domerc', '(312) 2987326', '28-Jun-1994', 'F', 'FALSE',
                                           '43875 Dixon Pass', 'adomerc6o@instagram.com');

insertdormmanagementdata.insertstudent('Roddy Iglesia', '(440) 6502608', '17-Aug-1995', 'M', 'FALSE',
                                           '59986 Oriole Way', 'riglesia6p@netlog.com');

insertdormmanagementdata.insertstudent('Juanita Johnston', '(452) 1201434', '09-Oct-1998', 'F', 'FALSE',
                                           '3 Quincy Street', 'jjohnston6q@stumbleupon.com');

insertdormmanagementdata.insertstudent('Wallas Bonevant', '(694) 1122816', '09-Jun-1991', 'M', 'FALSE',
                                           '264 Dapin Crossing', 'wbonevant6r@telegraph.co.uk');

insertdormmanagementdata.insertstudent('Dionisio Gainseford', '(978) 9399493', '02-Mar-1992', 'M', 'FALSE',
                                           '7761 Heath Hill', 'dgainseford6s@nih.gov');

insertdormmanagementdata.insertstudent('Celeste Attenburrow', '(878) 6449770', '20-Jul-2001', 'F', 'FALSE',
                                           '43 Schurz Plaza', 'cattenburrow6t@ca.gov');

insertdormmanagementdata.insertstudent('Waly Stilliard', '(546) 8812692', '01-Jun-1992', 'F', 'FALSE',
                                           '11 Bayside Crossing', 'wstilliard6u@geocities.jp');

insertdormmanagementdata.insertstudent('Giulietta Heisler', '(933) 6833694', '18-Mar-2001', 'F', 'FALSE',
                                           '04250 Katie Park', 'gheisler6v@plala.or.jp');

insertdormmanagementdata.insertstudent('Cal Pieche', '(184) 1480261', '21-Sep-1992', 'M', 'FALSE',
                                           '4 International Point', 'cpieche6w@nyu.edu');

insertdormmanagementdata.insertstudent('Saree Beri', '(349) 3881909', '27-Feb-1999', 'F', 'FALSE',
                                           '736 Birchwood Hill', 'sberi6x@exblog.jp');

insertdormmanagementdata.insertstudent('Harlan McRobbie', '(588) 4506009', '17-Jun-1991', 'M', 'FALSE',
                                           '267 Tony Center', 'hmcrobbie6y@123-reg.co.uk');

insertdormmanagementdata.insertstudent('Rozanne Dawley', '(342) 6304229', '17-Mar-1997', 'F', 'FALSE',
                                           '654 Luster Plaza', 'rdawley6z@hibu.com');

insertdormmanagementdata.insertstudent('Davey Trail', '(779) 3562528', '05-Dec-1990', 'M', 'FALSE',
                                           '8 Roxbury Street', 'dtrail70@virginia.edu');

insertdormmanagementdata.insertstudent('Sylvan Plume', '(664) 4489401', '20-Mar-1992', 'M', 'FALSE',
                                           '97786 Anniversary Court', 'splume71@deviantart.com');

insertdormmanagementdata.insertstudent('Maire Ortas', '(180) 6077087', '05-Jun-1998', 'F', 'FALSE',
                                           '878 Truax Drive', 'mortas72@redcross.org');

insertdormmanagementdata.insertstudent('Christean Pancast', '(536) 5841591', '20-Dec-2000', 'F', 'FALSE',
                                           '081 Fair Oaks Street', 'cpancast73@nyu.edu');

insertdormmanagementdata.insertstudent('Brock Weippert', '(931) 9520237', '17-May-1999', 'M', 'FALSE',
                                           '55 Morningstar Avenue', 'bweippert74@imdb.com');

insertdormmanagementdata.insertstudent('Phil Prantoni', '(276) 8284983', '18-Dec-1995', 'M', 'FALSE',
                                           '92 Sloan Place', 'pprantoni75@nps.gov');

insertdormmanagementdata.insertstudent('Inness Tackes', '(398) 4493740', '11-Dec-1992', 'M', 'FALSE',
                                           '1 Grover Crossing', 'itackes76@skype.com');

insertdormmanagementdata.insertstudent('Enoch Dik', '(961) 5511629', '19-Mar-1990', 'M', 'FALSE',
                                           '19 Carey Plaza', 'edik77@upenn.edu');

insertdormmanagementdata.insertstudent('Danella Harbour', '(522) 8445852', '05-Mar-2001', 'F', 'FALSE',
                                           '0472 Delladonna Plaza', 'dharbour78@ed.gov');

insertdormmanagementdata.insertstudent('Natal Toohey', '(741) 2557327', '05-Sep-2001', 'M', 'FALSE',
                                           '49 Thackeray Trail', 'ntoohey79@uol.com.br');

insertdormmanagementdata.insertstudent('Genni Oran', '(390) 2623867', '03-Jan-2002', 'F', 'FALSE',
                                           '9 Stuart Place', 'goran7a@umich.edu');

insertdormmanagementdata.insertstudent('Lilly Jumeau', '(610) 9957197', '05-May-1995', 'F', 'FALSE',
                                           '74974 Union Avenue', 'ljumeau7b@who.int');

insertdormmanagementdata.insertstudent('Zechariah Kurt', '(597) 3003363', '27-Apr-1994', 'M', 'FALSE',
                                           '327 Lerdahl Place', 'zkurt7c@va.gov');

insertdormmanagementdata.insertstudent('Carlin Carling', '(492) 5027110', '23-Sep-1993', 'M', 'FALSE',
                                           '51471 Lakeland Avenue', 'ccarling7d@homestead.com');

insertdormmanagementdata.insertstudent('Meggi Davidsohn', '(379) 1137642', '29-May-1998', 'F', 'FALSE',
                                           '81476 Oxford Pass', 'mdavidsohn7e@fda.gov');

insertdormmanagementdata.insertstudent('Amabel Borwick', '(494) 3347851', '29-May-2000', 'F', 'FALSE',
                                           '29806 Garrison Street', 'aborwick7f@1und1.de');

insertdormmanagementdata.insertstudent('Nolly Beazley', '(449) 1719176', '18-Nov-1999', 'M', 'FALSE',
                                           '2 Moland Circle', 'nbeazley7g@google.es');

insertdormmanagementdata.insertstudent('Syman Winspire', '(885) 7654496', '12-Aug-2001', 'M', 'FALSE',
                                           '47032 Service Drive', 'swinspire7h@diigo.com');

insertdormmanagementdata.insertstudent('Alonso Barbara', '(643) 2497019', '31-Jul-2000', 'M', 'FALSE',
                                           '4996 Manitowish Alley', 'abarbara7i@toplist.cz');

insertdormmanagementdata.insertstudent('Bondie Yabsley', '(587) 2303507', '21-Mar-1991', 'M', 'FALSE',
                                           '70983 Merrick Drive', 'byabsley7j@amazon.co.jp');

insertdormmanagementdata.insertstudent('Sonnie deKnevet', '(823) 9833659', '28-Aug-1993', 'F', 'FALSE',
                                           '12246 International Junction', 'sdeknevet7k@ehow.com');

insertdormmanagementdata.insertstudent('Graham Tattersdill', '(177) 8682010', '21-Sep-1995', 'M', 'FALSE',
                                           '705 Springview Parkway', 'gtattersdill7l@illinois.edu');

insertdormmanagementdata.insertstudent('Charis De Freyne', '(513) 4697261', '28-May-1993', 'F', 'FALSE',
                                           '21 Gulseth Street', 'cde7m@washingtonpost.com');

insertdormmanagementdata.insertstudent('Jermaine Odde', '(500) 3773406', '22-Nov-1991', 'F', 'FALSE',
                                           '199 Golf Crossing', 'jodde7n@domainmarket.com');

insertdormmanagementdata.insertstudent('Mariska Byrnes', '(947) 4068452', '04-Dec-1992', 'F', 'FALSE',
                                           '569 Almo Place', 'mbyrnes7o@ebay.com');

insertdormmanagementdata.insertstudent('Sindee Figgs', '(362) 1811309', '21-Apr-1997', 'F', 'FALSE',
                                           '9 Nevada Parkway', 'sfiggs7p@webeden.co.uk');

insertdormmanagementdata.insertstudent('Bartram Leefe', '(638) 1578409', '27-Feb-1991', 'M', 'FALSE',
                                           '9992 Utah Trail', 'bleefe7q@google.de');

insertdormmanagementdata.insertstudent('Christine Yanne', '(903) 6567504', '08-Apr-2001', 'F', 'FALSE',
                                           '9059 Carberry Crossing', 'cyanne7r@google.com');

insertdormmanagementdata.insertstudent('Heath Renyard', '(842) 5725151', '07-Jul-2000', 'F', 'FALSE',
                                           '7565 Sycamore Street', 'hrenyard7s@archive.org');

insertdormmanagementdata.insertstudent('Zacharias Semiraz', '(593) 1856288', '22-Dec-1993', 'M', 'FALSE',
                                           '5455 Gale Road', 'zsemiraz7t@npr.org');

insertdormmanagementdata.insertstudent('Nathanial Eustace', '(673) 5690457', '15-Jan-1992', 'M', 'FALSE',
                                           '0531 West Center', 'neustace7u@seattletimes.com');

insertdormmanagementdata.insertstudent('Janeczka Warratt', '(186) 2973289', '14-Nov-1998', 'F', 'FALSE',
                                           '62 Marquette Park', 'jwarratt7v@nature.com');

insertdormmanagementdata.insertstudent('Holden Hankin', '(329) 7171261', '18-Apr-1998', 'M', 'FALSE',
                                           '7 Browning Junction', 'hhankin7w@vistaprint.com');

insertdormmanagementdata.insertstudent('Willdon Skeels', '(371) 8259039', '20-Apr-1994', 'M', 'FALSE',
                                           '7 Swallow Street', 'wskeels7x@friendfeed.com');

insertdormmanagementdata.insertstudent('Darell Gilleon', '(529) 9173926', '31-May-2002', 'F', 'FALSE',
                                           '0 Homewood Center', 'dgilleon7y@cloudflare.com');

insertdormmanagementdata.insertstudent('Leighton Lott', '(457) 5706839', '16-Dec-2002', 'M', 'FALSE',
                                           '37881 Butterfield Court', 'llott7z@state.tx.us');

insertdormmanagementdata.insertstudent('Tori Augustus', '(165) 9068455', '17-Jan-1998', 'F', 'FALSE',
                                           '47 Dunning Alley', 'taugustus80@java.com');

insertdormmanagementdata.insertstudent('Grannie Rosser', '(252) 4790153', '19-Mar-1995', 'M', 'FALSE',
                                           '5 Shasta Drive', 'grosser81@diigo.com');

insertdormmanagementdata.insertstudent('Budd Brinded', '(948) 4030901', '25-Jun-1994', 'M', 'FALSE',
                                           '83106 Troy Lane', 'bbrinded82@mozilla.org');

insertdormmanagementdata.insertstudent('Eugen Ottee', '(641) 2770606', '24-Sep-2002', 'M', 'FALSE',
                                           '27133 Fremont Point', 'eottee83@usda.gov');

insertdormmanagementdata.insertstudent('Warden Gue', '(903) 4902013', '19-Nov-1996', 'M', 'FALSE',
                                           '7675 Anthes Center', 'wgue84@alexa.com');

insertdormmanagementdata.insertstudent('Mac Vittori', '(943) 8220453', '12-Mar-1993', 'M', 'FALSE',
                                           '3048 Bonner Hill', 'mvittori85@studiopress.com');

insertdormmanagementdata.insertstudent('Klaus Kerwen', '(985) 7586915', '02-Jul-1996', 'M', 'FALSE',
                                           '476 John Wall Parkway', 'kkerwen86@ocn.ne.jp');

insertdormmanagementdata.insertstudent('Chaddie Phant', '(110) 3639229', '27-Dec-1992', 'M', 'FALSE',
                                           '238 Kenwood Road', 'cphant87@blog.com');

insertdormmanagementdata.insertstudent('Matteo Mullin', '(783) 3121080', '18-Nov-1994', 'M', 'FALSE',
                                           '4789 Surrey Center', 'mmullin88@bbc.co.uk');

insertdormmanagementdata.insertstudent('Valerie Vaines', '(973) 7752392', '05-Sep-1995', 'F', 'FALSE',
                                           '5 Summerview Hill', 'vvaines89@yellowpages.com');

insertdormmanagementdata.insertstudent('Cher Skaife', '(686) 9904634', '08-Feb-2001', 'F', 'FALSE',
                                           '70723 Hudson Terrace', 'cskaife8a@rakuten.co.jp');

insertdormmanagementdata.insertstudent('Paulo Kauschke', '(475) 2756119', '29-Aug-1993', 'M', 'FALSE',
                                           '8161 Merchant Plaza', 'pkauschke8b@list-manage.com');

insertdormmanagementdata.insertstudent('Albrecht Blindt', '(697) 2424041', '02-Mar-1992', 'M', 'FALSE',
                                           '7 Farwell Hill', 'ablindt8c@cbslocal.com');

insertdormmanagementdata.insertstudent('Randie Lonsbrough', '(987) 3907170', '19-May-1994', 'M', 'FALSE',
                                           '1271 Warbler Hill', 'rlonsbrough8d@vinaora.com');

insertdormmanagementdata.insertstudent('Lauryn Lavender', '(122) 2356408', '05-Aug-2002', 'F', 'FALSE',
                                           '915 Nelson Alley', 'llavender8e@printfriendly.com');

insertdormmanagementdata.insertstudent('Clement Odger', '(763) 6115199', '25-Aug-1995', 'M', 'FALSE',
                                           '24515 Memorial Place', 'codger8f@jiathis.com');

insertdormmanagementdata.insertstudent('Findley Giraudou', '(574) 3197460', '30-Sep-1995', 'M', 'FALSE',
                                           '7527 Gateway Drive', 'fgiraudou8g@elpais.com');

insertdormmanagementdata.insertstudent('Regina Detoile', '(131) 4750185', '17-Sep-1993', 'F', 'FALSE',
                                           '169 Di Loreto Plaza', 'rdetoile8h@digg.com');

insertdormmanagementdata.insertstudent('Damien Antuoni', '(414) 6227280', '08-Jul-1997', 'M', 'FALSE',
                                           '434 Burning Wood Way', 'dantuoni8i@hubpages.com');

insertdormmanagementdata.insertstudent('Kirstin Jameson', '(652) 6205698', '28-Mar-2002', 'F', 'FALSE',
                                           '0 Acker Circle', 'kjameson8j@geocities.jp');

insertdormmanagementdata.insertstudent('Vaclav Gard', '(318) 8158594', '28-May-1992', 'M', 'FALSE',
                                           '4 Kedzie Avenue', 'vgard8k@i2i.jp');

insertdormmanagementdata.insertstudent('Marcello Constantine', '(283) 9409370', '06-Jan-1995', 'M', 'FALSE',
                                           '3 Rutledge Way', 'mconstantine8l@xrea.com');

insertdormmanagementdata.insertstudent('Roch Nendick', '(928) 6038135', '11-Oct-1992', 'F', 'FALSE',
                                           '6644 South Parkway', 'rnendick8m@dagondesign.com');

insertdormmanagementdata.insertstudent('Humfrey Davis', '(418) 4095129', '22-Jan-1992', 'M', 'FALSE',
                                           '170 Del Mar Drive', 'hdavis8n@seesaa.net');

insertdormmanagementdata.insertstudent('Des Bartlam', '(982) 5343516', '01-Jan-1995', 'M', 'FALSE',
                                           '011 Shelley Crossing', 'dbartlam8o@unc.edu');

insertdormmanagementdata.insertstudent('Drusie Siely', '(559) 3138685', '01-Oct-1998', 'F', 'FALSE',
                                           '50507 West Pass', 'dsiely8p@feedburner.com');

insertdormmanagementdata.insertstudent('Zia MacWhirter', '(722) 7531340', '14-Jul-1992', 'F', 'FALSE',
                                           '678 Sachs Court', 'zmacwhirter8q@sourceforge.net');

insertdormmanagementdata.insertstudent('Laurena Ibel', '(963) 2884209', '15-Oct-1993', 'F', 'FALSE',
                                           '95926 Bay Parkway', 'libel8r@nymag.com');

insertdormmanagementdata.insertstudent('Frans Van Halle', '(496) 5010278', '14-Jan-1997', 'M', 'FALSE',
                                           '45534 Sherman Junction', 'fvan8s@t-online.de');

insertdormmanagementdata.insertstudent('Tybi Keiley', '(674) 9883792', '14-Jun-2002', 'F', 'FALSE',
                                           '59 Laurel Drive', 'tkeiley8t@intel.com');

insertdormmanagementdata.insertstudent('Pall Janicki', '(720) 2225225', '26-Apr-1993', 'M', 'FALSE',
                                           '742 Fairview Parkway', 'pjanicki8u@slideshare.net');

insertdormmanagementdata.insertstudent('Bartholomew Collinette', '(462) 8916965', '10-Oct-2001', 'M', 'FALSE',
                                           '13720 Carpenter Drive', 'bcollinette8v@mtv.com');

insertdormmanagementdata.insertstudent('Pren Martinovsky', '(141) 8711109', '04-Jun-2001', 'M', 'FALSE',
                                           '4330 Claremont Point', 'pmartinovsky8w@samsung.com');

insertdormmanagementdata.insertstudent('Normie Larrosa', '(300) 8371007', '01-Feb-1995', 'M', 'FALSE',
                                           '65 Graedel Center', 'nlarrosa8x@mail.ru');

insertdormmanagementdata.insertstudent('Rad Tann', '(348) 7720469', '04-Jun-1994', 'M', 'FALSE',
                                           '38738 Harbort Avenue', 'rtann8y@artisteer.com');

insertdormmanagementdata.insertstudent('Stefanie Whoston', '(903) 8607695', '22-Mar-2001', 'F', 'FALSE',
                                           '54523 Oneill Drive', 'swhoston8z@mysql.com');

insertdormmanagementdata.insertstudent('Bayard Sweetnam', '(674) 6020988', '17-Jun-1996', 'M', 'FALSE',
                                           '8 Thierer Center', 'bsweetnam90@goo.ne.jp');

insertdormmanagementdata.insertstudent('Buddie Acey', '(473) 4836868', '21-Nov-2000', 'M', 'FALSE',
                                           '0097 Vernon Park', 'bacey91@youtube.com');

insertdormmanagementdata.insertstudent('Tine Jakubiak', '(645) 8522848', '28-Aug-1991', 'F', 'FALSE',
                                           '0 Fairview Trail', 'tjakubiak92@hatena.ne.jp');

insertdormmanagementdata.insertstudent('Adrienne Cullinane', '(341) 4830415', '20-Sep-1993', 'F', 'FALSE',
                                           '2 Independence Crossing', 'acullinane93@nasa.gov');

insertdormmanagementdata.insertstudent('Demetra MacQuaker', '(735) 7239858', '19-Oct-1990', 'F', 'FALSE',
                                           '37 Redwing Center', 'dmacquaker94@youtube.com');

insertdormmanagementdata.insertstudent('Kinsley Tod', '(423) 7373359', '04-May-1999', 'M', 'FALSE',
                                           '2 Golf Course Road', 'ktod95@prlog.org');

insertdormmanagementdata.insertstudent('Allie Gaskins', '(232) 6745257', '28-Jun-2002', 'M', 'FALSE',
                                           '416 Meadow Vale Parkway', 'agaskins96@ocn.ne.jp');

insertdormmanagementdata.insertstudent('De Poleykett', '(333) 4239129', '12-Dec-1992', 'F', 'FALSE',
                                           '43628 Orin Point', 'dpoleykett97@blogs.com');

insertdormmanagementdata.insertstudent('Allianora Domeney', '(507) 3714632', '06-Nov-1994', 'F', 'FALSE',
                                           '3298 Sachtjen Road', 'adomeney98@php.net');

insertdormmanagementdata.insertstudent('Marty Ogan', '(271) 1705483', '24-Feb-1992', 'M', 'FALSE',
                                           '97 Charing Cross Parkway', 'mogan99@cloudflare.com');

insertdormmanagementdata.insertstudent('Averill Pimblott', '(638) 4194005', '31-Jan-2002', 'M', 'FALSE',
                                           '7825 Heffernan Point', 'apimblott9a@google.pl');

insertdormmanagementdata.insertstudent('Ailyn Loades', '(800) 5902975', '10-Nov-1992', 'F', 'FALSE',
                                           '64784 Green Drive', 'aloades9b@slate.com');

insertdormmanagementdata.insertstudent('Kordula Gregoriou', '(526) 8430791', '23-Oct-1993', 'F', 'FALSE',
                                           '334 Tennessee Alley', 'kgregoriou9c@pinterest.com');

insertdormmanagementdata.insertstudent('Cello Dackombe', '(153) 1841438', '10-Feb-1994', 'M', 'FALSE',
                                           '646 Goodland Parkway', 'cdackombe9d@reverbnation.com');

insertdormmanagementdata.insertstudent('Giorgio McElwee', '(921) 9757934', '09-Feb-1999', 'M', 'FALSE',
                                           '09288 Spaight Way', 'gmcelwee9e@sun.com');

insertdormmanagementdata.insertstudent('Grange Marrett', '(132) 2459255', '21-Jul-1996', 'M', 'FALSE',
                                           '8259 Clemons Hill', 'gmarrett9f@free.fr');

insertdormmanagementdata.insertstudent('Pepe Rowan', '(276) 3127839', '08-May-1992', 'M', 'FALSE',
                                           '01 Oakridge Park', 'prowan9g@nhs.uk');

insertdormmanagementdata.insertstudent('Gavin Bletsoe', '(664) 5374393', '11-Aug-1992', 'M', 'FALSE',
                                           '71621 Graedel Parkway', 'gbletsoe9h@rakuten.co.jp');

insertdormmanagementdata.insertstudent('Wilfrid Chelley', '(551) 5515127', '14-May-1990', 'M', 'FALSE',
                                           '1515 Kingsford Point', 'wchelley9i@sphinn.com');

insertdormmanagementdata.insertstudent('Torie Leachman', '(405) 7871082', '28-Jun-1990', 'F', 'FALSE',
                                           '456 Eastlawn Point', 'tleachman9j@dmoz.org');

insertdormmanagementdata.insertstudent('Teador Hazelby', '(878) 5978111', '11-Jan-1999', 'M', 'FALSE',
                                           '127 Victoria Point', 'thazelby9k@exblog.jp');

insertdormmanagementdata.insertstudent('Rory Kohring', '(664) 6861980', '28-Jan-1999', 'M', 'FALSE',
                                           '90 Shasta Place', 'rkohring9l@sphinn.com');

insertdormmanagementdata.insertstudent('Eileen Gert', '(626) 1028110', '03-Aug-2000', 'F', 'FALSE',
                                           '608 Ruskin Road', 'egert9m@umn.edu');

insertdormmanagementdata.insertstudent('Bridie Kirkpatrick', '(175) 2813236', '20-Dec-1999', 'F', 'FALSE',
                                           '68956 Scott Junction', 'bkirkpatrick9n@usnews.com');

insertdormmanagementdata.insertstudent('Noreen Larmour', '(218) 6456984', '21-Feb-1997', 'F', 'FALSE',
                                           '925 Dawn Drive', 'nlarmour9o@bigcartel.com');

insertdormmanagementdata.insertstudent('Jefferey Reeman', '(965) 9550759', '15-Jun-2000', 'M', 'FALSE',
                                           '262 Little Fleur Plaza', 'jreeman9p@theatlantic.com');

insertdormmanagementdata.insertstudent('Tersina Priestman', '(857) 2397300', '18-Dec-1996', 'F', 'FALSE',
                                           '5779 Graedel Place', 'tpriestman9q@alibaba.com');

insertdormmanagementdata.insertstudent('Babette Stepto', '(733) 1232641', '22-Jun-1994', 'F', 'FALSE',
                                           '5 Ludington Court', 'bstepto9r@princeton.edu');

insertdormmanagementdata.insertstudent('Gretal Parsand', '(512) 5674885', '07-Jun-1998', 'F', 'FALSE',
                                           '9066 Luster Lane', 'gparsand9s@woothemes.com');

insertdormmanagementdata.insertstudent('Richie Skitt', '(737) 2052671', '13-May-1991', 'M', 'FALSE',
                                           '927 Debs Plaza', 'rskitt9t@engadget.com');

insertdormmanagementdata.insertstudent('Darsey Marunchak', '(305) 9232176', '14-Apr-2002', 'F', 'FALSE',
                                           '6335 2nd Circle', 'dmarunchak9u@ovh.net');

insertdormmanagementdata.insertstudent('Ainsley Habard', '(868) 3661194', '29-Jun-1993', 'F', 'FALSE',
                                           '974 Northridge Street', 'ahabard9v@admin.ch');

insertdormmanagementdata.insertstudent('Chaddy Figgess', '(623) 9761517', '12-May-1991', 'M', 'FALSE',
                                           '4 Dexter Way', 'cfiggess9w@amazon.co.uk');

insertdormmanagementdata.insertstudent('Deina Craze', '(673) 7766221', '26-Jul-2000', 'F', 'FALSE',
                                           '13617 Oak Valley Place', 'dcraze9x@cornell.edu');

insertdormmanagementdata.insertstudent('Odilia Trymme', '(742) 6992625', '31-Mar-1998', 'F', 'FALSE',
                                           '8 Bartillon Drive', 'otrymme9y@state.tx.us');

insertdormmanagementdata.insertstudent('Cesar Khadir', '(140) 7264936', '28-Jan-1998', 'M', 'FALSE',
                                           '1 Bluestem Road', 'ckhadir9z@virginia.edu');

insertdormmanagementdata.insertstudent('Sinclare Wahncke', '(858) 7033280', '12-Dec-1995', 'M', 'FALSE',
                                           '0 Straubel Pass', 'swahnckea0@multiply.com');

insertdormmanagementdata.insertstudent('Jacqui Kearle', '(118) 4717100', '25-May-1991', 'F', 'FALSE',
                                           '0008 Tomscot Drive', 'jkearlea1@seesaa.net');

insertdormmanagementdata.insertstudent('Gregoor Faircliffe', '(471) 5160528', '06-Sep-1994', 'M', 'FALSE',
                                           '0837 Arrowood Street', 'gfaircliffea2@techcrunch.com');

insertdormmanagementdata.insertstudent('Merilee Terzza', '(782) 9713239', '22-Mar-1995', 'F', 'FALSE',
                                           '10 Miller Alley', 'mterzzaa3@wikipedia.org');

insertdormmanagementdata.insertstudent('Conn Claiton', '(686) 5034734', '22-Aug-1998', 'M', 'FALSE',
                                           '43 Hoard Drive', 'cclaitona4@nasa.gov');

insertdormmanagementdata.insertstudent('Ardine Bartle', '(522) 8477813', '07-Feb-1998', 'F', 'FALSE',
                                           '034 Delaware Hill', 'abartlea5@dedecms.com');

insertdormmanagementdata.insertstudent('Elsworth Beachamp', '(406) 3657348', '04-Oct-1991', 'M', 'FALSE',
                                           '245 Service Lane', 'ebeachampa6@alexa.com');

insertdormmanagementdata.insertstudent('Dominic Nottingham', '(285) 6674925', '19-Apr-1998', 'M', 'FALSE',
                                           '2 Magdeline Pass', 'dnottinghama7@alibaba.com');

insertdormmanagementdata.insertstudent('Gun Crossthwaite', '(760) 1867467', '09-Nov-1993', 'M', 'FALSE',
                                           '58443 Nobel Place', 'gcrossthwaitea8@squarespace.com');

insertdormmanagementdata.insertstudent('Hewitt Eayres', '(485) 6781764', '24-Apr-2000', 'M', 'FALSE',
                                           '877 Farragut Junction', 'heayresa9@jiathis.com');

insertdormmanagementdata.insertstudent('Syd Merrall', '(169) 6219530', '14-Jun-1999', 'M', 'FALSE',
                                           '8 Goodland Place', 'smerrallaa@guardian.co.uk');

insertdormmanagementdata.insertstudent('Opalina Gregon', '(369) 6455881', '20-May-1992', 'F', 'FALSE',
                                           '3 Grover Terrace', 'ogregonab@godaddy.com');

insertdormmanagementdata.insertstudent('Irina Yurlov', '(472) 1989475', '02-Oct-1992', 'F', 'FALSE',
                                           '144 Magdeline Alley', 'iyurlovac@usgs.gov');

insertdormmanagementdata.insertstudent('Gillian Lias', '(475) 2559088', '28-Apr-1991', 'F', 'FALSE',
                                           '93 1st Alley', 'gliasad@intel.com');

insertdormmanagementdata.insertstudent('Jamie Ishchenko', '(794) 9931605', '14-Oct-1997', 'M', 'FALSE',
                                           '99 Trailsway Circle', 'jishchenkoae@yahoo.com');

insertdormmanagementdata.insertstudent('Eydie Longmaid', '(558) 2862684', '19-Dec-1992', 'F', 'FALSE',
                                           '22936 Commercial Trail', 'elongmaidaf@about.com');

insertdormmanagementdata.insertstudent('Jan Jekyll', '(681) 6539743', '17-May-2000', 'F', 'FALSE',
                                           '3341 Glendale Terrace', 'jjekyllag@digg.com');

insertdormmanagementdata.insertstudent('Anabella Bertholin', '(942) 5860269', '10-Nov-1994', 'F', 'FALSE',
                                           '4543 Colorado Road', 'abertholinah@free.fr');

insertdormmanagementdata.insertstudent('Emily Hildred', '(583) 6001523', '18-May-1996', 'F', 'FALSE',
                                           '9 Stuart Terrace', 'ehildredai@canalblog.com');

insertdormmanagementdata.insertstudent('Inna Brasseur', '(219) 9926686', '03-May-1991', 'F', 'FALSE',
                                           '0 Golf View Way', 'ibrasseuraj@mediafire.com');

insertdormmanagementdata.insertstudent('Ileane Currin', '(512) 9867687', '27-Mar-2001', 'F', 'FALSE',
                                           '8 Heath Terrace', 'icurrinak@washington.edu');

insertdormmanagementdata.insertstudent('Arline Burgyn', '(244) 4048371', '02-Jul-2002', 'F', 'FALSE',
                                           '6260 Bowman Way', 'aburgynal@dell.com');

insertdormmanagementdata.insertstudent('Sawyer Boyer', '(279) 5309513', '20-Mar-1998', 'M', 'FALSE',
                                           '36880 Menomonie Center', 'sboyeram@miitbeian.gov.cn');

insertdormmanagementdata.insertstudent('Saundra Vasyatkin', '(224) 4768765', '10-Apr-1998', 'M', 'FALSE',
                                           '45179 Cambridge Way', 'svasyatkinan@wufoo.com');

insertdormmanagementdata.insertstudent('Minor McGroarty', '(502) 5296605', '13-Jan-1994', 'M', 'FALSE',
                                           '711 Blue Bill Park Trail', 'mmcgroartyao@vimeo.com');

insertdormmanagementdata.insertstudent('Hope Antoniak', '(429) 5838476', '01-Dec-2002', 'F', 'FALSE',
                                           '1 Dunning Park', 'hantoniakap@squidoo.com');

insertdormmanagementdata.insertstudent('Cleveland Crimes', '(502) 7471782', '01-Nov-1990', 'M', 'FALSE',
                                           '71287 Dawn Plaza', 'ccrimesaq@wix.com');

insertdormmanagementdata.insertstudent('Betsey Mulvany', '(719) 8676203', '03-Nov-1990', 'F', 'FALSE',
                                           '676 Cottonwood Parkway', 'bmulvanyar@taobao.com');

insertdormmanagementdata.insertstudent('Hurlee Karpeev', '(266) 1601190', '25-Mar-1991', 'M', 'FALSE',
                                           '8 Glendale Circle', 'hkarpeevas@bloglines.com');

insertdormmanagementdata.insertstudent('Bradley Caines', '(260) 8022279', '11-Oct-1995', 'M', 'FALSE',
                                           '15 Thierer Road', 'bcainesat@infoseek.co.jp');

insertdormmanagementdata.insertstudent('Fara Sofe', '(552) 8111258', '20-Nov-1997', 'F', 'FALSE',
                                           '70 Graceland Pass', 'fsofeau@gnu.org');

insertdormmanagementdata.insertstudent('Othello Minney', '(629) 1840981', '05-Jan-1990', 'M', 'FALSE',
                                           '72 Towne Center', 'ominneyav@berkeley.edu');

insertdormmanagementdata.insertstudent('Selestina Manes', '(438) 6763746', '21-Nov-1991', 'F', 'FALSE',
                                           '2874 Northfield Hill', 'smanesaw@usatoday.com');

insertdormmanagementdata.insertstudent('Willem Vizor', '(287) 8187668', '31-May-2002', 'M', 'FALSE',
                                           '6882 Esker Center', 'wvizorax@zimbio.com');

insertdormmanagementdata.insertstudent('Olivie Drysdall', '(668) 8727697', '02-Oct-1994', 'F', 'FALSE',
                                           '330 Portage Junction', 'odrysdallay@ow.ly');

insertdormmanagementdata.insertstudent('Tillie Hickisson', '(859) 4428176', '06-Jul-1995', 'F', 'FALSE',
                                           '3 Springs Junction', 'thickissonaz@wufoo.com');

insertdormmanagementdata.insertstudent('Antoine Smoth', '(472) 6418173', '27-Feb-1995', 'M', 'FALSE',
                                           '7 Village Alley', 'asmothb0@nhs.uk');

insertdormmanagementdata.insertstudent('Chloris Blackbourn', '(805) 4327524', '26-Dec-2002', 'F', 'FALSE',
                                           '52 South Place', 'cblackbournb1@aboutads.info');

insertdormmanagementdata.insertstudent('Elita Bour', '(897) 7009882', '31-Dec-1993', 'F', 'FALSE',
                                           '549 Forster Crossing', 'ebourb2@senate.gov');

insertdormmanagementdata.insertstudent('Courtenay Ewins', '(187) 9391643', '01-Jul-1995', 'F', 'FALSE',
                                           '9011 Swallow Road', 'cewinsb3@unc.edu');

insertdormmanagementdata.insertstudent('Noak Antoshin', '(793) 9633168', '21-Apr-2000', 'M', 'FALSE',
                                           '4616 Rigney Junction', 'nantoshinb4@spotify.com');

insertdormmanagementdata.insertstudent('Der Duckering', '(448) 8626567', '23-Jun-2002', 'M', 'FALSE',
                                           '4113 Mallory Terrace', 'dduckeringb5@nydailynews.com');

insertdormmanagementdata.insertstudent('Kimble Corona', '(880) 2362964', '12-Sep-1998', 'M', 'FALSE',
                                           '02 Green Terrace', 'kcoronab6@photobucket.com');

insertdormmanagementdata.insertstudent('Minnnie Offin', '(403) 2148905', '14-Oct-1999', 'F', 'FALSE',
                                           '557 Larry Trail', 'moffinb7@state.tx.us');

insertdormmanagementdata.insertstudent('Shea Lysaght', '(469) 4605720', '26-Feb-2001', 'F', 'FALSE',
                                           '380 Granby Lane', 'slysaghtb8@cmu.edu');

insertdormmanagementdata.insertstudent('Josie Geri', '(376) 7923802', '10-May-1993', 'F', 'FALSE',
                                           '72 Spenser Way', 'jgerib9@arizona.edu');

insertdormmanagementdata.insertstudent('Cecilius Connett', '(265) 3996730', '12-Oct-1993', 'M', 'FALSE',
                                           '1 Judy Court', 'cconnettba@army.mil');

insertdormmanagementdata.insertstudent('Sascha MacCrosson', '(146) 9063717', '03-Aug-1999', 'M', 'FALSE',
                                           '08986 Commercial Alley', 'smaccrossonbb@histats.com');

insertdormmanagementdata.insertstudent('Gloriana Bottlestone', '(505) 6790352', '17-Sep-1990', 'F', 'FALSE',
                                           '93588 Bartillon Crossing', 'gbottlestonebc@google.it');

insertdormmanagementdata.insertstudent('Moira Gratton', '(286) 3046919', '15-Apr-2002', 'F', 'FALSE',
                                           '4 Steensland Avenue', 'mgrattonbd@biglobe.ne.jp');

insertdormmanagementdata.insertstudent('Saxon Standen', '(508) 6094746', '10-Oct-1990', 'M', 'FALSE',
                                           '2590 Jenifer Parkway', 'sstandenbe@sina.com.cn');

insertdormmanagementdata.insertstudent('Garvy Sleight', '(928) 1472072', '29-Jan-1994', 'M', 'FALSE',
                                           '7 Spohn Court', 'gsleightbf@un.org');

insertdormmanagementdata.insertstudent('Lester Wisedale', '(300) 2943448', '03-Apr-1993', 'M', 'FALSE',
                                           '49397 Sullivan Hill', 'lwisedalebg@creativecommons.org');

insertdormmanagementdata.insertstudent('Duffy McCarver', '(589) 9985278', '15-Apr-1993', 'M', 'FALSE',
                                           '4 Rieder Hill', 'dmccarverbh@discovery.com');

insertdormmanagementdata.insertstudent('Darnell Marks', '(267) 1987512', '16-Apr-1994', 'M', 'FALSE',
                                           '0123 Brown Street', 'dmarksbi@rediff.com');

insertdormmanagementdata.insertstudent('Felizio Foker', '(133) 5987747', '14-Sep-1995', 'M', 'FALSE',
                                           '50 2nd Drive', 'ffokerbj@alibaba.com');

insertdormmanagementdata.insertstudent('Effie Hearnes', '(806) 3455618', '08-Jan-1993', 'F', 'FALSE',
                                           '10195 Toban Way', 'ehearnesbk@hud.gov');

insertdormmanagementdata.insertstudent('Jarrod Ellard', '(467) 4229310', '10-Dec-1990', 'M', 'FALSE',
                                           '34831 Pawling Court', 'jellardbl@slashdot.org');

insertdormmanagementdata.insertstudent('Dianne Lundon', '(917) 8083975', '06-Jul-2000', 'F', 'FALSE',
                                           '78372 Marcy Place', 'dlundonbm@phpbb.com');

insertdormmanagementdata.insertstudent('Herbie Dugget', '(752) 8303732', '08-Dec-1999', 'M', 'FALSE',
                                           '7 Golden Leaf Park', 'hduggetbn@netvibes.com');

insertdormmanagementdata.insertstudent('Opalina Rowlett', '(744) 8038334', '03-Nov-1991', 'F', 'FALSE',
                                           '186 American Place', 'orowlettbo@dedecms.com');

insertdormmanagementdata.insertstudent('Phylys Haliburton', '(311) 6487142', '12-Dec-1999', 'F', 'FALSE',
                                           '2730 Graceland Circle', 'phaliburtonbp@wordpress.com');

insertdormmanagementdata.insertstudent('Murry Cuerda', '(510) 8559727', '05-Jun-1993', 'M', 'FALSE',
                                           '7 Vahlen Point', 'mcuerdabq@illinois.edu');

insertdormmanagementdata.insertstudent('Creight McGibbon', '(141) 3014927', '08-Oct-1997', 'M', 'FALSE',
                                           '71 Division Park', 'cmcgibbonbr@go.com');

insertdormmanagementdata.insertstudent('Colan Dawkins', '(986) 1223092', '09-Mar-1990', 'M', 'FALSE',
                                           '25 Bashford Parkway', 'cdawkinsbs@oracle.com');

insertdormmanagementdata.insertstudent('Nefen Duplain', '(321) 5970435', '09-May-1995', 'M', 'FALSE',
                                           '40785 Westport Alley', 'nduplainbt@pagesperso-orange.fr');

insertdormmanagementdata.insertstudent('Bert Alcott', '(548) 4507888', '29-Jun-1990', 'M', 'FALSE',
                                           '450 Farwell Circle', 'balcottbu@fema.gov');

insertdormmanagementdata.insertstudent('Linc Brownett', '(815) 2937737', '22-Feb-1991', 'M', 'FALSE',
                                           '46729 Bashford Street', 'lbrownettbv@stanford.edu');

insertdormmanagementdata.insertstudent('Dasya Jaffrey', '(867) 3199780', '15-Feb-1993', 'F', 'FALSE',
                                           '0395 Ridgeway Hill', 'djaffreybw@unesco.org');

insertdormmanagementdata.insertstudent('Douglass Holah', '(768) 4985482', '12-Jun-1990', 'M', 'FALSE',
                                           '968 Larry Parkway', 'dholahbx@xing.com');

insertdormmanagementdata.insertstudent('Hussein Paule', '(275) 3043918', '29-Dec-1998', 'M', 'FALSE',
                                           '60771 Marquette Place', 'hpauleby@angelfire.com');

insertdormmanagementdata.insertstudent('Bax Edgerly', '(283) 1120390', '11-Feb-1990', 'M', 'FALSE',
                                           '49000 Forster Crossing', 'bedgerlybz@ed.gov');

insertdormmanagementdata.insertstudent('Arin Francecione', '(115) 2413533', '03-Jun-2000', 'M', 'FALSE',
                                           '18 Green Ridge Place', 'afrancecionec0@behance.net');

insertdormmanagementdata.insertstudent('Danielle Woollett', '(421) 8616349', '15-Apr-1998', 'F', 'FALSE',
                                           '6 Becker Drive', 'dwoollettc1@mac.com');

insertdormmanagementdata.insertstudent('Marcelo Keneleyside', '(160) 8162573', '29-Dec-1997', 'M', 'FALSE',
                                           '7694 Wayridge Lane', 'mkeneleysidec2@bravesites.com');

insertdormmanagementdata.insertstudent('Roderigo Filson', '(337) 6890432', '26-May-1995', 'M', 'FALSE',
                                           '357 Graedel Junction', 'rfilsonc3@joomla.org');

insertdormmanagementdata.insertstudent('Gardiner Dulwitch', '(544) 8740487', '04-Sep-1992', 'M', 'FALSE',
                                           '0 Bunker Hill Lane', 'gdulwitchc4@technorati.com');

insertdormmanagementdata.insertstudent('Eugenio De Cruze', '(525) 4963919', '01-Nov-2001', 'M', 'FALSE',
                                           '4 Longview Drive', 'edec5@github.io');

insertdormmanagementdata.insertstudent('Mozes Astridge', '(530) 6849085', '17-Aug-2002', 'M', 'FALSE',
                                           '1810 Sherman Plaza', 'mastridgec6@histats.com');

insertdormmanagementdata.insertstudent('Kingsley Ericsson', '(157) 4756381', '08-Mar-2000', 'M', 'FALSE',
                                           '9 Buhler Circle', 'kericssonc7@opera.com');

insertdormmanagementdata.insertstudent('Fanni Akerman', '(974) 2578655', '26-May-2000', 'F', 'FALSE',
                                           '07878 Drewry Pass', 'fakermanc8@sun.com');

insertdormmanagementdata.insertstudent('Chelsie Koeppe', '(833) 9265868', '28-Feb-1991', 'F', 'FALSE',
                                           '523 Ohio Plaza', 'ckoeppec9@china.com.cn');

insertdormmanagementdata.insertstudent('Alice Chedgey', '(490) 9999259', '02-May-1991', 'F', 'FALSE',
                                           '08145 Pearson Lane', 'achedgeyca@weibo.com');

insertdormmanagementdata.insertstudent('Marius Tritton', '(849) 2669436', '20-Feb-1993', 'M', 'FALSE',
                                           '64285 Vera Way', 'mtrittoncb@sina.com.cn');

insertdormmanagementdata.insertstudent('Pauline Sandry', '(135) 7664751', '12-Feb-1990', 'F', 'FALSE',
                                           '85924 Eagle Crest Road', 'psandrycc@usgs.gov');

insertdormmanagementdata.insertstudent('Arv Steenson', '(933) 8719150', '23-Dec-1998', 'M', 'FALSE',
                                           '059 Scott Court', 'asteensoncd@yellowpages.com');

insertdormmanagementdata.insertstudent('Brina Muckeen', '(821) 6053049', '17-Mar-1990', 'F', 'FALSE',
                                           '2842 1st Place', 'bmuckeence@baidu.com');

insertdormmanagementdata.insertstudent('Loella Asif', '(574) 2991875', '03-Sep-2002', 'F', 'FALSE',
                                           '8311 Schmedeman Point', 'lasifcf@nationalgeographic.com');

insertdormmanagementdata.insertstudent('Konstantine Bilham', '(297) 1240946', '18-Nov-1990', 'M', 'FALSE',
                                           '7597 Shasta Point', 'kbilhamcg@unblog.fr');

insertdormmanagementdata.insertstudent('Garry Huxley', '(186) 4736273', '21-Jan-2002', 'M', 'FALSE',
                                           '0 West Court', 'ghuxleych@sogou.com');

insertdormmanagementdata.insertstudent('Leroy Tunstall', '(575) 2200541', '07-Jan-2002', 'M', 'FALSE',
                                           '99 Nancy Trail', 'ltunstallci@tiny.cc');

insertdormmanagementdata.insertstudent('Shamus McIan', '(766) 1396169', '18-Feb-1992', 'M', 'FALSE',
                                           '1840 Randy Avenue', 'smciancj@ovh.net');

insertdormmanagementdata.insertstudent('Barbara Dowbiggin', '(315) 7433890', '21-May-1990', 'F', 'FALSE',
                                           '75 Portage Alley', 'bdowbigginck@privacy.gov.au');

insertdormmanagementdata.insertstudent('Laurence Bilsford', '(978) 1555725', '16-Jul-1996', 'M', 'FALSE',
                                           '53 Bobwhite Park', 'lbilsfordcl@ibm.com');

insertdormmanagementdata.insertstudent('Tessi Bradman', '(132) 4602634', '06-Nov-1999', 'F', 'FALSE',
                                           '15 Merry Alley', 'tbradmancm@tripod.com');

insertdormmanagementdata.insertstudent('Dara Stoffer', '(775) 7535634', '22-Oct-1998', 'F', 'FALSE',
                                           '7 Dixon Pass', 'dstoffercn@nationalgeographic.com');

insertdormmanagementdata.insertstudent('Rancell Hadgraft', '(786) 3099244', '10-Mar-1998', 'M', 'FALSE',
                                           '8 Hanson Crossing', 'rhadgraftco@surveymonkey.com');

insertdormmanagementdata.insertstudent('Cam De Paoli', '(168) 8676858', '15-Nov-1998', 'F', 'FALSE',
                                           '795 Bay Junction', 'cdecp@ucsd.edu');

insertdormmanagementdata.insertstudent('Jamima Dunk', '(914) 2519624', '17-Aug-1993', 'F', 'FALSE',
                                           '758 Marquette Trail', 'jdunkcq@elpais.com');

insertdormmanagementdata.insertstudent('Tim Eldershaw', '(284) 8926382', '17-Dec-1998', 'M', 'FALSE',
                                           '8774 Merry Terrace', 'teldershawcr@amazonaws.com');

insertdormmanagementdata.insertstudent('Sylas Fairbeard', '(521) 1122494', '20-Apr-1997', 'M', 'FALSE',
                                           '59144 Washington Hill', 'sfairbeardcs@homestead.com');

insertdormmanagementdata.insertstudent('Georgina Sutliff', '(679) 8841652', '20-Jan-2002', 'F', 'FALSE',
                                           '07621 Golf Course Street', 'gsutliffct@xinhuanet.com');

insertdormmanagementdata.insertstudent('Dew Rubee', '(213) 2669071', '04-Dec-1992', 'M', 'FALSE',
                                           '158 Toban Hill', 'drubeecu@oracle.com');

insertdormmanagementdata.insertstudent('Ursuline Jeandon', '(816) 9465224', '17-Jun-2001', 'F', 'FALSE',
                                           '192 Hovde Hill', 'ujeandoncv@blogtalkradio.com');

insertdormmanagementdata.insertstudent('Berke Duffyn', '(105) 9704013', '21-Apr-1992', 'M', 'FALSE',
                                           '0424 Bellgrove Point', 'bduffyncw@msn.com');

insertdormmanagementdata.insertstudent('Davidde Golightly', '(318) 6677121', '01-Jul-1990', 'M', 'FALSE',
                                           '2 Scott Lane', 'dgolightlycx@aboutads.info');

insertdormmanagementdata.insertstudent('Augustina Truwert', '(665) 1684767', '07-Dec-1995', 'F', 'FALSE',
                                           '92138 6th Point', 'atruwertcy@army.mil');

insertdormmanagementdata.insertstudent('Rodney Cawson', '(487) 4942169', '26-Dec-2002', 'M', 'FALSE',
                                           '763 Stuart Pass', 'rcawsoncz@gmpg.org');

insertdormmanagementdata.insertstudent('Libbie Curnucke', '(591) 3217702', '15-Jul-1994', 'F', 'FALSE',
                                           '9858 Village Trail', 'lcurnucked0@ucla.edu');

insertdormmanagementdata.insertstudent('Zacharie Minard', '(352) 4000425', '03-Jun-1995', 'M', 'FALSE',
                                           '0 Kennedy Pass', 'zminardd1@pen.io');

insertdormmanagementdata.insertstudent('Kearney Butterick', '(135) 6869501', '14-Apr-1990', 'M', 'FALSE',
                                           '41069 Jana Alley', 'kbutterickd2@adobe.com');

insertdormmanagementdata.insertstudent('Ellswerth Whiscard', '(862) 9933586', '04-Apr-2002', 'M', 'FALSE',
                                           '76376 Armistice Street', 'ewhiscardd3@auda.org.au');

insertdormmanagementdata.insertstudent('Ferd Kingzet', '(599) 5060756', '17-Jan-1994', 'M', 'FALSE',
                                           '63 Katie Pass', 'fkingzetd4@sfgate.com');

insertdormmanagementdata.insertstudent('Ema Hutt', '(430) 4359678', '18-May-1990', 'F', 'FALSE',
                                           '77 Transport Pass', 'ehuttd5@wired.com');

insertdormmanagementdata.insertstudent('Danny Roycraft', '(502) 3964504', '26-Aug-1994', 'F', 'FALSE',
                                           '6759 Manufacturers Place', 'droycraftd6@webnode.com');

insertdormmanagementdata.insertstudent('Cory Dries', '(620) 4166673', '06-Sep-1996', 'F', 'FALSE',
                                           '1277 La Follette Parkway', 'cdriesd7@sina.com.cn');

insertdormmanagementdata.insertstudent('Vida Newlands', '(857) 7577451', '28-Sep-1993', 'F', 'FALSE',
                                           '41 Mayer Lane', 'vnewlandsd8@usda.gov');

insertdormmanagementdata.insertstudent('Eddi Tomney', '(817) 8897827', '15-May-2000', 'F', 'FALSE',
                                           '71 Michigan Hill', 'etomneyd9@europa.eu');

insertdormmanagementdata.insertstudent('Grier Shepland', '(843) 7652758', '27-Aug-1993', 'F', 'FALSE',
                                           '9844 Grayhawk Junction', 'gsheplandda@ihg.com');

insertdormmanagementdata.insertstudent('Rivi Braisher', '(728) 9585484', '30-Apr-1994', 'F', 'FALSE',
                                           '0 Little Fleur Junction', 'rbraisherdb@baidu.com');

insertdormmanagementdata.insertstudent('Finlay Harriskine', '(512) 3877273', '02-Jul-1999', 'M', 'FALSE',
                                           '882 Northport Place', 'fharriskinedc@bbb.org');

insertdormmanagementdata.insertstudent('Venita Morrowe', '(860) 3122791', '31-Aug-1990', 'F', 'FALSE',
                                           '5 Barby Road', 'vmorrowedd@admin.ch');

insertdormmanagementdata.insertstudent('Madalena Stansbie', '(126) 4984371', '18-Nov-1992', 'F', 'FALSE',
                                           '184 Transport Terrace', 'mstansbiede@aol.com');

insertdormmanagementdata.insertstudent('Padraig Simanenko', '(205) 1105416', '23-May-1997', 'M', 'FALSE',
                                           '9250 Thierer Lane', 'psimanenkodf@geocities.com');

insertdormmanagementdata.insertstudent('Tawsha Carah', '(560) 2806664', '06-May-2000', 'F', 'FALSE',
                                           '44928 Dakota Center', 'tcarahdg@blogtalkradio.com');

insertdormmanagementdata.insertstudent('Matilde Cristofari', '(310) 2210076', '18-Sep-1991', 'F', 'FALSE',
                                           '5 Kropf Crossing', 'mcristofaridh@hc360.com');

insertdormmanagementdata.insertstudent('Pren Gerran', '(609) 5889802', '30-Oct-2000', 'M', 'FALSE',
                                           '715 Golden Leaf Point', 'pgerrandi@qq.com');

insertdormmanagementdata.insertstudent('Frannie Ledger', '(556) 3746793', '16-Sep-1992', 'M', 'FALSE',
                                           '32 Declaration Trail', 'fledgerdj@goo.gl');

insertdormmanagementdata.insertstudent('Augustin Stratiff', '(414) 8004758', '16-Jan-1996', 'M', 'FALSE',
                                           '5 Sommers Lane', 'astratiffdk@engadget.com');

insertdormmanagementdata.insertstudent('Park Jarman', '(355) 5919160', '08-Feb-1999', 'M', 'FALSE',
                                           '1 Monument Crossing', 'pjarmandl@google.de');

insertdormmanagementdata.insertstudent('Andres McColm', '(475) 9642184', '26-May-2001', 'M', 'FALSE',
                                           '302 Union Parkway', 'amccolmdm@blogs.com');

insertdormmanagementdata.insertstudent('Jae Reap', '(492) 9940559', '03-Apr-1998', 'M', 'FALSE',
                                           '426 Logan Way', 'jreapdn@oaic.gov.au');

insertdormmanagementdata.insertstudent('Maddi Littefair', '(832) 3014115', '22-Nov-1993', 'F', 'FALSE',
                                           '1003 Browning Street', 'mlittefairdo@goo.gl');

insertdormmanagementdata.insertstudent('Brooke Esparza', '(629) 8488971', '20-May-1992', 'M', 'FALSE',
                                           '39 Ilene Pass', 'besparzadp@is.gd');

insertdormmanagementdata.insertstudent('Sonny Hatley', '(335) 3900334', '18-Oct-1991', 'M', 'FALSE',
                                           '63 Talmadge Drive', 'shatleydq@wisc.edu');

insertdormmanagementdata.insertstudent('Yorgos Gisburn', '(148) 9921223', '14-Sep-1992', 'M', 'FALSE',
                                           '83681 Colorado Avenue', 'ygisburndr@wikipedia.org');

insertdormmanagementdata.insertstudent('Kaine Parmley', '(928) 3066077', '15-Sep-2002', 'M', 'FALSE',
                                           '174 Bashford Trail', 'kparmleyds@netlog.com');

insertdormmanagementdata.insertstudent('Gallagher Fullerd', '(622) 9831346', '06-Oct-1991', 'M', 'FALSE',
                                           '44 Cambridge Parkway', 'gfullerddt@webs.com');

insertdormmanagementdata.insertstudent('Lydon Dabney', '(907) 2998418', '14-Nov-2002', 'M', 'FALSE',
                                           '9986 Scoville Terrace', 'ldabneydu@chronoengine.com');

insertdormmanagementdata.insertstudent('Val Cholmondeley', '(804) 5191925', '05-Mar-1991', 'F', 'FALSE',
                                           '23 Schmedeman Avenue', 'vcholmondeleydv@last.fm');

insertdormmanagementdata.insertstudent('Clemens Felkin', '(912) 4197890', '21-Nov-1992', 'M', 'FALSE',
                                           '4 Emmet Crossing', 'cfelkindw@earthlink.net');

insertdormmanagementdata.insertstudent('Arty Thurstance', '(245) 7201111', '26-May-2000', 'M', 'FALSE',
                                           '2 Lindbergh Hill', 'athurstancedx@cornell.edu');

insertdormmanagementdata.insertstudent('Tedmund Felton', '(315) 1883954', '09-Mar-1998', 'M', 'FALSE',
                                           '1580 Myrtle Pass', 'tfeltondy@pen.io');

insertdormmanagementdata.insertstudent('Marja Verrall', '(478) 2678078', '29-Dec-2002', 'F', 'FALSE',
                                           '8215 Sullivan Point', 'mverralldz@google.de');

insertdormmanagementdata.insertstudent('Kenton Gogarty', '(268) 1232615', '19-Jan-1995', 'M', 'FALSE',
                                           '6837 Kennedy Point', 'kgogartye0@edublogs.org');

insertdormmanagementdata.insertstudent('Araldo Pettipher', '(323) 1706774', '25-Feb-1998', 'M', 'FALSE',
                                           '75108 Johnson Street', 'apettiphere1@e-recht24.de');

insertdormmanagementdata.insertstudent('Erasmus Scourfield', '(887) 3127218', '19-Jul-2002', 'M', 'FALSE',
                                           '6 Dahle Pass', 'escourfielde2@cmu.edu');

insertdormmanagementdata.insertstudent('Ruddy Jurgen', '(954) 9229574', '19-Mar-1999', 'M', 'FALSE',
                                           '4017 Gateway Drive', 'rjurgene3@usnews.com');

insertdormmanagementdata.insertstudent('Verile Starte', '(963) 3667392', '07-Sep-1992', 'F', 'FALSE',
                                           '2794 Morrow Road', 'vstartee4@globo.com');

insertdormmanagementdata.insertstudent('Sarena Dy', '(626) 7309042', '06-Nov-1992', 'F', 'FALSE',
                                           '8000 Marcy Court', 'sdye5@omniture.com');

insertdormmanagementdata.insertstudent('Barth Beatty', '(339) 1985993', '14-Jul-1997', 'M', 'FALSE',
                                           '6 La Follette Park', 'bbeattye6@wufoo.com');

insertdormmanagementdata.insertstudent('Walker Berfoot', '(659) 2506267', '16-May-1994', 'M', 'FALSE',
                                           '19 North Plaza', 'wberfoote7@theatlantic.com');

insertdormmanagementdata.insertstudent('Gilemette Collibear', '(589) 5765738', '03-Jan-2001', 'F', 'FALSE',
                                           '70 Northridge Terrace', 'gcollibeare8@foxnews.com');

insertdormmanagementdata.insertstudent('Caleb Muckian', '(359) 4121268', '18-Oct-1993', 'M', 'FALSE',
                                           '2137 Transport Road', 'cmuckiane9@icio.us');

insertdormmanagementdata.insertstudent('Darleen Freeland', '(714) 1840983', '18-Jan-1994', 'F', 'FALSE',
                                           '7539 Merry Park', 'dfreelandea@state.tx.us');

insertdormmanagementdata.insertstudent('Jareb Whiteside', '(650) 6525781', '15-Jun-1995', 'M', 'FALSE',
                                           '3 Bashford Avenue', 'jwhitesideeb@gizmodo.com');

insertdormmanagementdata.insertstudent('Debora Morcombe', '(739) 8019194', '10-Aug-1995', 'F', 'FALSE',
                                           '5 Merry Terrace', 'dmorcombeec@businessweek.com');

insertdormmanagementdata.insertstudent('Rolando Belchamp', '(977) 2618037', '13-Apr-2001', 'M', 'FALSE',
                                           '2153 Daystar Junction', 'rbelchamped@technorati.com');

insertdormmanagementdata.insertstudent('Alidia Gresswell', '(927) 4058825', '28-Jan-1990', 'F', 'FALSE',
                                           '9062 Pleasure Junction', 'agresswellee@wufoo.com');

insertdormmanagementdata.insertstudent('Troy Bollins', '(552) 6898023', '05-Apr-2001', 'M', 'FALSE',
                                           '14 Vera Pass', 'tbollinsef@meetup.com');

insertdormmanagementdata.insertstudent('Sonnnie Scates', '(993) 1255741', '29-Oct-2000', 'F', 'FALSE',
                                           '66 Blaine Center', 'sscateseg@examiner.com');

insertdormmanagementdata.insertstudent('Ian Toffoletto', '(760) 2620579', '04-Sep-1994', 'M', 'FALSE',
                                           '5824 Petterle Alley', 'itoffolettoeh@plala.or.jp');

insertdormmanagementdata.insertstudent('Kira Cantos', '(774) 1416562', '22-Oct-1994', 'F', 'FALSE',
                                           '4632 Bartelt Crossing', 'kcantosei@reverbnation.com');

insertdormmanagementdata.insertstudent('Dudley Mabe', '(906) 6909726', '25-Aug-1999', 'M', 'FALSE',
                                           '8 Holy Cross Center', 'dmabeej@cbc.ca');

insertdormmanagementdata.insertstudent('Tully Purdy', '(107) 4412603', '14-Oct-1997', 'M', 'FALSE',
                                           '16968 Rutledge Center', 'tpurdyek@usgs.gov');

insertdormmanagementdata.insertstudent('Gabie Grocott', '(846) 5434882', '31-Jan-1991', 'M', 'FALSE',
                                           '21565 Logan Trail', 'ggrocottel@stumbleupon.com');

insertdormmanagementdata.insertstudent('Marlin Hamer', '(524) 4997143', '09-Oct-2001', 'M', 'FALSE',
                                           '46 Nevada Point', 'mhamerem@dailymotion.com');

insertdormmanagementdata.insertstudent('Gilburt Korous', '(945) 7753986', '28-Aug-1996', 'M', 'FALSE',
                                           '48331 Montana Crossing', 'gkorousen@miibeian.gov.cn');

insertdormmanagementdata.insertstudent('Grace Arias', '(536) 5535229', '21-Jul-1990', 'F', 'FALSE',
                                           '94 Main Pass', 'gariaseo@weather.com');

insertdormmanagementdata.insertstudent('Ros Points', '(775) 8332266', '02-Feb-2002', 'F', 'FALSE',
                                           '10243 Hoard Hill', 'rpointsep@hao123.com');

insertdormmanagementdata.insertstudent('Vincents Seago', '(115) 5495443', '03-Feb-2001', 'M', 'FALSE',
                                           '01867 Memorial Alley', 'vseagoeq@fema.gov');

insertdormmanagementdata.insertstudent('Stirling Stuckow', '(502) 8116723', '31-Oct-1999', 'M', 'FALSE',
                                           '005 Corscot Way', 'sstuckower@webnode.com');

insertdormmanagementdata.insertstudent('Darrel Zaniolo', '(762) 2664013', '01-Oct-1999', 'M', 'FALSE',
                                           '64 Crest Line Terrace', 'dzanioloes@homestead.com');

insertdormmanagementdata.insertstudent('Walden Balden', '(456) 9457855', '07-Aug-2002', 'M', 'FALSE',
                                           '3526 Lotheville Road', 'wbaldenet@privacy.gov.au');

insertdormmanagementdata.insertstudent('Janek Walklett', '(409) 1765233', '22-Aug-2002', 'M', 'FALSE',
                                           '0 Homewood Lane', 'jwalkletteu@netscape.com');

insertdormmanagementdata.insertstudent('Hope Wison', '(274) 3345944', '29-Sep-1999', 'F', 'FALSE',
                                           '55 Towne Point', 'hwisonev@marketwatch.com');

insertdormmanagementdata.insertstudent('Gwendolen Rushbury', '(906) 3429890', '20-Nov-2002', 'F', 'FALSE',
                                           '44 Milwaukee Park', 'grushburyew@elpais.com');

insertdormmanagementdata.insertstudent('Dominica McWilliam', '(488) 8764540', '10-Jan-1999', 'F', 'FALSE',
                                           '771 Bultman Avenue', 'dmcwilliamex@sciencedaily.com');

insertdormmanagementdata.insertstudent('Hughie Lenin', '(253) 9910648', '18-Mar-1994', 'M', 'FALSE',
                                           '26 Independence Terrace', 'hleniney@zdnet.com');

insertdormmanagementdata.insertstudent('Parnell Saladino', '(619) 6660450', '19-Jul-2002', 'M', 'FALSE',
                                           '9126 Elmside Park', 'psaladinoez@merriam-webster.com');

insertdormmanagementdata.insertstudent('Claudina Martinat', '(496) 6678643', '14-Feb-1996', 'F', 'FALSE',
                                           '9 Mcbride Parkway', 'cmartinatf0@jimdo.com');

insertdormmanagementdata.insertstudent('Judie Angrave', '(339) 9946206', '22-Sep-1990', 'F', 'FALSE',
                                           '45640 Stuart Street', 'jangravef1@wix.com');

insertdormmanagementdata.insertstudent('Darnall McCreery', '(406) 5578744', '09-Jun-1999', 'M', 'FALSE',
                                           '1 Marquette Terrace', 'dmccreeryf2@jalbum.net');

insertdormmanagementdata.insertstudent('Annelise Hirjak', '(260) 5517703', '18-Feb-2001', 'F', 'FALSE',
                                           '7 American Ash Terrace', 'ahirjakf3@skyrock.com');

insertdormmanagementdata.insertstudent('Emmaline Pontain', '(589) 1906507', '26-Sep-1995', 'F', 'FALSE',
                                           '696 Jackson Circle', 'epontainf4@webeden.co.uk');

insertdormmanagementdata.insertstudent('Veronique Runnicles', '(113) 5981991', '01-Dec-1994', 'F', 'FALSE',
                                           '9747 Algoma Point', 'vrunniclesf5@mapy.cz');

insertdormmanagementdata.insertstudent('Pattin Hedin', '(387) 3383959', '01-May-1995', 'M', 'FALSE',
                                           '009 Crescent Oaks Parkway', 'phedinf6@cpanel.net');

insertdormmanagementdata.insertstudent('Oralie Artindale', '(683) 4213831', '02-Nov-1995', 'F', 'FALSE',
                                           '7 Holmberg Way', 'oartindalef7@craigslist.org');

insertdormmanagementdata.insertstudent('Federico Meatyard', '(161) 1398739', '20-Dec-1994', 'M', 'FALSE',
                                           '63397 Goodland Crossing', 'fmeatyardf8@unicef.org');

insertdormmanagementdata.insertstudent('Benedicto Breward', '(274) 6760957', '15-Mar-1990', 'M', 'FALSE',
                                           '49236 Brown Street', 'bbrewardf9@youku.com');

insertdormmanagementdata.insertstudent('Noland Wheaton', '(989) 9436161', '20-Sep-2002', 'M', 'FALSE',
                                           '07718 Corscot Way', 'nwheatonfa@arizona.edu');

insertdormmanagementdata.insertstudent('Lovell Boughton', '(481) 7404473', '05-May-2002', 'M', 'FALSE',
                                           '62 Almo Way', 'lboughtonfb@sphinn.com');

insertdormmanagementdata.insertstudent('Morris Fraine', '(753) 4714541', '13-Apr-1996', 'M', 'FALSE',
                                           '1653 Ronald Regan Crossing', 'mfrainefc@1688.com');

insertdormmanagementdata.insertstudent('Rory Sorey', '(788) 9183526', '01-Jan-1998', 'M', 'FALSE',
                                           '2446 Parkside Avenue', 'rsoreyfd@sun.com');

insertdormmanagementdata.insertstudent('Junina Wildin', '(677) 8221417', '19-Oct-1998', 'F', 'FALSE',
                                           '8061 Milwaukee Way', 'jwildinfe@twitter.com');

insertdormmanagementdata.insertstudent('Jenni Badini', '(901) 9551545', '04-Sep-1997', 'F', 'FALSE',
                                           '87 Trailsway Center', 'jbadiniff@youku.com');

insertdormmanagementdata.insertstudent('Tracey Fissenden', '(121) 9875297', '12-Sep-1996', 'F', 'FALSE',
                                           '99 Merrick Trail', 'tfissendenfg@amazon.co.jp');

insertdormmanagementdata.insertstudent('Dag Baile', '(946) 5814292', '15-Oct-2002', 'M', 'FALSE',
                                           '79 Morningstar Drive', 'dbailefh@slashdot.org');

insertdormmanagementdata.insertstudent('Ernaline Chalk', '(264) 3435355', '14-Apr-1997', 'F', 'FALSE',
                                           '2287 Bluejay Avenue', 'echalkfi@wiley.com');

insertdormmanagementdata.insertstudent('Lanny Whetton', '(827) 4931334', '19-Jun-1997', 'F', 'FALSE',
                                           '08856 Stang Center', 'lwhettonfj@usnews.com');

insertdormmanagementdata.insertstudent('Jethro Perigoe', '(156) 8143618', '01-Sep-1994', 'M', 'FALSE',
                                           '524 Lunder Terrace', 'jperigoefk@accuweather.com');

insertdormmanagementdata.insertstudent('Lexis MacGruer', '(348) 1937144', '16-Oct-1996', 'F', 'FALSE',
                                           '86332 Mayfield Alley', 'lmacgruerfl@smh.com.au');

insertdormmanagementdata.insertstudent('Lula Coultous', '(979) 2904187', '13-Jul-1998', 'F', 'FALSE',
                                           '59517 Sage Point', 'lcoultousfm@lulu.com');

insertdormmanagementdata.insertstudent('Calhoun Vallis', '(442) 4627334', '05-Nov-1996', 'M', 'FALSE',
                                           '90 Oriole Avenue', 'cvallisfn@discovery.com');

insertdormmanagementdata.insertstudent('Putnam Schollar', '(400) 2401211', '09-Jan-1994', 'M', 'FALSE',
                                           '7 Quincy Trail', 'pschollarfo@webnode.com');

insertdormmanagementdata.insertstudent('Findley Odegaard', '(803) 5149995', '01-May-1996', 'M', 'FALSE',
                                           '8469 Mccormick Parkway', 'fodegaardfp@behance.net');

insertdormmanagementdata.insertstudent('Glynis Rickardes', '(926) 9122370', '13-Nov-1993', 'F', 'FALSE',
                                           '83 Forest Run Crossing', 'grickardesfq@imageshack.us');

insertdormmanagementdata.insertstudent('Keith Fouracre', '(459) 4523259', '11-Aug-1994', 'M', 'FALSE',
                                           '40 Eastlawn Road', 'kfouracrefr@tripod.com');

insertdormmanagementdata.insertstudent('Tades Simonot', '(458) 9394042', '09-Oct-1990', 'M', 'FALSE',
                                           '32810 High Crossing Trail', 'tsimonotfs@apache.org');

insertdormmanagementdata.insertstudent('Marve Anker', '(206) 6719293', '16-Jun-2002', 'M', 'FALSE',
                                           '117 Utah Pass', 'mankerft@gizmodo.com');

insertdormmanagementdata.insertstudent('Catha Packman', '(197) 4410888', '03-May-2002', 'F', 'FALSE',
                                           '51 Caliangt Drive', 'cpackmanfu@amazon.co.uk');

insertdormmanagementdata.insertstudent('Johann Kunzelmann', '(835) 8237777', '11-May-1990', 'M', 'FALSE',
                                           '62 Mandrake Place', 'jkunzelmannfv@artisteer.com');

insertdormmanagementdata.insertstudent('Allistir Watson-Brown', '(816) 3805979', '28-Sep-1994', 'M', 'FALSE',
                                           '80 Kropf Place', 'awatsonbrownfw@google.it');

insertdormmanagementdata.insertstudent('Khalil Covill', '(279) 1772659', '15-Jan-1990', 'M', 'FALSE',
                                           '57 Logan Lane', 'kcovillfx@ezinearticles.com');

insertdormmanagementdata.insertstudent('Woodrow MacAlpin', '(289) 5562419', '22-Jul-1994', 'M', 'FALSE',
                                           '69400 Maywood Trail', 'wmacalpinfy@prlog.org');

insertdormmanagementdata.insertstudent('Elihu Bentall', '(261) 8210416', '09-May-1994', 'M', 'FALSE',
                                           '82 Nobel Street', 'ebentallfz@home.pl');

insertdormmanagementdata.insertstudent('Galina Chritchlow', '(297) 6519980', '10-Dec-1990', 'F', 'FALSE',
                                           '6086 Dahle Court', 'gchritchlowg0@meetup.com');

insertdormmanagementdata.insertstudent('Corabel Halwill', '(558) 5584449', '15-Feb-1999', 'F', 'FALSE',
                                           '945 Donald Parkway', 'chalwillg1@barnesandnoble.com');

insertdormmanagementdata.insertstudent('Fonsie Colquhoun', '(241) 3348419', '06-Nov-2000', 'M', 'FALSE',
                                           '0 Montana Avenue', 'fcolquhoung2@about.me');

insertdormmanagementdata.insertstudent('Stevana Spencley', '(656) 2183691', '02-Aug-2000', 'F', 'FALSE',
                                           '032 Sugar Road', 'sspencleyg3@forbes.com');

insertdormmanagementdata.insertstudent('Raleigh Dever', '(465) 4107247', '13-Apr-2002', 'M', 'FALSE',
                                           '96461 Messerschmidt Terrace', 'rdeverg4@pbs.org');

insertdormmanagementdata.insertstudent('Jessee Shoreson', '(763) 8863660', '19-Sep-1994', 'M', 'FALSE',
                                           '51 Farragut Avenue', 'jshoresong5@wikia.com');

insertdormmanagementdata.insertstudent('Charo Haslam', '(682) 9644040', '04-Oct-2001', 'F', 'FALSE',
                                           '78911 Forest Dale Pass', 'chaslamg6@aol.com');

insertdormmanagementdata.insertstudent('Ingaberg Badby', '(582) 8342132', '19-May-1997', 'F', 'FALSE',
                                           '1 Dexter Circle', 'ibadbyg7@va.gov');

insertdormmanagementdata.insertstudent('Lalo Attaway', '(537) 5382855', '17-May-1995', 'M', 'FALSE',
                                           '46 Kim Junction', 'lattawayg8@census.gov');

insertdormmanagementdata.insertstudent('Lucas Jocelyn', '(621) 1564976', '01-Feb-1995', 'M', 'FALSE',
                                           '8 Quincy Point', 'ljocelyng9@newyorker.com');

insertdormmanagementdata.insertstudent('Dori Lindback', '(535) 7472048', '07-Nov-2000', 'F', 'FALSE',
                                           '6 Anzinger Circle', 'dlindbackga@digg.com');

insertdormmanagementdata.insertstudent('Ileana Kubelka', '(579) 3718177', '07-Nov-2002', 'F', 'FALSE',
                                           '76355 Golden Leaf Parkway', 'ikubelkagb@noaa.gov');

insertdormmanagementdata.insertstudent('Shel Priddy', '(685) 3435766', '22-Feb-2001', 'F', 'FALSE',
                                           '691 Commercial Pass', 'spriddygc@bbc.co.uk');

insertdormmanagementdata.insertstudent('Gerek Alexandrou', '(735) 5814992', '14-Mar-1998', 'M', 'FALSE',
                                           '9 La Follette Street', 'galexandrougd@bravesites.com');

insertdormmanagementdata.insertstudent('Janelle Kelley', '(808) 1937735', '27-Feb-1990', 'F', 'FALSE',
                                           '0 Glendale Court', 'jkelleyge@mashable.com');

insertdormmanagementdata.insertstudent('Patrica Klaffs', '(201) 3080957', '13-Dec-2001', 'F', 'FALSE',
                                           '71188 Riverside Place', 'pklaffsgf@xing.com');

insertdormmanagementdata.insertstudent('Toby Hatherleigh', '(650) 4724620', '15-Nov-1993', 'M', 'FALSE',
                                           '548 Moulton Avenue', 'thatherleighgg@example.com');

insertdormmanagementdata.insertstudent('Halette Huddlestone', '(174) 7309740', '27-Jan-1990', 'F', 'FALSE',
                                           '6 Colorado Plaza', 'hhuddlestonegh@dion.ne.jp');

insertdormmanagementdata.insertstudent('Marietta Gillan', '(298) 2677186', '24-Aug-1993', 'M', 'FALSE',
                                           '18582 Haas Point', 'mgillangi@netlog.com');

insertdormmanagementdata.insertstudent('Nathanael Kellart', '(116) 5588952', '14-Oct-1998', 'M', 'FALSE',
                                           '4837 La Follette Crossing', 'nkellartgj@opera.com');

insertdormmanagementdata.insertstudent('Karim Fletcher', '(689) 7457066', '24-Mar-1996', 'M', 'FALSE',
                                           '0 Stone Corner Lane', 'kfletchergk@bloomberg.com');

insertdormmanagementdata.insertstudent('Tommy Swindells', '(542) 5295115', '19-Oct-1993', 'F', 'FALSE',
                                           '4 Lyons Drive', 'tswindellsgl@virginia.edu');

insertdormmanagementdata.insertstudent('Pooh Elies', '(724) 8723277', '10-Jan-1992', 'M', 'FALSE',
                                           '62 Debs Way', 'peliesgm@dion.ne.jp');

insertdormmanagementdata.insertstudent('Vidovic Ryhorovich', '(339) 1703595', '29-Nov-1997', 'M', 'FALSE',
                                           '148 Bultman Park', 'vryhorovichgn@prweb.com');

insertdormmanagementdata.insertstudent('Geri Rodnight', '(147) 9754762', '12-Sep-2001', 'F', 'FALSE',
                                           '066 Anthes Pass', 'grodnightgo@wired.com');

insertdormmanagementdata.insertstudent('Raff Collacombe', '(478) 5789759', '24-Aug-1991', 'M', 'FALSE',
                                           '458 Buell Plaza', 'rcollacombegp@imageshack.us');

insertdormmanagementdata.insertstudent('Lulu Marns', '(862) 8377302', '23-Jan-1996', 'F', 'FALSE',
                                           '98003 Mitchell Pass', 'lmarnsgq@oaic.gov.au');

insertdormmanagementdata.insertstudent('Cole Twigg', '(838) 6506654', '06-Jun-1992', 'M', 'FALSE',
                                           '3041 Thompson Avenue', 'ctwigggr@printfriendly.com');

insertdormmanagementdata.insertstudent('Susannah Crook', '(325) 6624238', '12-Dec-1996', 'F', 'FALSE',
                                           '1 Dakota Pass', 'scrookgs@google.com.au');

insertdormmanagementdata.insertstudent('Valli Ever', '(763) 1003097', '22-Jan-2001', 'F', 'FALSE',
                                           '3 Starling Court', 'vevergt@cocolog-nifty.com');

insertdormmanagementdata.insertstudent('Pierrette Andrzejak', '(497) 3453030', '27-Nov-1997', 'F', 'FALSE',
                                           '531 Burning Wood Road', 'pandrzejakgu@printfriendly.com');

insertdormmanagementdata.insertstudent('Billi Harcarse', '(399) 7122692', '18-Oct-1991', 'F', 'FALSE',
                                           '02 Mendota Center', 'bharcarsegv@nih.gov');

insertdormmanagementdata.insertstudent('Franklyn Gilleon', '(751) 9895649', '04-Jan-2002', 'M', 'FALSE',
                                           '6 1st Place', 'fgilleongw@mail.ru');

insertdormmanagementdata.insertstudent('Sanson Mobbs', '(542) 5740805', '20-Dec-1992', 'M', 'FALSE',
                                           '6760 Moose Junction', 'smobbsgx@adobe.com');

insertdormmanagementdata.insertstudent('Denney Terrett', '(841) 6991615', '17-Sep-1993', 'M', 'FALSE',
                                           '16 Hooker Park', 'dterrettgy@imageshack.us');

insertdormmanagementdata.insertstudent('Lindsay Lahive', '(986) 5280458', '08-Jul-1998', 'F', 'FALSE',
                                           '1 Burrows Park', 'llahivegz@howstuffworks.com');

insertdormmanagementdata.insertstudent('Ned Hopkins', '(172) 6340252', '07-Apr-1991', 'M', 'FALSE',
                                           '3 Pleasure Road', 'nhopkinsh0@wikispaces.com');

insertdormmanagementdata.insertstudent('Cornell Lamerton', '(129) 5510286', '29-Nov-1992', 'M', 'FALSE',
                                           '09 Sunbrook Point', 'clamertonh1@paginegialle.it');

insertdormmanagementdata.insertstudent('Constantino Ridett', '(795) 3103984', '24-Apr-1993', 'M', 'FALSE',
                                           '1046 Oneill Pass', 'cridetth2@sciencedaily.com');

insertdormmanagementdata.insertstudent('Cherri Kleinzweig', '(270) 7258471', '15-Oct-1993', 'F', 'FALSE',
                                           '61252 Comanche Street', 'ckleinzweigh3@yale.edu');

insertdormmanagementdata.insertstudent('Arron Gadault', '(507) 5936655', '27-Jul-1999', 'M', 'FALSE',
                                           '2 Shasta Road', 'agadaulth4@foxnews.com');

insertdormmanagementdata.insertstudent('Hobard Calafato', '(770) 7055657', '08-May-1996', 'M', 'FALSE',
                                           '65683 South Lane', 'hcalafatoh5@123-reg.co.uk');

insertdormmanagementdata.insertstudent('Lindsy Greensitt', '(731) 5481487', '08-Oct-1990', 'F', 'FALSE',
                                           '2 Nancy Plaza', 'lgreensitth6@spotify.com');

insertdormmanagementdata.insertstudent('Marwin Hooke', '(142) 9579356', '30-Dec-1997', 'M', 'FALSE',
                                           '84 Eggendart Circle', 'mhookeh7@sun.com');

insertdormmanagementdata.insertstudent('Cynthia Kordt', '() 3555382', '16-Jan-1993', 'F', 'FALSE',
                                           '3343 Rigney Trail', 'ckordth8@ycombinator.com');

insertdormmanagementdata.insertstudent('Jereme Powton', '(233) 4496137', '31-Jul-2001', 'M', 'FALSE',
                                           '3 Bonner Park', 'jpowtonh9@over-blog.com');

insertdormmanagementdata.insertstudent('Brianne Oscroft', '(380) 1922305', '09-Jan-2002', 'F', 'FALSE',
                                           '87693 Dakota Way', 'boscroftha@sogou.com');

insertdormmanagementdata.insertstudent('Moyna Hamon', '(962) 5820418', '28-Aug-1992', 'F', 'FALSE',
                                           '95386 Talmadge Plaza', 'mhamonhb@latimes.com');

insertdormmanagementdata.insertstudent('Clerkclaude Chatto', '(755) 8283546', '17-May-1994', 'M', 'FALSE',
                                           '562 Melody Plaza', 'cchattohc@elpais.com');

insertdormmanagementdata.insertstudent('Maximilian Laval', '(685) 4218423', '10-Sep-1992', 'M', 'FALSE',
                                           '68401 Sunnyside Parkway', 'mlavalhd@wired.com');

insertdormmanagementdata.insertstudent('Artie Ruslen', '(482) 6447704', '28-Aug-2000', 'M', 'FALSE',
                                           '31115 Hansons Park', 'aruslenhe@accuweather.com');

insertdormmanagementdata.insertstudent('Jocko Frances', '(895) 6625658', '19-Dec-1996', 'M', 'FALSE',
                                           '83395 Waxwing Crossing', 'jfranceshf@cocolog-nifty.com');

insertdormmanagementdata.insertstudent('Melba Hunnybun', '(888) 2357005', '07-Aug-1992', 'F', 'FALSE',
                                           '78 Ridgeview Center', 'mhunnybunhg@google.co.jp');

insertdormmanagementdata.insertstudent('Cos Besset', '(332) 9983216', '13-Mar-1993', 'M', 'FALSE',
                                           '10731 Vidon Lane', 'cbessethh@nps.gov');

insertdormmanagementdata.insertstudent('Otha Ferguson', '(363) 7872662', '28-May-1994', 'F', 'FALSE',
                                           '6770 Spaight Point', 'ofergusonhi@nasa.gov');

insertdormmanagementdata.insertstudent('Leonidas Eckersall', '(859) 9086319', '09-Sep-1997', 'M', 'FALSE',
                                           '2 Debs Center', 'leckersallhj@ameblo.jp');

insertdormmanagementdata.insertstudent('Willy Nutting', '(160) 8080382', '14-Oct-1999', 'M', 'FALSE',
                                           '914 Fulton Plaza', 'wnuttinghk@weebly.com');

insertdormmanagementdata.insertstudent('Zaria Van der Beek', '(714) 9402935', '04-Feb-1999', 'F', 'FALSE',
                                           '1647 Village Plaza', 'zvanhl@sohu.com');

insertdormmanagementdata.insertstudent('Teddy Tester', '(387) 3855277', '05-May-1993', 'M', 'FALSE',
                                           '3694 Loeprich Point', 'ttesterhm@google.cn');

insertdormmanagementdata.insertstudent('Patty Bagenal', '(629) 3612094', '22-Mar-1990', 'M', 'FALSE',
                                           '2 Sutherland Crossing', 'pbagenalhn@ucla.edu');

insertdormmanagementdata.insertstudent('Damita MacAlaster', '(560) 8246796', '12-Mar-2000', 'F', 'FALSE',
                                           '2 Schlimgen Street', 'dmacalasterho@alexa.com');

insertdormmanagementdata.insertstudent('Wolfy Bushell', '(265) 3192305', '29-Jul-1995', 'M', 'FALSE',
                                           '4 Stephen Road', 'wbushellhp@time.com');

insertdormmanagementdata.insertstudent('Kelby Zamudio', '(151) 1713373', '06-May-1992', 'M', 'FALSE',
                                           '5 Troy Avenue', 'kzamudiohq@ameblo.jp');

insertdormmanagementdata.insertstudent('Louis Swatheridge', '(206) 2589921', '24-Dec-1994', 'M', 'FALSE',
                                           '55 Mesta Park', 'lswatheridgehr@amazon.com');

insertdormmanagementdata.insertstudent('Zeb Beechcraft', '(932) 3383991', '25-Apr-1996', 'M', 'FALSE',
                                           '5 Pine View Center', 'zbeechcrafths@barnesandnoble.com');

insertdormmanagementdata.insertstudent('Shep Tourmell', '(476) 4815052', '16-Oct-1991', 'M', 'FALSE',
                                           '8623 Fallview Junction', 'stourmellht@booking.com');

insertdormmanagementdata.insertstudent('Liane Bunning', '(826) 8862573', '20-Jun-1990', 'F', 'FALSE',
                                           '598 School Way', 'lbunninghu@cmu.edu');

insertdormmanagementdata.insertstudent('Shani Parkyn', '(895) 3931283', '04-Oct-2001', 'F', 'FALSE',
                                           '1 American Ash Junction', 'sparkynhv@so-net.ne.jp');

insertdormmanagementdata.insertstudent('Barbee Bloss', '(205) 4490288', '14-Feb-1994', 'F', 'FALSE',
                                           '266 Pankratz Plaza', 'bblosshw@tmall.com');

insertdormmanagementdata.insertstudent('Culley Lattimore', '(179) 9887194', '20-Jan-1990', 'M', 'FALSE',
                                           '9 Mesta Junction', 'clattimorehx@angelfire.com');

insertdormmanagementdata.insertstudent('Alberto Dowdall', '(190) 4450927', '07-Apr-1992', 'M', 'FALSE',
                                           '4946 Union Center', 'adowdallhy@cargocollective.com');

insertdormmanagementdata.insertstudent('Erny McCrorie', '(505) 9362499', '12-Dec-1990', 'M', 'FALSE',
                                           '58 Kensington Center', 'emccroriehz@blogtalkradio.com');

insertdormmanagementdata.insertstudent('Cobbie Scougall', '(742) 4152967', '14-Sep-1995', 'M', 'FALSE',
                                           '86066 Manufacturers Plaza', 'cscougalli0@moonfruit.com');

insertdormmanagementdata.insertstudent('Luigi O''Dee', '(217) 9118556', '23-Jan-1990', 'M', 'FALSE',
                                           '90 Straubel Street', 'lodeei1@printfriendly.com');

insertdormmanagementdata.insertstudent('Helsa Barkess', '(196) 5529520', '17-May-2001', 'F', 'FALSE',
                                           '07689 Columbus Pass', 'hbarkessi2@behance.net');

insertdormmanagementdata.insertstudent('Barnabe Arman', '(798) 6675754', '29-Jul-2001', 'M', 'FALSE',
                                           '04 Scofield Place', 'barmani3@yahoo.com');

insertdormmanagementdata.insertstudent('Haily Habgood', '(323) 5652317', '19-Oct-1997', 'M', 'FALSE',
                                           '4749 Thompson Hill', 'hhabgoodi4@vk.com');

insertdormmanagementdata.insertstudent('Arabelle Boggon', '(406) 5375243', '14-Nov-1997', 'F', 'FALSE',
                                           '79 Walton Street', 'aboggoni5@privacy.gov.au');

insertdormmanagementdata.insertstudent('Thorvald Gillmor', '(382) 2422681', '28-Jan-1990', 'M', 'FALSE',
                                           '69 Coleman Road', 'tgillmori6@webmd.com');

insertdormmanagementdata.insertstudent('Bernadene Pedel', '(361) 5016599', '28-Jun-1992', 'F', 'FALSE',
                                           '6 Porter Center', 'bpedeli7@redcross.org');

insertdormmanagementdata.insertstudent('Flinn Baber', '(637) 9547530', '31-Aug-2002', 'M', 'FALSE',
                                           '7 Grasskamp Road', 'fbaberi8@hugedomains.com');

insertdormmanagementdata.insertstudent('Christan Ellerton', '(678) 1210108', '18-Nov-1999', 'F', 'FALSE',
                                           '01951 West Center', 'cellertoni9@addthis.com');

insertdormmanagementdata.insertstudent('Candra Gainfort', '(537) 8329818', '04-Dec-1995', 'F', 'FALSE',
                                           '89 Delaware Terrace', 'cgainfortia@purevolume.com');

insertdormmanagementdata.insertstudent('Carrissa Sharkey', '(364) 6778915', '28-May-1991', 'F', 'FALSE',
                                           '2831 Oneill Lane', 'csharkeyib@cnn.com');

insertdormmanagementdata.insertstudent('Taylor Thairs', '(734) 7161876', '15-May-2000', 'M', 'FALSE',
                                           '29843 Porter Park', 'tthairsic@elpais.com');

insertdormmanagementdata.insertstudent('Herminia Caret', '(435) 4342236', '28-Sep-2000', 'F', 'FALSE',
                                           '6 Truax Trail', 'hcaretid@walmart.com');

insertdormmanagementdata.insertstudent('Virgilio Bruckenthal', '(180) 2333713', '09-Mar-1996', 'M', 'FALSE',
                                           '5 Trailsway Drive', 'vbruckenthalie@scientificamerican.com');

insertdormmanagementdata.insertstudent('Rosetta Heys', '(342) 6751709', '18-Feb-2002', 'F', 'FALSE',
                                           '01503 Brentwood Avenue', 'rheysif@state.tx.us');

insertdormmanagementdata.insertstudent('Karoly Pizzey', '(774) 5700625', '31-Dec-1995', 'M', 'FALSE',
                                           '484 Mendota Junction', 'kpizzeyig@fastcompany.com');

insertdormmanagementdata.insertstudent('Lindsey Dellatorre', '(653) 5334633', '03-Jul-1997', 'F', 'FALSE',
                                           '35765 Toban Court', 'ldellatorreih@google.it');

insertdormmanagementdata.insertstudent('Frederich Harmstone', '(189) 9342011', '19-Jan-1995', 'M', 'FALSE',
                                           '74 Drewry Drive', 'fharmstoneii@vkontakte.ru');

insertdormmanagementdata.insertstudent('Leon Strank', '(678) 6431674', '07-Apr-1998', 'M', 'FALSE',
                                           '2756 Banding Place', 'lstrankij@imageshack.us');

insertdormmanagementdata.insertstudent('Liliane Linne', '(809) 4501772', '06-Mar-1999', 'F', 'FALSE',
                                           '4 Stang Terrace', 'llinneik@who.int');

insertdormmanagementdata.insertstudent('Hadley Handrick', '(858) 4149535', '07-Apr-1999', 'M', 'FALSE',
                                           '02 Ruskin Lane', 'hhandrickil@ed.gov');

insertdormmanagementdata.insertstudent('Tracey Palfreman', '(328) 4820334', '19-Sep-1994', 'F', 'FALSE',
                                           '839 Division Junction', 'tpalfremanim@yolasite.com');

insertdormmanagementdata.insertstudent('Domenic Sings', '(875) 6442007', '06-Jan-2002', 'M', 'FALSE',
                                           '6360 Lawn Court', 'dsingsin@businesswire.com');

insertdormmanagementdata.insertstudent('Charlton Keymar', '(228) 8918101', '09-Mar-2000', 'M', 'FALSE',
                                           '75 Montana Hill', 'ckeymario@github.com');

insertdormmanagementdata.insertstudent('Tiphani Cobden', '(677) 5672109', '05-Jun-1990', 'F', 'FALSE',
                                           '634 Moland Junction', 'tcobdenip@pbs.org');

insertdormmanagementdata.insertstudent('Beitris Wilshere', '(306) 8414794', '24-Aug-1992', 'F', 'FALSE',
                                           '49 Russell Circle', 'bwilshereiq@ezinearticles.com');

insertdormmanagementdata.insertstudent('Reuben Dalloway', '(238) 8584524', '12-Oct-2002', 'M', 'FALSE',
                                           '0137 Corscot Plaza', 'rdallowayir@1und1.de');

insertdormmanagementdata.insertstudent('Haleigh Prys', '(161) 5123855', '11-May-2000', 'M', 'FALSE',
                                           '639 Ramsey Crossing', 'hprysis@cnet.com');

insertdormmanagementdata.insertstudent('Jewel Wyon', '(236) 1289490', '16-Mar-1990', 'F', 'FALSE',
                                           '03458 Cherokee Pass', 'jwyonit@baidu.com');

insertdormmanagementdata.insertstudent('Ramsey Pecht', '(434) 2059125', '18-Nov-1995', 'M', 'FALSE',
                                           '15153 Mcbride Circle', 'rpechtiu@w3.org');

insertdormmanagementdata.insertstudent('Dukie Shawcroft', '(492) 7188280', '09-Apr-2000', 'M', 'FALSE',
                                           '247 Bluejay Circle', 'dshawcroftiv@privacy.gov.au');

insertdormmanagementdata.insertstudent('Tally Halmkin', '(483) 3770450', '08-Nov-1994', 'F', 'FALSE',
                                           '3 Anderson Avenue', 'thalmkiniw@dyndns.org');

insertdormmanagementdata.insertstudent('Ynes Johnys', '(911) 6524802', '30-Nov-1993', 'F', 'FALSE',
                                           '7654 Lukken Place', 'yjohnysix@merriam-webster.com');

insertdormmanagementdata.insertstudent('Ivor Colpus', '(900) 4356998', '28-Jan-2000', 'M', 'FALSE',
                                           '3 Homewood Street', 'icolpusiy@senate.gov');

insertdormmanagementdata.insertstudent('Adria Bockler', '(615) 3382317', '06-Jan-1991', 'F', 'FALSE',
                                           '11756 Grover Park', 'abockleriz@redcross.org');

insertdormmanagementdata.insertstudent('Kile Maydway', '(982) 6594683', '06-Aug-1992', 'M', 'FALSE',
                                           '1 Hollow Ridge Lane', 'kmaydwayj0@yolasite.com');

insertdormmanagementdata.insertstudent('Burty Desvignes', '(711) 9713367', '23-Oct-1999', 'M', 'FALSE',
                                           '16 Hoard Avenue', 'bdesvignesj1@last.fm');

insertdormmanagementdata.insertstudent('Tiertza Ovanesian', '(824) 2756783', '27-Mar-1999', 'F', 'FALSE',
                                           '3493 Dunning Avenue', 'tovanesianj2@purevolume.com');

insertdormmanagementdata.insertstudent('Antonina Jakel', '(191) 5854243', '12-Nov-1996', 'F', 'FALSE',
                                           '40 Dottie Plaza', 'ajakelj3@about.me');

insertdormmanagementdata.insertstudent('Zeb Lowdeane', '(115) 1699803', '23-Feb-1993', 'M', 'FALSE',
                                           '5204 Sachs Pass', 'zlowdeanej4@seattletimes.com');

insertdormmanagementdata.insertstudent('Tuesday Whetson', '(492) 7840176', '01-Dec-1999', 'F', 'FALSE',
                                           '24150 Almo Road', 'twhetsonj5@youtube.com');

insertdormmanagementdata.insertstudent('Maddie Grigori', '(810) 8318229', '17-Jan-1990', 'F', 'FALSE',
                                           '28224 Comanche Terrace', 'mgrigorij6@illinois.edu');

insertdormmanagementdata.insertstudent('Kimbra Panyer', '(503) 1215804', '31-Jul-1991', 'F', 'FALSE',
                                           '4 Waubesa Hill', 'kpanyerj7@msn.com');

insertdormmanagementdata.insertstudent('Arnuad Scawton', '(452) 1870878', '12-Aug-1997', 'M', 'FALSE',
                                           '22565 Tennyson Pass', 'ascawtonj8@spotify.com');

insertdormmanagementdata.insertstudent('Manon Dri', '(804) 6787438', '26-Nov-1995', 'F', 'FALSE',
                                           '139 Butterfield Park', 'mdrij9@example.com');

insertdormmanagementdata.insertstudent('Olag McLean', '(807) 5065377', '11-Sep-1994', 'M', 'FALSE',
                                           '43 Walton Alley', 'omcleanja@pbs.org');

insertdormmanagementdata.insertstudent('Bren Flahy', '(163) 5102215', '14-Jan-2002', 'M', 'FALSE',
                                           '07 Forest Run Pass', 'bflahyjb@storify.com');

insertdormmanagementdata.insertstudent('Nataniel Retchless', '(129) 6199467', '15-Feb-1990', 'M', 'FALSE',
                                           '678 Doe Crossing Parkway', 'nretchlessjc@delicious.com');

insertdormmanagementdata.insertstudent('Millie Sambells', '(969) 3970875', '16-Jan-1997', 'F', 'FALSE',
                                           '1 Anzinger Terrace', 'msambellsjd@twitpic.com');

insertdormmanagementdata.insertstudent('Clovis Ireland', '(772) 6087500', '05-Feb-1993', 'F', 'FALSE',
                                           '03431 Lindbergh Avenue', 'cirelandje@netvibes.com');

insertdormmanagementdata.insertstudent('Ruddie Weetch', '(798) 9775978', '07-Feb-1996', 'M', 'FALSE',
                                           '74 Daystar Lane', 'rweetchjf@pagesperso-orange.fr');

insertdormmanagementdata.insertstudent('Karlotte Cassell', '(230) 5637402', '10-Jul-1995', 'F', 'FALSE',
                                           '9 Hermina Point', 'kcasselljg@columbia.edu');

insertdormmanagementdata.insertstudent('Inness Dot', '(821) 5578411', '08-Apr-1995', 'M', 'FALSE',
                                           '499 Westerfield Hill', 'idotjh@wired.com');

insertdormmanagementdata.insertstudent('Malissa Arpe', '(109) 4179469', '11-Feb-1995', 'F', 'FALSE',
                                           '93 Clove Park', 'marpeji@hibu.com');

insertdormmanagementdata.insertstudent('Waldo Muzzollo', '(284) 5740122', '22-Apr-1992', 'M', 'FALSE',
                                           '1476 7th Street', 'wmuzzollojj@parallels.com');

insertdormmanagementdata.insertstudent('Yance Drescher', '(137) 4174589', '30-Jul-1998', 'M', 'FALSE',
                                           '0 Badeau Terrace', 'ydrescherjk@bing.com');

insertdormmanagementdata.insertstudent('Ines Merwe', '(997) 4479926', '23-Jan-1996', 'F', 'FALSE',
                                           '0004 Village Place', 'imerwejl@bloglines.com');

insertdormmanagementdata.insertstudent('Melisa Gratland', '(837) 4604375', '30-Aug-1991', 'F', 'FALSE',
                                           '1 Daystar Junction', 'mgratlandjm@chronoengine.com');

insertdormmanagementdata.insertstudent('Emalee Feldhammer', '(783) 8137259', '26-Mar-1997', 'F', 'FALSE',
                                           '472 Orin Place', 'efeldhammerjn@nbcnews.com');

insertdormmanagementdata.insertstudent('Else Souley', '(135) 8731206', '02-May-1999', 'F', 'FALSE',
                                           '3 Hanson Lane', 'esouleyjo@lycos.com');

insertdormmanagementdata.insertstudent('Josi Cawthera', '(366) 7704956', '10-Feb-1998', 'F', 'FALSE',
                                           '633 Eastlawn Place', 'jcawtherajp@sciencedaily.com');

insertdormmanagementdata.insertstudent('Jillane Zmitrichenko', '(962) 6218882', '10-Mar-1997', 'F', 'FALSE',
                                           '7 Derek Street', 'jzmitrichenkojq@wufoo.com');

insertdormmanagementdata.insertstudent('Reba Halson', '(625) 6668523', '07-Nov-1995', 'F', 'FALSE',
                                           '12 Marcy Place', 'rhalsonjr@istockphoto.com');

insertdormmanagementdata.insertstudent('Moreen Plumer', '(284) 3706199', '29-Jul-1993', 'F', 'FALSE',
                                           '60 Shoshone Crossing', 'mplumerjs@mozilla.com');

insertdormmanagementdata.insertstudent('Dorthea Jackalin', '(126) 5655370', '09-Jul-1999', 'F', 'FALSE',
                                           '83 Merrick Crossing', 'djackalinjt@over-blog.com');

insertdormmanagementdata.insertstudent('Elspeth Prudham', '(449) 1017314', '26-Mar-1998', 'F', 'FALSE',
                                           '53 Lunder Hill', 'eprudhamju@cbc.ca');

insertdormmanagementdata.insertstudent('Hurley Morillas', '(517) 1054481', '11-Jan-1995', 'M', 'FALSE',
                                           '5 Pepper Wood Point', 'hmorillasjv@deliciousdays.com');

insertdormmanagementdata.insertstudent('Marlyn Grishinov', '(517) 3313235', '15-Dec-2001', 'F', 'FALSE',
                                           '23 Reinke Plaza', 'mgrishinovjw@creativecommons.org');

insertdormmanagementdata.insertstudent('Son Muzzullo', '(403) 3838945', '15-Nov-2001', 'M', 'FALSE',
                                           '97 Kipling Junction', 'smuzzullojx@google.com.br');

insertdormmanagementdata.insertstudent('Hanni Sherlock', '(532) 5889936', '04-Nov-1995', 'F', 'FALSE',
                                           '67004 Debs Hill', 'hsherlockjy@people.com.cn');

insertdormmanagementdata.insertstudent('Gregorius Hurran', '(372) 9412302', '23-May-1992', 'M', 'FALSE',
                                           '21 Division Alley', 'ghurranjz@irs.gov');

insertdormmanagementdata.insertstudent('Rorie Pidgen', '(487) 1193290', '16-Apr-1999', 'F', 'FALSE',
                                           '286 Steensland Pass', 'rpidgenk0@weebly.com');

insertdormmanagementdata.insertstudent('Ev Karlowicz', '(972) 7611328', '01-Aug-2000', 'M', 'FALSE',
                                           '01603 Helena Place', 'ekarlowiczk1@msu.edu');

insertdormmanagementdata.insertstudent('Micheal Rignall', '(922) 7978249', '09-Mar-1992', 'M', 'FALSE',
                                           '61 Moose Plaza', 'mrignallk2@mit.edu');

insertdormmanagementdata.insertstudent('Gaultiero Schubert', '(788) 5800180', '18-Jul-1992', 'M', 'FALSE',
                                           '9544 Hanson Place', 'gschubertk3@discuz.net');

insertdormmanagementdata.insertstudent('Flore Luckwell', '(673) 2274979', '14-Oct-1993', 'F', 'FALSE',
                                           '470 Meadow Vale Terrace', 'fluckwellk4@telegraph.co.uk');

insertdormmanagementdata.insertstudent('Miquela Maynell', '(757) 4796971', '16-Jan-1996', 'F', 'FALSE',
                                           '09492 Thackeray Place', 'mmaynellk5@addthis.com');

insertdormmanagementdata.insertstudent('Renaldo Ludlem', '(462) 9381135', '19-Sep-1995', 'M', 'FALSE',
                                           '93 Westerfield Park', 'rludlemk6@ibm.com');

insertdormmanagementdata.insertstudent('Ruthy Thacke', '(440) 2776493', '23-Oct-2000', 'F', 'FALSE',
                                           '92523 Darwin Parkway', 'rthackek7@census.gov');

insertdormmanagementdata.insertstudent('Nanon Gowdy', '(657) 3184214', '06-Dec-1997', 'F', 'FALSE',
                                           '59 Parkside Park', 'ngowdyk8@people.com.cn');

insertdormmanagementdata.insertstudent('Gerri Tedstone', '(310) 3852162', '23-Sep-2002', 'F', 'FALSE',
                                           '6 Comanche Plaza', 'gtedstonek9@hud.gov');

insertdormmanagementdata.insertstudent('Georgiana Pankhurst.', '(153) 4193609', '17-Sep-1994', 'F', 'FALSE',
                                           '35 Porter Lane', 'gpankhurstka@uiuc.edu');

insertdormmanagementdata.insertstudent('Hedvige Divis', '(820) 4364923', '10-Nov-1994', 'F', 'FALSE',
                                           '3 Doe Crossing Road', 'hdiviskb@mit.edu');

insertdormmanagementdata.insertstudent('Scotti Columbine', '(118) 9264635', '20-May-1996', 'M', 'FALSE',
                                           '02619 Jackson Circle', 'scolumbinekc@usa.gov');

insertdormmanagementdata.insertstudent('Dotti Lowles', '(242) 9604942', '28-Feb-1998', 'F', 'FALSE',
                                           '70 Springs Court', 'dlowleskd@t-online.de');

insertdormmanagementdata.insertstudent('Rayna Phelips', '(726) 4422502', '16-May-1994', 'F', 'FALSE',
                                           '1 Declaration Point', 'rphelipske@mediafire.com');

insertdormmanagementdata.insertstudent('Cristal Buckner', '(589) 6045932', '05-Nov-1993', 'F', 'FALSE',
                                           '58835 Buhler Drive', 'cbucknerkf@phpbb.com');

insertdormmanagementdata.insertstudent('Emlen Hoston', '(613) 9865649', '15-Apr-1998', 'M', 'FALSE',
                                           '8918 Merry Street', 'ehostonkg@google.es');

insertdormmanagementdata.insertstudent('Keelby Zarfat', '(750) 9547651', '25-May-1997', 'M', 'FALSE',
                                           '6 Glendale Drive', 'kzarfatkh@furl.net');

insertdormmanagementdata.insertstudent('Dosi Rounding', '(962) 5170315', '22-Oct-1991', 'F', 'FALSE',
                                           '9925 4th Way', 'droundingki@jimdo.com');

insertdormmanagementdata.insertstudent('Freddie Alforde', '(870) 4093890', '19-Oct-1995', 'M', 'FALSE',
                                           '05 5th Plaza', 'falfordekj@theatlantic.com');

insertdormmanagementdata.insertstudent('Stephen Culleford', '(687) 5465904', '06-Feb-1997', 'M', 'FALSE',
                                           '79 Raven Crossing', 'scullefordkk@icio.us');

insertdormmanagementdata.insertstudent('Maxim Orlton', '(207) 2891446', '24-May-1994', 'M', 'FALSE',
                                           '432 Loomis Terrace', 'morltonkl@ca.gov');

insertdormmanagementdata.insertstudent('Manolo Lisamore', '(268) 9516123', '12-Nov-1994', 'M', 'FALSE',
                                           '827 Ronald Regan Lane', 'mlisamorekm@ocn.ne.jp');

insertdormmanagementdata.insertstudent('Dorie Fransemai', '(210) 4779623', '25-Jan-2001', 'F', 'FALSE',
                                           '60751 Bultman Plaza', 'dfransemaikn@sciencedirect.com');

insertdormmanagementdata.insertstudent('Suellen Resdale', '(305) 1164482', '22-Jul-2000', 'F', 'FALSE',
                                           '9924 Parkside Road', 'sresdaleko@ted.com');

insertdormmanagementdata.insertstudent('Francene Elderkin', '(184) 4717953', '23-Nov-1990', 'F', 'FALSE',
                                           '8 Arapahoe Pass', 'felderkinkp@4shared.com');

insertdormmanagementdata.insertstudent('Christal Harkes', '(248) 6718979', '22-Aug-1994', 'F', 'FALSE',
                                           '45 Fisk Alley', 'charkeskq@loc.gov');

insertdormmanagementdata.insertstudent('Olag Lidell', '(161) 8297176', '13-May-1994', 'M', 'FALSE',
                                           '914 Mitchell Court', 'olidellkr@businessinsider.com');

insertdormmanagementdata.insertstudent('Allen Lackinton', '(516) 3295227', '14-Apr-1999', 'M', 'FALSE',
                                           '7 Beilfuss Street', 'alackintonks@pinterest.com');

insertdormmanagementdata.insertstudent('Inglebert Doog', '(163) 9209160', '22-Apr-1995', 'M', 'FALSE',
                                           '3563 Orin Point', 'idoogkt@wikia.com');

insertdormmanagementdata.insertstudent('Consuela Pinches', '(239) 6381762', '01-Mar-2001', 'F', 'FALSE',
                                           '845 Lakewood Street', 'cpinchesku@senate.gov');

insertdormmanagementdata.insertstudent('Susan Sollime', '(387) 7829389', '22-Mar-1994', 'F', 'FALSE',
                                           '143 Schlimgen Trail', 'ssollimekv@cnbc.com');

insertdormmanagementdata.insertstudent('Tabbie Lalor', '(866) 1347083', '24-Aug-2000', 'M', 'FALSE',
                                           '5896 Melby Plaza', 'tlalorkw@ucsd.edu');

insertdormmanagementdata.insertstudent('Lynn Josilowski', '(263) 2099850', '19-Dec-1991', 'F', 'FALSE',
                                           '84 Mockingbird Place', 'ljosilowskikx@etsy.com');

insertdormmanagementdata.insertstudent('Klemens Congrave', '(684) 4414964', '02-Sep-2000', 'M', 'FALSE',
                                           '8708 Rieder Hill', 'kcongraveky@walmart.com');

insertdormmanagementdata.insertstudent('Olivier Farries', '(735) 2449883', '03-Nov-1997', 'M', 'FALSE',
                                           '8 Montana Crossing', 'ofarrieskz@google.co.uk');

insertdormmanagementdata.insertstudent('Sabra Kinzel', '(544) 1952268', '15-Feb-1996', 'F', 'FALSE',
                                           '848 Graedel Avenue', 'skinzell0@storify.com');

insertdormmanagementdata.insertstudent('Wilfrid Gynn', '(919) 9639544', '13-Jun-1998', 'M', 'FALSE',
                                           '9 Hansons Crossing', 'wgynnl1@columbia.edu');

insertdormmanagementdata.insertstudent('Viviene Brockley', '(773) 7693396', '12-Oct-1998', 'F', 'FALSE',
                                           '1 Eagan Avenue', 'vbrockleyl2@multiply.com');

insertdormmanagementdata.insertstudent('Carlyn Tromans', '(943) 7116842', '14-Aug-1990', 'F', 'FALSE',
                                           '68 Continental Way', 'ctromansl3@fc2.com');

insertdormmanagementdata.insertstudent('Franky Giorgioni', '(384) 5285274', '29-Mar-1990', 'M', 'FALSE',
                                           '097 Fulton Drive', 'fgiorgionil4@newyorker.com');

insertdormmanagementdata.insertstudent('Bailie Tumpane', '(910) 3217388', '01-Jun-1996', 'M', 'FALSE',
                                           '801 Florence Hill', 'btumpanel5@prweb.com');

insertdormmanagementdata.insertstudent('Marty Vickors', '(241) 6448303', '23-Jan-1992', 'M', 'FALSE',
                                           '17 Everett Crossing', 'mvickorsl6@constantcontact.com');

insertdormmanagementdata.insertstudent('Purcell Charity', '(404) 8560652', '15-Sep-1999', 'M', 'FALSE',
                                           '08 Hayes Way', 'pcharityl7@histats.com');

insertdormmanagementdata.insertstudent('Tomkin Hansford', '(999) 4737681', '23-Apr-1994', 'M', 'FALSE',
                                           '5 Clarendon Lane', 'thansfordl8@discovery.com');

insertdormmanagementdata.insertstudent('Angil Gives', '(671) 6395404', '08-Oct-1991', 'F', 'FALSE',
                                           '10 Anzinger Pass', 'agivesl9@oracle.com');

insertdormmanagementdata.insertstudent('Lindsay Dumphries', '(707) 2972802', '13-Dec-1996', 'M', 'FALSE',
                                           '03 Jenna Way', 'ldumphriesla@cam.ac.uk');

insertdormmanagementdata.insertstudent('Philis Shorten', '(552) 3890938', '05-Dec-1992', 'F', 'FALSE',
                                           '1 Boyd Court', 'pshortenlb@sina.com.cn');

insertdormmanagementdata.insertstudent('Fallon Lanchbury', '(340) 5240690', '27-Feb-1999', 'F', 'FALSE',
                                           '8983 Huxley Drive', 'flanchburylc@liveinternet.ru');

insertdormmanagementdata.insertstudent('Bryanty Metzig', '(722) 1940890', '04-Mar-1993', 'M', 'FALSE',
                                           '19 Cascade Crossing', 'bmetzigld@auda.org.au');

insertdormmanagementdata.insertstudent('Erl Larwood', '(721) 7635014', '15-Apr-1995', 'M', 'FALSE',
                                           '16462 Anthes Pass', 'elarwoodle@springer.com');

insertdormmanagementdata.insertstudent('Franni Chaundy', '(784) 4882158', '29-Mar-1995', 'F', 'FALSE',
                                           '5051 Pleasure Circle', 'fchaundylf@salon.com');

insertdormmanagementdata.insertstudent('Prissie Canceller', '(542) 9128484', '22-Nov-1991', 'F', 'FALSE',
                                           '45427 Fremont Plaza', 'pcancellerlg@wisc.edu');

insertdormmanagementdata.insertstudent('Thurston Davidove', '(481) 8920428', '19-Sep-1999', 'M', 'FALSE',
                                           '821 Schlimgen Circle', 'tdavidovelh@myspace.com');

insertdormmanagementdata.insertstudent('Elnora Howship', '(888) 6940267', '14-Dec-2001', 'F', 'FALSE',
                                           '63 Mandrake Pass', 'ehowshipli@jimdo.com');

insertdormmanagementdata.insertstudent('Tallie Cremen', '(149) 7836982', '09-Dec-2002', 'M', 'FALSE',
                                           '2521 Vermont Junction', 'tcremenlj@ehow.com');

insertdormmanagementdata.insertstudent('Paco Tapply', '(974) 8898644', '29-Nov-1998', 'M', 'FALSE',
                                           '690 Northport Street', 'ptapplylk@hexun.com');

insertdormmanagementdata.insertstudent('Reeta Huncote', '(867) 3039202', '24-Mar-1990', 'F', 'FALSE',
                                           '2748 Bobwhite Drive', 'rhuncotell@google.pl');

insertdormmanagementdata.insertstudent('Johny Windless', '(253) 1562161', '10-Jan-1998', 'M', 'FALSE',
                                           '39 Holmberg Parkway', 'jwindlesslm@merriam-webster.com');

insertdormmanagementdata.insertstudent('Tadd Lethcoe', '(124) 3817943', '16-Dec-2001', 'M', 'FALSE',
                                           '682 Harper Road', 'tlethcoeln@flickr.com');

insertdormmanagementdata.insertstudent('Stacia Twelvetrees', '(359) 7471334', '29-Apr-1992', 'F', 'FALSE',
                                           '015 Independence Lane', 'stwelvetreeslo@cmu.edu');

insertdormmanagementdata.insertstudent('Yolanthe Levick', '(224) 5439796', '10-Sep-1996', 'F', 'FALSE',
                                           '2 Cardinal Junction', 'ylevicklp@abc.net.au');

insertdormmanagementdata.insertstudent('Harry Colcutt', '(232) 5461150', '14-Sep-1994', 'M', 'FALSE',
                                           '07194 Moose Avenue', 'hcolcuttlq@deviantart.com');

insertdormmanagementdata.insertstudent('Charita Camerana', '(249) 2345106', '14-Jul-1992', 'F', 'FALSE',
                                           '1 Northland Alley', 'ccameranalr@blogtalkradio.com');

insertdormmanagementdata.insertstudent('Sheelagh Clymer', '(412) 4188860', '10-May-1993', 'F', 'FALSE',
                                           '75 Tomscot Crossing', 'sclymerls@edublogs.org');

insertdormmanagementdata.insertstudent('Bernete Pollitt', '(960) 1361311', '16-May-1995', 'F', 'FALSE',
                                           '59350 Lakewood Crossing', 'bpollittlt@webmd.com');

insertdormmanagementdata.insertstudent('Hobart Kasparski', '(695) 6324265', '18-Aug-1995', 'M', 'FALSE',
                                           '7 Harper Circle', 'hkasparskilu@constantcontact.com');

insertdormmanagementdata.insertstudent('Farly Alvis', '(568) 6321660', '07-Oct-1997', 'M', 'FALSE',
                                           '41841 Mccormick Junction', 'falvislv@vinaora.com');

insertdormmanagementdata.insertstudent('Larisa Botger', '(103) 9241567', '10-Jun-1994', 'F', 'FALSE',
                                           '33189 Sutteridge Pass', 'lbotgerlw@usnews.com');

insertdormmanagementdata.insertstudent('Oralla Damiata', '(199) 4754462', '04-Sep-2000', 'F', 'FALSE',
                                           '19 Banding Way', 'odamiatalx@nbcnews.com');

insertdormmanagementdata.insertstudent('Shermy Ferrillio', '(120) 2367045', '23-Jun-1999', 'M', 'FALSE',
                                           '00 Bellgrove Crossing', 'sferrillioly@bloomberg.com');

insertdormmanagementdata.insertstudent('Sherlock Walkden', '(759) 1379817', '14-Apr-1996', 'M', 'FALSE',
                                           '78897 Manitowish Circle', 'swalkdenlz@narod.ru');

insertdormmanagementdata.insertstudent('Mark Elster', '(273) 8532221', '07-Mar-1999', 'M', 'FALSE',
                                           '477 Iowa Plaza', 'melsterm0@google.co.jp');

insertdormmanagementdata.insertstudent('Alejandrina Barkhouse', '(412) 3599489', '13-Jul-1997', 'F', 'FALSE',
                                           '1 Northfield Drive', 'abarkhousem1@uiuc.edu');

insertdormmanagementdata.insertstudent('Erminia Mayoral', '(444) 5881422', '28-Dec-1994', 'F', 'FALSE',
                                           '116 Porter Court', 'emayoralm2@last.fm');

insertdormmanagementdata.insertstudent('Debby Ghost', '(206) 3467923', '21-Oct-2001', 'F', 'FALSE',
                                           '1477 Michigan Terrace', 'dghostm3@bbb.org');

insertdormmanagementdata.insertstudent('Alfredo Huston', '(842) 5842387', '11-Oct-2002', 'M', 'FALSE',
                                           '2 Golf View Center', 'ahustonm4@wix.com');

insertdormmanagementdata.insertstudent('Renado Phython', '(203) 5757813', '24-May-1995', 'M', 'FALSE',
                                           '636 La Follette Place', 'rphythonm5@biblegateway.com');

insertdormmanagementdata.insertstudent('Kennan Shatliffe', '(305) 1385384', '19-Jan-1991', 'M', 'FALSE',
                                           '53595 Milwaukee Plaza', 'kshatliffem6@berkeley.edu');

insertdormmanagementdata.insertstudent('Randie Iowarch', '(558) 3149185', '18-Feb-2001', 'M', 'FALSE',
                                           '2 Grim Street', 'riowarchm7@chron.com');

insertdormmanagementdata.insertstudent('Cathy Conrath', '(626) 5004239', '30-Dec-1997', 'F', 'FALSE',
                                           '5878 Di Loreto Plaza', 'cconrathm8@java.com');

insertdormmanagementdata.insertstudent('Harwilll Benian', '(426) 5231634', '07-Jun-1996', 'M', 'FALSE',
                                           '1 Towne Lane', 'hbenianm9@canalblog.com');

insertdormmanagementdata.insertstudent('Judie Eaklee', '(635) 6594138', '11-Feb-1994', 'F', 'FALSE',
                                           '52 Oneill Point', 'jeakleema@omniture.com');

insertdormmanagementdata.insertstudent('Adina Claremont', '(897) 6970765', '11-Aug-1990', 'F', 'FALSE',
                                           '4 Ludington Place', 'aclaremontmb@slate.com');

insertdormmanagementdata.insertstudent('Tricia Spowart', '(884) 4749684', '12-Oct-2002', 'F', 'FALSE',
                                           '6010 Arrowood Parkway', 'tspowartmc@ezinearticles.com');

insertdormmanagementdata.insertstudent('Annmaria Willacot', '(150) 5752182', '11-Dec-1996', 'F', 'FALSE',
                                           '3 Westerfield Drive', 'awillacotmd@go.com');

insertdormmanagementdata.insertstudent('Reese Scamadine', '(639) 8172603', '12-Jun-1997', 'M', 'FALSE',
                                           '41667 Coolidge Center', 'rscamadineme@loc.gov');

insertdormmanagementdata.insertstudent('Ginny Riddel', '(845) 1229232', '01-Feb-2001', 'F', 'FALSE',
                                           '27 Buena Vista Avenue', 'griddelmf@princeton.edu');

insertdormmanagementdata.insertstudent('Vidovik Loddy', '(527) 8128939', '27-May-1992', 'M', 'FALSE',
                                           '884 Bunting Terrace', 'vloddymg@ibm.com');

insertdormmanagementdata.insertstudent('Ania Pantry', '(154) 4771143', '11-Feb-1991', 'F', 'FALSE',
                                           '4 Meadow Vale Circle', 'apantrymh@chron.com');

insertdormmanagementdata.insertstudent('Alys Liles', '(342) 7810139', '18-Oct-1993', 'F', 'FALSE',
                                           '4218 Bellgrove Center', 'alilesmi@blinklist.com');

insertdormmanagementdata.insertstudent('Byrann Cottis', '(824) 8708956', '19-May-1993', 'M', 'FALSE',
                                           '733 Arapahoe Terrace', 'bcottismj@intel.com');

insertdormmanagementdata.insertstudent('Tori Sommerton', '(839) 5422689', '10-May-1998', 'F', 'FALSE',
                                           '31621 Donald Road', 'tsommertonmk@usgs.gov');

insertdormmanagementdata.insertstudent('Annadiana Weins', '(651) 1708837', '19-Dec-1998', 'F', 'FALSE',
                                           '2 Hintze Park', 'aweinsml@biblegateway.com');

insertdormmanagementdata.insertstudent('Estel Delf', '(805) 4951070', '19-Mar-2000', 'F', 'FALSE',
                                           '1 Bonner Crossing', 'edelfmm@mediafire.com');

insertdormmanagementdata.insertstudent('Darb Morot', '(956) 9284185', '04-Mar-2000', 'M', 'FALSE',
                                           '5464 Delladonna Trail', 'dmorotmn@homestead.com');

insertdormmanagementdata.insertstudent('Donna Kidstoun', '(998) 8036526', '04-Jan-1998', 'F', 'FALSE',
                                           '4778 6th Road', 'dkidstounmo@icio.us');

insertdormmanagementdata.insertstudent('Odell Crut', '(797) 4613592', '02-Dec-1992', 'M', 'FALSE',
                                           '759 Mockingbird Drive', 'ocrutmp@nature.com');

insertdormmanagementdata.insertstudent('Nara Dorsey', '(486) 6135891', '02-Nov-1994', 'F', 'FALSE',
                                           '90610 Brentwood Parkway', 'ndorseymq@xing.com');

insertdormmanagementdata.insertstudent('Barbara-anne Ordidge', '(661) 2338864', '29-Nov-2001', 'F', 'FALSE',
                                           '5295 Rusk Avenue', 'bordidgemr@samsung.com');

insertdormmanagementdata.insertstudent('Averil Nunes Nabarro', '(286) 8300224', '07-Oct-1991', 'M', 'FALSE',
                                           '7867 Hoffman Crossing', 'anunesms@ftc.gov');

insertdormmanagementdata.insertstudent('Allister Beeton', '(181) 6435361', '25-Jul-2001', 'M', 'FALSE',
                                           '2 Larry Parkway', 'abeetonmt@upenn.edu');

insertdormmanagementdata.insertstudent('Cate Abelov', '(338) 9878163', '16-Dec-1996', 'F', 'FALSE',
                                           '266 Eastwood Way', 'cabelovmu@wordpress.org');

insertdormmanagementdata.insertstudent('Celestia Oldcote', '(300) 7253092', '06-Jul-1999', 'F', 'FALSE',
                                           '9628 Dahle Avenue', 'coldcotemv@domainmarket.com');

insertdormmanagementdata.insertstudent('Evy Filipczynski', '(952) 7726295', '05-Jul-1996', 'F', 'FALSE',
                                           '499 Straubel Avenue', 'efilipczynskimw@goodreads.com');

insertdormmanagementdata.insertstudent('Tamarah Dansken', '(382) 1368848', '14-May-1991', 'F', 'FALSE',
                                           '844 Lien Lane', 'tdanskenmx@lulu.com');

insertdormmanagementdata.insertstudent('Tori Felipe', '(377) 6547205', '21-Mar-1999', 'F', 'FALSE',
                                           '6413 Fordem Center', 'tfelipemy@howstuffworks.com');

insertdormmanagementdata.insertstudent('Sybila von Hagt', '(530) 2743642', '21-Jul-2000', 'F', 'FALSE',
                                           '9710 Ruskin Crossing', 'svonmz@yahoo.com');

insertdormmanagementdata.insertstudent('Gene Daud', '(420) 9172174', '29-Oct-1993', 'M', 'FALSE',
                                           '15 John Wall Trail', 'gdaudn0@ning.com');

insertdormmanagementdata.insertstudent('Verla Boakes', '(582) 7688719', '04-Jun-1991', 'F', 'FALSE',
                                           '24 Red Cloud Terrace', 'vboakesn1@exblog.jp');

insertdormmanagementdata.insertstudent('Donny Bondy', '(548) 2349753', '26-Aug-1990', 'F', 'FALSE',
                                           '7 Dorton Center', 'dbondyn2@nbcnews.com');

insertdormmanagementdata.insertstudent('Aurthur Oseman', '(103) 5968215', '08-Jul-1991', 'M', 'FALSE',
                                           '25 Dayton Avenue', 'aosemann3@bloglovin.com');

insertdormmanagementdata.insertstudent('Germaine Woonton', '(320) 5313714', '23-Jul-1993', 'M', 'FALSE',
                                           '90502 Brentwood Alley', 'gwoontonn4@jugem.jp');

insertdormmanagementdata.insertstudent('Red Verriour', '(253) 3777185', '27-Jan-1997', 'M', 'FALSE',
                                           '16 Eliot Terrace', 'rverriourn5@timesonline.co.uk');

insertdormmanagementdata.insertstudent('Braden Randleson', '(260) 5922389', '23-Feb-1990', 'M', 'FALSE',
                                           '10934 Kennedy Crossing', 'brandlesonn6@springer.com');

insertdormmanagementdata.insertstudent('Bernette Deverell', '(962) 8542325', '29-Jul-1995', 'F', 'FALSE',
                                           '24 Atwood Point', 'bdeverelln7@geocities.jp');

insertdormmanagementdata.insertstudent('Jorge Lohoar', '(961) 9994673', '04-Jul-2002', 'M', 'FALSE',
                                           '533 Del Sol Pass', 'jlohoarn8@merriam-webster.com');

insertdormmanagementdata.insertstudent('Horatio Twoohy', '(695) 3967452', '25-Feb-2001', 'M', 'FALSE',
                                           '312 Becker Way', 'htwoohyn9@freewebs.com');

insertdormmanagementdata.insertstudent('Briny Bolderson', '(808) 8013335', '01-Sep-1998', 'F', 'FALSE',
                                           '1 Garrison Way', 'bboldersonna@adobe.com');

insertdormmanagementdata.insertstudent('Rozella Girvin', '(507) 3947692', '12-Jun-1997', 'F', 'FALSE',
                                           '3682 Westport Lane', 'rgirvinnb@free.fr');

insertdormmanagementdata.insertstudent('Horatio Wooler', '(276) 5069098', '23-Jan-2001', 'M', 'FALSE',
                                           '59 Donald Park', 'hwoolernc@ebay.com');

insertdormmanagementdata.insertstudent('Carole Whitbread', '(896) 9804786', '26-Oct-1998', 'F', 'FALSE',
                                           '5 Jenna Court', 'cwhitbreadnd@google.nl');

insertdormmanagementdata.insertstudent('Teddy Corke', '(791) 9324365', '29-May-2000', 'M', 'FALSE',
                                           '520 Upham Circle', 'tcorkene@csmonitor.com');

insertdormmanagementdata.insertstudent('Stephine Minucci', '(700) 3055165', '08-Mar-1994', 'F', 'FALSE',
                                           '7 Saint Paul Point', 'sminuccinf@cmu.edu');

insertdormmanagementdata.insertstudent('Kane Povlsen', '(353) 7108064', '01-Sep-1996', 'M', 'FALSE',
                                           '025 Bunting Center', 'kpovlsenng@theatlantic.com');

insertdormmanagementdata.insertstudent('Fowler Witherby', '(742) 7860891', '06-Jul-1994', 'M', 'FALSE',
                                           '73 Talmadge Alley', 'fwitherbynh@yale.edu');

insertdormmanagementdata.insertstudent('Saul Domokos', '(370) 3491530', '20-Aug-1990', 'M', 'FALSE',
                                           '769 Waubesa Trail', 'sdomokosni@reuters.com');

insertdormmanagementdata.insertstudent('Elihu Shepcutt', '(838) 3487696', '16-Sep-1999', 'M', 'FALSE',
                                           '6 Bonner Lane', 'eshepcuttnj@timesonline.co.uk');

insertdormmanagementdata.insertstudent('Terry Skule', '(599) 5522357', '10-Dec-1998', 'M', 'FALSE',
                                           '6 Grasskamp Hill', 'tskulenk@newyorker.com');

insertdormmanagementdata.insertstudent('Chrotoem Pentony', '(561) 9619718', '29-Apr-1996', 'M', 'FALSE',
                                           '8351 Riverside Plaza', 'cpentonynl@dmoz.org');

insertdormmanagementdata.insertstudent('Franny Sim', '(175) 4007192', '17-Jul-2000', 'F', 'FALSE',
                                           '74253 Fordem Court', 'fsimnm@liveinternet.ru');

insertdormmanagementdata.insertstudent('Townsend Ratcliffe', '(953) 2805539', '24-May-1999', 'M', 'FALSE',
                                           '9275 Vernon Avenue', 'tratcliffenn@prnewswire.com');

insertdormmanagementdata.insertstudent('Welsh O''Hoey', '(735) 5299196', '30-Jun-1990', 'M', 'FALSE',
                                           '132 Melrose Junction', 'wohoeyno@instagram.com');

insertdormmanagementdata.insertstudent('Solomon Meredith', '(964) 5978546', '12-Dec-1994', 'M', 'FALSE',
                                           '871 Forster Alley', 'smeredithnp@fotki.com');

insertdormmanagementdata.insertstudent('Cristine Shales', '(825) 6378916', '26-Aug-1991', 'F', 'FALSE',
                                           '3 Orin Trail', 'cshalesnq@amazon.com');

insertdormmanagementdata.insertstudent('Neville Beddard', '(432) 5051770', '15-Apr-1993', 'M', 'FALSE',
                                           '043 Vernon Circle', 'nbeddardnr@macromedia.com');

insertdormmanagementdata.insertstudent('Farlay Twiname', '(819) 6164155', '25-Mar-2002', 'M', 'FALSE',
                                           '92 Rigney Circle', 'ftwinamens@gizmodo.com');

insertdormmanagementdata.insertstudent('Waly Caverhill', '(998) 2304717', '14-Jul-1997', 'F', 'FALSE',
                                           '00 Clyde Gallagher Crossing', 'wcaverhillnt@prweb.com');

insertdormmanagementdata.insertstudent('Nathanael Gresser', '(348) 9303357', '05-Oct-2001', 'M', 'FALSE',
                                           '373 Meadow Vale Court', 'ngressernu@geocities.jp');

insertdormmanagementdata.insertstudent('Lia Miroy', '(317) 7660891', '05-Oct-1993', 'F', 'FALSE',
                                           '1786 Corry Point', 'lmiroynv@ovh.net');

insertdormmanagementdata.insertstudent('Octavia Binding', '(397) 9544732', '06-Jul-1998', 'F', 'FALSE',
                                           '5 Jackson Circle', 'obindingnw@domainmarket.com');

insertdormmanagementdata.insertstudent('Franny Pratley', '(722) 2726866', '20-Apr-1996', 'F', 'FALSE',
                                           '65516 Grasskamp Street', 'fpratleynx@pbs.org');

insertdormmanagementdata.insertstudent('Elmira Garley', '(747) 9686599', '14-Feb-1999', 'F', 'FALSE',
                                           '992 Lawn Terrace', 'egarleyny@pinterest.com');

insertdormmanagementdata.insertstudent('Connie Louis', '(639) 3591564', '06-Sep-1998', 'F', 'FALSE',
                                           '9568 Farmco Hill', 'clouisnz@yellowpages.com');

insertdormmanagementdata.insertstudent('Yankee Yuryshev', '(803) 8076312', '22-Dec-1995', 'M', 'FALSE',
                                           '2036 Vernon Lane', 'yyuryshevo0@sun.com');

insertdormmanagementdata.insertstudent('Merrick Rickasse', '(577) 4792921', '06-Jun-1994', 'M', 'FALSE',
                                           '0786 Jana Alley', 'mrickasseo1@amazon.co.jp');

insertdormmanagementdata.insertstudent('Gwennie Toy', '(118) 8383331', '17-May-1998', 'F', 'FALSE',
                                           '6373 5th Circle', 'gtoyo2@bizjournals.com');

insertdormmanagementdata.insertstudent('Fae Widmore', '(618) 6837257', '04-May-1991', 'F', 'FALSE',
                                           '600 Reinke Street', 'fwidmoreo3@wiley.com');

insertdormmanagementdata.insertstudent('Luce Hadrill', '(385) 9428600', '16-Jul-1998', 'F', 'FALSE',
                                           '26120 Blackbird Center', 'lhadrillo4@ucoz.com');

insertdormmanagementdata.insertstudent('Lenette Titcom', '(445) 6757103', '05-Jan-2002', 'F', 'FALSE',
                                           '13167 Leroy Junction', 'ltitcomo5@hc360.com');

insertdormmanagementdata.insertstudent('Travis Forsdike', '(435) 9695779', '15-Jan-1999', 'M', 'FALSE',
                                           '99 Kedzie Road', 'tforsdikeo6@gravatar.com');

insertdormmanagementdata.insertstudent('Reinhard Northover', '(465) 8114041', '27-Nov-1997', 'M', 'FALSE',
                                           '724 Namekagon Circle', 'rnorthovero7@ustream.tv');

insertdormmanagementdata.insertstudent('Lenora Aronov', '(581) 2916973', '29-Oct-2002', 'F', 'FALSE',
                                           '38258 Shelley Hill', 'laronovo8@friendfeed.com');

insertdormmanagementdata.insertstudent('Betta Chismon', '(518) 7861857', '16-Mar-1993', 'F', 'FALSE',
                                           '50439 Dixon Drive', 'bchismono9@wikispaces.com');

insertdormmanagementdata.insertstudent('Lamar MacNeish', '(368) 7246274', '10-Dec-1999', 'M', 'FALSE',
                                           '141 Glacier Hill Plaza', 'lmacneishoa@youtube.com');

insertdormmanagementdata.insertstudent('Rafaello Crickmer', '(850) 2039147', '25-Aug-2002', 'M', 'FALSE',
                                           '3 Vermont Street', 'rcrickmerob@zimbio.com');

insertdormmanagementdata.insertstudent('Lemuel Beauchop', '(632) 6737418', '03-Sep-1999', 'M', 'FALSE',
                                           '282 Melody Point', 'lbeauchopoc@columbia.edu');

insertdormmanagementdata.insertstudent('Shurlocke Muncer', '(464) 5031659', '29-Jun-2001', 'M', 'FALSE',
                                           '8203 Meadow Valley Pass', 'smuncerod@ehow.com');

insertdormmanagementdata.insertstudent('Lidia Klainman', '(904) 4170306', '05-Jan-2002', 'F', 'FALSE',
                                           '65 Gulseth Alley', 'lklainmanoe@addthis.com');

insertdormmanagementdata.insertstudent('Elsy Cordes', '(213) 9721536', '27-Jun-1993', 'F', 'FALSE',
                                           '21221 Mccormick Circle', 'ecordesof@opera.com');

insertdormmanagementdata.insertstudent('Jorie Mitchelson', '(526) 8366874', '29-Jun-2001', 'F', 'FALSE',
                                           '84 American Park', 'jmitchelsonog@posterous.com');

insertdormmanagementdata.insertstudent('Therese Salmons', '(763) 2556071', '04-Jul-2002', 'F', 'FALSE',
                                           '56270 Barby Plaza', 'tsalmonsoh@shutterfly.com');

insertdormmanagementdata.insertstudent('Gene Oldham', '(245) 3508424', '10-Jul-1999', 'M', 'FALSE',
                                           '69430 Village Green Drive', 'goldhamoi@joomla.org');

insertdormmanagementdata.insertstudent('Muhammad Muckloe', '(575) 3484334', '19-Sep-1995', 'M', 'FALSE',
                                           '8 Acker Junction', 'mmuckloeoj@homestead.com');

insertdormmanagementdata.insertstudent('Tommie Laviss', '(994) 4390876', '06-May-1991', 'M', 'FALSE',
                                           '97086 Becker Junction', 'tlavissok@edublogs.org');

insertdormmanagementdata.insertstudent('Louella Stryde', '(702) 2699163', '22-Nov-1998', 'F', 'FALSE',
                                           '05680 Stang Lane', 'lstrydeol@ibm.com');

insertdormmanagementdata.insertstudent('Charley Van Saltsberg', '(629) 5258810', '09-May-2001', 'M', 'FALSE',
                                           '8705 Pine View Place', 'cvanom@java.com');

insertdormmanagementdata.insertstudent('Eugenius Delea', '(292) 5735755', '03-May-1993', 'M', 'FALSE',
                                           '73 Beilfuss Junction', 'edeleaon@wikia.com');

insertdormmanagementdata.insertstudent('Jule Melding', '(714) 1203796', '21-Oct-1994', 'M', 'FALSE',
                                           '8 Shoshone Hill', 'jmeldingoo@google.com.au');

insertdormmanagementdata.insertstudent('Roy Purdom', '(884) 4837344', '04-May-1996', 'M', 'FALSE',
                                           '02606 Valley Edge Pass', 'rpurdomop@businesswire.com');

insertdormmanagementdata.insertstudent('Freddi Philpot', '(805) 9997959', '27-Sep-1999', 'F', 'FALSE',
                                           '74 Main Park', 'fphilpotoq@webmd.com');

insertdormmanagementdata.insertstudent('Becki MacDavitt', '(381) 8558458', '14-Apr-2001', 'F', 'FALSE',
                                           '13 Ruskin Junction', 'bmacdavittor@eepurl.com');

insertdormmanagementdata.insertstudent('Kylila Wheelhouse', '(600) 5318855', '20-Apr-1991', 'F', 'FALSE',
                                           '0750 Dwight Plaza', 'kwheelhouseos@php.net');

insertdormmanagementdata.insertstudent('Izak Jaher', '(686) 2129366', '13-Dec-1991', 'M', 'FALSE',
                                           '5 Dryden Park', 'ijaherot@vimeo.com');

insertdormmanagementdata.insertstudent('Corbie Goodliffe', '(224) 5096922', '25-Mar-2001', 'M', 'FALSE',
                                           '6 Crowley Place', 'cgoodliffeou@github.com');

insertdormmanagementdata.insertstudent('Theodosia Gealy', '(849) 7892406', '23-Oct-2002', 'F', 'FALSE',
                                           '5572 Shelley Court', 'tgealyov@ifeng.com');

insertdormmanagementdata.insertstudent('Genevieve Stammler', '(462) 3356582', '07-Sep-1992', 'F', 'FALSE',
                                           '4 Kedzie Crossing', 'gstammlerow@cpanel.net');

insertdormmanagementdata.insertstudent('Ganny Lushey', '(532) 5794615', '25-Sep-1998', 'M', 'FALSE',
                                           '048 Warrior Place', 'glusheyox@slideshare.net');

insertdormmanagementdata.insertstudent('Peria Ure', '(947) 5516135', '22-Jan-1998', 'F', 'FALSE',
                                           '1 Grayhawk Avenue', 'pureoy@gmpg.org');

insertdormmanagementdata.insertstudent('Etan Couling', '(144) 7994410', '14-Nov-1999', 'M', 'FALSE',
                                           '35997 Grayhawk Way', 'ecoulingoz@uol.com.br');

insertdormmanagementdata.insertstudent('Mario Rogez', '(835) 6064189', '14-Jul-1990', 'M', 'FALSE',
                                           '163 Buena Vista Avenue', 'mrogezp0@blogger.com');

insertdormmanagementdata.insertstudent('Barth Hovy', '(363) 9115106', '18-Nov-1996', 'M', 'FALSE',
                                           '8699 Myrtle Terrace', 'bhovyp1@cornell.edu');

insertdormmanagementdata.insertstudent('Tab Bigglestone', '(285) 6226940', '24-Jan-1992', 'M', 'FALSE',
                                           '053 Garrison Street', 'tbigglestonep2@nps.gov');

insertdormmanagementdata.insertstudent('Mandy Simond', '(767) 4173741', '01-Dec-1998', 'F', 'FALSE',
                                           '972 4th Park', 'msimondp3@clickbank.net');

insertdormmanagementdata.insertstudent('Maurise Antoni', '(205) 8117102', '25-Mar-1994', 'F', 'FALSE',
                                           '667 Clemons Trail', 'mantonip4@hc360.com');

insertdormmanagementdata.insertstudent('El Lafrentz', '(934) 5106686', '15-Jul-2002', 'M', 'FALSE',
                                           '8791 Algoma Junction', 'elafrentzp5@ask.com');

insertdormmanagementdata.insertstudent('Mannie Housden', '(433) 8024947', '16-Nov-1995', 'M', 'FALSE',
                                           '55 Schurz Court', 'mhousdenp6@wisc.edu');

insertdormmanagementdata.insertstudent('Claybourne MacLeod', '(774) 5703610', '26-Jul-1990', 'M', 'FALSE',
                                           '17605 Maywood Crossing', 'cmacleodp7@admin.ch');

insertdormmanagementdata.insertstudent('Tadeas Burstow', '(436) 7940472', '22-Aug-2000', 'M', 'FALSE',
                                           '18157 Derek Court', 'tburstowp8@youku.com');

insertdormmanagementdata.insertstudent('Livia Handford', '(433) 3214695', '15-Oct-1996', 'F', 'FALSE',
                                           '9482 Monica Plaza', 'lhandfordp9@blog.com');

insertdormmanagementdata.insertstudent('Brenna MacFaul', '(376) 6927015', '11-Oct-1998', 'F', 'FALSE',
                                           '954 Steensland Point', 'bmacfaulpa@japanpost.jp');

insertdormmanagementdata.insertstudent('Martguerita Clinch', '(739) 6667507', '28-Feb-1995', 'F', 'FALSE',
                                           '6 Springview Circle', 'mclinchpb@state.gov');

insertdormmanagementdata.insertstudent('Patrizia Lyngsted', '(782) 4575762', '15-Mar-2002', 'F', 'FALSE',
                                           '72 Stuart Park', 'plyngstedpc@shinystat.com');

insertdormmanagementdata.insertstudent('Kerstin Valentelli', '(784) 6595451', '01-May-1995', 'F', 'FALSE',
                                           '220 Scott Plaza', 'kvalentellipd@tinypic.com');

insertdormmanagementdata.insertstudent('Joanie Naptin', '(993) 5836834', '16-Feb-1990', 'F', 'FALSE',
                                           '160 Anderson Place', 'jnaptinpe@is.gd');

insertdormmanagementdata.insertstudent('Georg Irdale', '(249) 3070277', '05-Apr-1998', 'M', 'FALSE',
                                           '79 Scott Center', 'girdalepf@yahoo.co.jp');

insertdormmanagementdata.insertstudent('Alyse Kuhl', '(361) 1008302', '22-Jun-1992', 'F', 'FALSE',
                                           '8 Schlimgen Road', 'akuhlpg@timesonline.co.uk');

insertdormmanagementdata.insertstudent('Tremaine Levesley', '(670) 2019647', '01-Jun-1992', 'M', 'FALSE',
                                           '807 Fair Oaks Alley', 'tlevesleyph@shop-pro.jp');

insertdormmanagementdata.insertstudent('Jesselyn Lazenby', '(203) 8680815', '15-Jul-1992', 'F', 'FALSE',
                                           '09126 Randy Parkway', 'jlazenbypi@seattletimes.com');

insertdormmanagementdata.insertstudent('Alick Wortman', '(242) 3949791', '18-Aug-1990', 'M', 'FALSE',
                                           '841 Schiller Alley', 'awortmanpj@chron.com');

insertdormmanagementdata.insertstudent('Ruy Kersting', '(470) 8677083', '28-Apr-2000', 'M', 'FALSE',
                                           '062 Prentice Avenue', 'rkerstingpk@tmall.com');

insertdormmanagementdata.insertstudent('Corbett Ashlee', '(430) 2333797', '23-Jun-1992', 'M', 'FALSE',
                                           '35 Bluestem Place', 'cashleepl@yahoo.co.jp');

insertdormmanagementdata.insertstudent('Vick Potkins', '(380) 8654274', '14-Nov-1999', 'M', 'FALSE',
                                           '1 Beilfuss Point', 'vpotkinspm@fotki.com');

insertdormmanagementdata.insertstudent('Liv Ferney', '(521) 7226462', '28-Jun-1995', 'F', 'FALSE',
                                           '091 Dennis Crossing', 'lferneypn@slate.com');

insertdormmanagementdata.insertstudent('Beret Adamsen', '(756) 5973570', '21-Mar-1998', 'F', 'FALSE',
                                           '88659 Summerview Hill', 'badamsenpo@furl.net');

insertdormmanagementdata.insertstudent('Dean La Rosa', '(570) 8409406', '22-Feb-1994', 'M', 'FALSE',
                                           '6 7th Street', 'dlapp@huffingtonpost.com');

insertdormmanagementdata.insertstudent('Antonin Fley', '(330) 2040290', '01-Mar-1993', 'M', 'FALSE',
                                           '84 Pine View Center', 'afleypq@geocities.jp');

insertdormmanagementdata.insertstudent('Merola Vashchenko', '(160) 9569373', '22-Oct-2002', 'F', 'FALSE',
                                           '65012 Valley Edge Avenue', 'mvashchenkopr@yellowbook.com');

insertdormmanagementdata.insertstudent('Margaux Whittuck', '(330) 3909980', '11-Nov-1996', 'F', 'FALSE',
                                           '93931 Hansons Crossing', 'mwhittuckps@godaddy.com');

insertdormmanagementdata.insertstudent('Joe Lydster', '(323) 2404766', '24-May-1992', 'M', 'FALSE',
                                           '99 Clove Lane', 'jlydsterpt@java.com');

insertdormmanagementdata.insertstudent('Fayette Dominelli', '(638) 7776636', '18-Dec-1990', 'F', 'FALSE',
                                           '70 Maywood Street', 'fdominellipu@omniture.com');

insertdormmanagementdata.insertstudent('Sabine Cotter', '(867) 5095052', '20-Mar-1991', 'F', 'FALSE',
                                           '97 Mifflin Point', 'scotterpv@shinystat.com');

insertdormmanagementdata.insertstudent('Catlaina Laxson', '(878) 1940815', '12-Nov-1999', 'F', 'FALSE',
                                           '93 Amoth Center', 'claxsonpw@wiley.com');

insertdormmanagementdata.insertstudent('Rafi Trouncer', '(438) 2167102', '09-Jun-1997', 'M', 'FALSE',
                                           '7133 Clarendon Pass', 'rtrouncerpx@usa.gov');

insertdormmanagementdata.insertstudent('Zachery Pizzie', '(238) 3115292', '29-Nov-2000', 'M', 'FALSE',
                                           '82628 Mallard Way', 'zpizziepy@ed.gov');

insertdormmanagementdata.insertstudent('Weber Arlett', '(856) 7309613', '25-Apr-1996', 'M', 'FALSE',
                                           '3 Kedzie Road', 'warlettpz@free.fr');

insertdormmanagementdata.insertstudent('Willyt Laible', '(432) 6061916', '03-Jan-1992', 'F', 'FALSE',
                                           '48118 Delladonna Point', 'wlaibleq0@cbslocal.com');

insertdormmanagementdata.insertstudent('Yetta Cahen', '(614) 8955259', '02-Jan-1992', 'F', 'FALSE',
                                           '8 Rigney Pass', 'ycahenq1@hexun.com');

insertdormmanagementdata.insertstudent('Shay Gilstoun', '(478) 8240103', '08-Sep-1992', 'M', 'FALSE',
                                           '49163 Delladonna Center', 'sgilstounq2@hao123.com');

insertdormmanagementdata.insertstudent('Rania Baker', '(467) 7214604', '24-Jun-1992', 'F', 'FALSE',
                                           '0 Carioca Place', 'rbakerq3@webeden.co.uk');

insertdormmanagementdata.insertstudent('Hersch Kalinowsky', '(238) 7467534', '08-Jul-1995', 'M', 'FALSE',
                                           '33697 Paget Court', 'hkalinowskyq4@cafepress.com');

insertdormmanagementdata.insertstudent('Fairfax Dounbare', '(375) 2564674', '01-May-1997', 'M', 'FALSE',
                                           '9669 Pepper Wood Drive', 'fdounbareq5@mit.edu');

insertdormmanagementdata.insertstudent('Arlie Wolseley', '(167) 8201322', '18-Sep-1999', 'F', 'FALSE',
                                           '62887 Elgar Avenue', 'awolseleyq6@businesswire.com');

insertdormmanagementdata.insertstudent('Charlena Slora', '(878) 9258528', '13-Mar-1999', 'F', 'FALSE',
                                           '12770 Park Meadow Park', 'csloraq7@google.ca');

insertdormmanagementdata.insertstudent('Lucio Hamnett', '(931) 6076335', '16-Jan-1990', 'M', 'FALSE',
                                           '999 Ryan Lane', 'lhamnettq8@ow.ly');

insertdormmanagementdata.insertstudent('Dulcinea Antushev', '(117) 3965375', '11-Aug-1993', 'F', 'FALSE',
                                           '34010 Tomscot Trail', 'dantushevq9@twitpic.com');

insertdormmanagementdata.insertstudent('Robbie Ralfe', '(650) 2214679', '11-Jun-1993', 'F', 'FALSE',
                                           '3480 Loeprich Center', 'rralfeqa@google.ca');

insertdormmanagementdata.insertstudent('Kahaleel Barkas', '(889) 7807437', '03-Mar-1990', 'M', 'FALSE',
                                           '572 Badeau Street', 'kbarkasqb@naver.com');

insertdormmanagementdata.insertstudent('Orton Chevin', '(236) 3170897', '21-Jan-1996', 'M', 'FALSE',
                                           '55691 Victoria Circle', 'ochevinqc@addtoany.com');

insertdormmanagementdata.insertstudent('Adi Zupo', '(379) 2791746', '06-Nov-1993', 'F', 'FALSE',
                                           '94 Vidon Lane', 'azupoqd@amazon.de');

insertdormmanagementdata.insertstudent('Bartholemy Bownde', '(647) 4421876', '21-Sep-2001', 'M', 'FALSE',
                                           '7 Springs Junction', 'bbowndeqe@thetimes.co.uk');

insertdormmanagementdata.insertstudent('Jacquelynn Mackilpatrick', '(313) 5988863', '11-Aug-1990', 'F', 'FALSE',
                                           '6258 Blackbird Court', 'jmackilpatrickqf@nydailynews.com');

insertdormmanagementdata.insertstudent('Job Morpeth', '(850) 9976658', '15-Jun-1994', 'M', 'FALSE',
                                           '920 Holmberg Way', 'jmorpethqg@themeforest.net');

insertdormmanagementdata.insertstudent('Florinda Farn', '(192) 7291693', '18-May-1993', 'F', 'FALSE',
                                           '9 Vera Center', 'ffarnqh@ft.com');

insertdormmanagementdata.insertstudent('Kettie Duggan', '(856) 4820332', '29-Dec-1990', 'F', 'FALSE',
                                           '69 Shelley Way', 'kdugganqi@google.ru');

insertdormmanagementdata.insertstudent('Georgette Semrad', '(521) 2627879', '21-Apr-1998', 'F', 'FALSE',
                                           '111 Hintze Court', 'gsemradqj@exblog.jp');

insertdormmanagementdata.insertstudent('Reidar Lamming', '(363) 5266932', '26-Sep-1992', 'M', 'FALSE',
                                           '3 Straubel Street', 'rlammingqk@buzzfeed.com');

insertdormmanagementdata.insertstudent('Burtie Spata', '(839) 6426724', '06-Jun-1991', 'M', 'FALSE',
                                           '99418 Clemons Court', 'bspataql@mtv.com');

insertdormmanagementdata.insertstudent('Lona Lantuffe', '(114) 5400520', '09-Jan-1997', 'F', 'FALSE',
                                           '8 Warner Crossing', 'llantuffeqm@nationalgeographic.com');

insertdormmanagementdata.insertstudent('Doyle Lethlay', '(332) 9399828', '29-Apr-1999', 'M', 'FALSE',
                                           '6 David Drive', 'dlethlayqn@booking.com');

insertdormmanagementdata.insertstudent('Ivor Wasiel', '(984) 4061362', '02-Dec-1992', 'M', 'FALSE',
                                           '49 Fordem Place', 'iwasielqo@msu.edu');

insertdormmanagementdata.insertstudent('Jacquenette Scoines', '(371) 4900174', '28-Sep-1992', 'F', 'FALSE',
                                           '8 Mesta Park', 'jscoinesqp@boston.com');

insertdormmanagementdata.insertstudent('Kelcey Fentem', '(417) 4985242', '02-Mar-1995', 'F', 'FALSE',
                                           '17333 Holmberg Lane', 'kfentemqq@addtoany.com');

insertdormmanagementdata.insertstudent('Ole Lampen', '(825) 1524367', '30-Jul-1998', 'M', 'FALSE',
                                           '089 Florence Way', 'olampenqr@addtoany.com');

insertdormmanagementdata.insertstudent('Lorena Mordin', '(642) 6443315', '29-Aug-1995', 'F', 'FALSE',
                                           '0 Delladonna Way', 'lmordinqs@npr.org');

insertdormmanagementdata.insertstudent('Hew Schwaiger', '(912) 4787530', '01-Feb-1998', 'M', 'FALSE',
                                           '99173 Harper Plaza', 'hschwaigerqt@vistaprint.com');

insertdormmanagementdata.insertstudent('Burke Kimmerling', '(275) 8917498', '22-Feb-1993', 'M', 'FALSE',
                                           '0 Moose Hill', 'bkimmerlingqu@amazon.de');

insertdormmanagementdata.insertstudent('Bald Dacey', '(736) 4243118', '18-Jun-1997', 'M', 'FALSE',
                                           '31744 Utah Point', 'bdaceyqv@stumbleupon.com');

insertdormmanagementdata.insertstudent('Alaster Bigglestone', '(356) 2589464', '15-Dec-1990', 'M', 'FALSE',
                                           '5 Grasskamp Center', 'abigglestoneqw@sitemeter.com');

insertdormmanagementdata.insertstudent('Em Leeves', '(534) 5255440', '02-Feb-1993', 'M', 'FALSE',
                                           '42 Schiller Plaza', 'eleevesqx@go.com');

insertdormmanagementdata.insertstudent('Humfrey Mockett', '(720) 2459156', '27-Feb-1997', 'M', 'FALSE',
                                           '97878 Meadow Ridge Road', 'hmockettqy@bandcamp.com');

insertdormmanagementdata.insertstudent('Abra Filyakov', '(433) 3196053', '27-Dec-1992', 'F', 'FALSE',
                                           '0194 Caliangt Alley', 'afilyakovqz@linkedin.com');

insertdormmanagementdata.insertstudent('Denys Lugsdin', '(263) 2040408', '31-Mar-2000', 'M', 'FALSE',
                                           '87287 Quincy Pass', 'dlugsdinr0@google.co.uk');

insertdormmanagementdata.insertstudent('Gloriane Albrook', '(480) 4709799', '06-Apr-2000', 'F', 'FALSE',
                                           '5022 Superior Circle', 'galbrookr1@eventbrite.com');

insertdormmanagementdata.insertstudent('Eugenius Priestner', '(962) 5198972', '04-Jul-1992', 'M', 'FALSE',
                                           '1 Texas Trail', 'epriestnerr2@w3.org');

insertdormmanagementdata.insertstudent('Tedie Sawyers', '(993) 6969352', '14-May-1999', 'M', 'FALSE',
                                           '1923 Golf View Road', 'tsawyersr3@wix.com');

insertdormmanagementdata.insertstudent('Obidiah Gary', '(471) 7154591', '30-Jan-1995', 'M', 'FALSE',
                                           '474 Cascade Place', 'ogaryr4@about.com');

insertdormmanagementdata.insertstudent('Denys Mullaly', '(147) 9710856', '27-Jun-1999', 'M', 'FALSE',
                                           '52534 Lyons Place', 'dmullalyr5@discuz.net');

insertdormmanagementdata.insertstudent('Happy Athey', '(485) 1729979', '18-Nov-2002', 'F', 'FALSE',
                                           '88256 Johnson Crossing', 'hatheyr6@economist.com');

insertdormmanagementdata.insertstudent('Tessy Treleven', '(349) 9599390', '12-Apr-1993', 'F', 'FALSE',
                                           '242 Dottie Park', 'ttrelevenr7@ebay.com');

insertdormmanagementdata.insertstudent('Heda Quincey', '(815) 1822231', '27-Oct-1996', 'F', 'FALSE',
                                           '0611 Dryden Avenue', 'hquinceyr8@163.com');

insertdormmanagementdata.insertstudent('Kala Turton', '(290) 1456071', '02-Jun-2002', 'F', 'FALSE',
                                           '28983 Arrowood Lane', 'kturtonr9@auda.org.au');

insertdormmanagementdata.insertstudent('Risa Dowrey', '(463) 8575906', '18-Apr-1997', 'F', 'FALSE',
                                           '6616 Mifflin Street', 'rdowreyra@freewebs.com');

insertdormmanagementdata.insertstudent('Con Perrigo', '(100) 1754512', '16-Apr-1992', 'M', 'FALSE',
                                           '306 Fremont Avenue', 'cperrigorb@ucoz.ru');

insertdormmanagementdata.insertstudent('Emilio Mazzilli', '(122) 2413274', '04-Jul-1999', 'M', 'FALSE',
                                           '92402 Crescent Oaks Street', 'emazzillirc@who.int');

insertdormmanagementdata.insertstudent('Joellen Klaggeman', '(864) 1965468', '19-Sep-1994', 'F', 'FALSE',
                                           '554 Union Pass', 'jklaggemanrd@vinaora.com');

insertdormmanagementdata.insertstudent('Nev Fernando', '(402) 8208838', '13-Apr-1995', 'M', 'FALSE',
                                           '811 Leroy Hill', 'nfernandore@alexa.com');

insertdormmanagementdata.insertstudent('Adelind Garett', '(434) 4402309', '26-Sep-2000', 'F', 'FALSE',
                                           '094 Dahle Drive', 'agarettrf@google.co.jp');

insertdormmanagementdata.insertstudent('Bobbee Laidel', '(511) 6050953', '03-Dec-1990', 'F', 'FALSE',
                                           '34263 Scoville Point', 'blaidelrg@list-manage.com');

insertdormmanagementdata.insertstudent('Danika Hurley', '(559) 4070013', '21-Mar-1997', 'F', 'FALSE',
                                           '0 Northview Terrace', 'dhurleyrh@noaa.gov');

insertdormmanagementdata.insertstudent('Aloysius Hymus', '(185) 9832118', '18-May-1990', 'M', 'FALSE',
                                           '18748 Vahlen Avenue', 'ahymusri@pbs.org');

insertdormmanagementdata.insertstudent('Allis Gitsham', '(531) 7415677', '14-May-2002', 'F', 'FALSE',
                                           '885 Talisman Plaza', 'agitshamrj@dell.com');

insertdormmanagementdata.insertstudent('Rancell Rice', '(319) 7586986', '15-Dec-2000', 'M', 'FALSE',
                                           '2998 Lotheville Point', 'rricerk@narod.ru');

insertdormmanagementdata.insertstudent('Dunstan Dael', '(314) 2478408', '21-Oct-2000', 'M', 'FALSE',
                                           '6970 Green Circle', 'ddaelrl@illinois.edu');

insertdormmanagementdata.insertstudent('Mariel Keach', '(717) 1831235', '17-May-1991', 'F', 'FALSE',
                                           '61212 Waywood Court', 'mkeachrm@china.com.cn');

insertdormmanagementdata.insertstudent('Yolanthe Gaspar', '(433) 3303775', '30-Dec-1993', 'F', 'FALSE',
                                           '26030 Clove Center', 'ygasparrn@liveinternet.ru');

insertdormmanagementdata.insertstudent('Gerda Duchateau', '(193) 4634234', '09-Oct-1990', 'F', 'FALSE',
                                           '537 Dennis Parkway', 'gduchateauro@examiner.com');

insertdormmanagementdata.insertstudent('Mikael Fairburne', '(557) 7179169', '16-Sep-1991', 'M', 'FALSE',
                                           '6129 Kim Place', 'mfairburnerp@google.com.br');

insertdormmanagementdata.insertstudent('Mellicent Tadgell', '(476) 5954480', '30-May-1994', 'F', 'FALSE',
                                           '40 Hooker Junction', 'mtadgellrq@phoca.cz');

insertdormmanagementdata.insertstudent('Noak Muslim', '(841) 7717372', '09-Mar-2001', 'M', 'FALSE',
                                           '310 Summer Ridge Way', 'nmuslimrr@comcast.net');
                                           
END;
/

EXEC insertdormmanagementdata.p_makestudentaresident(224, 'White Hall', '12-Mar-2021', '30-Aug-2025');

EXEC insertdormmanagementdata.p_makestudentaresident(225, 'Hastings Hall', '02-Jun-2021', '03-Aug-2027');

EXEC insertdormmanagementdata.p_makestudentaresident(226, 'Meserve Hall', '12-Mar-2021', '01-Jan-2023');

EXEC insertdormmanagementdata.p_makestudentaresident(227, 'Northeastern University Smith Hall', '14-Feb-2023', '14-Aug-2024');

EXEC insertdormmanagementdata.p_makestudentaresident(228, 'Hurtig Hall', '18-Dec-2021', '05-Sep-2029');

EXEC insertdormmanagementdata.p_makestudentaresident(229, 'Willis Hall', '12-Nov-2021', '03-Aug-2030');

EXEC insertdormmanagementdata.p_guest_entry('Prathamesh', '(857) 3186354', 1);

EXEC insertdormmanagementdata.p_guest_entry('Viraj', '(123) 2354566', 2);

EXEC insertdormmanagementdata.p_guest_entry('Urvang', '(233) 3545465', 3);

EXEC insertdormmanagementdata.p_guest_entry('Vidhi', '(442) 2345456', 4);

EXEC insertdormmanagementdata.p_guest_entry('Milind', '(562) 8765433', 5);

EXEC insertdormmanagementdata.p_swipe_me(1, 8);

EXEC insertdormmanagementdata.p_swipe_me(2, 1);

EXEC insertdormmanagementdata.p_swipe_me(3, 2);

EXEC insertdormmanagementdata.p_swipe_me(4, 3);

EXEC insertdormmanagementdata.p_swipe_me(5, 9);

EXEC insertdormmanagementdata.insertproctor('Tabbatha McCahey', '(202) 4623202', 'tmccahey0@gmpg.org', '143 Schiller Parkway', '14-Jan-1994');

EXEC insertdormmanagementdata.insertproctor('Ilysa Fullard', '(241) 6124835', 'ifullard1@shutterfly.com', '07 Haas Place', '28-May-2000');

EXEC insertdormmanagementdata.insertproctor('Dana Dimock', '(640) 7523291', 'ddimock2@tmall.com', '5632 Muir Court', '15-Sep-1988');

EXEC insertdormmanagementdata.insertproctor('Brandise Mertel', '(465) 5295897', 'bmertel3@businesswire.com', '2821 Pleasure Hill', '27-May-2000');

EXEC insertdormmanagementdata.insertproctor('Wallache Westwood', '(177) 3077742', 'wwestwood4@studiopress.com', '4 Maple Way', '24-Feb-1991');

EXEC insertdormmanagementdata.insertproctor('Emmett Sommerlin', '(154) 7179576', 'esommerlin5@ucla.edu', '4132 Westend Drive', '17-May-1998');

EXEC insertdormmanagementdata.insertproctor('Lisbeth Ceillier', '(996) 3592878', 'lceillier6@etsy.com', '5 Little Fleur Terrace', '24-Mar-1991');

EXEC insertdormmanagementdata.insertproctor('Jennine Mattingley', '(670) 2276239', 'jmattingley7@adobe.com', '89 Surrey Trail', '03-Jul-1987');

EXEC insertdormmanagementdata.insertproctor('Edsel Fordy', '(799) 4405545', 'efordy8@china.com.cn', '7350 Onsgard Terrace', '14-Jan-1988');

EXEC insertdormmanagementdata.insertproctor('Shel Mitten', '(683) 1493914', 'smitten9@miibeian.gov.cn', '10251 Corry Park', '15-Jul-2000');

EXEC insertdormmanagementdata.insertproctor('Tony Fessions', '(938) 3380897', 'tfessionsa@businessweek.com', '7253 Loomis Pass', '21-Dec-1999');

EXEC insertdormmanagementdata.insertproctor('Fabian Wildish', '(936) 9371949', 'fwildishb@opensource.org', '5 Sullivan Circle', '30-Dec-1994');

EXEC insertdormmanagementdata.insertproctor('Vaughn Walsh', '(690) 2044883', 'vwalshc@cmu.edu', '60811 Elka Center', '03-Mar-2003');

EXEC insertdormmanagementdata.insertproctor('Sheeree Canedo', '(379) 9352394', 'scanedod@feedburner.com', '03 Nevada Park', '09-Oct-1985');

EXEC insertdormmanagementdata.insertproctor('Jana Patnelli', '(730) 4823611', 'jpatnellie@unc.edu', '13 Memorial Trail', '18-Dec-1995');

EXEC insertdormmanagementdata.insertproctor('Skipton Allardyce', '(544) 5703289', 'sallardycef@springer.com', '14019 Kings Hill', '22-May-1991');

EXEC insertdormmanagementdata.insertproctor('Anatol Butterick', '(442) 4801542', 'abutterickg@omniture.com', '6491 Atwood Junction', '29-Apr-2000');

EXEC insertdormmanagementdata.insertproctor('Xaviera Simpole', '(990) 6810987', 'xsimpoleh@github.io', '2 Ridgeview Trail', '13-Sep-1986');

EXEC insertdormmanagementdata.insertproctor('Clo Nolot', '(842) 7552035', 'cnoloti@newsvine.com', '252 Gina Terrace', '31-Jul-1985');

EXEC insertdormmanagementdata.insertproctor('Corri McCollum', '(249) 4700549', 'cmccollumj@apache.org', '813 Killdeer Drive', '16-Oct-1992');

EXEC insertdormmanagementdata.insertproctor('Kiri Druhan', '(863) 5340603', 'kdruhank@nydailynews.com', '4 Holmberg Circle', '13-Oct-1993');

EXEC insertdormmanagementdata.insertproctor('Kristine Ingleson', '(779) 8158059', 'kinglesonl@examiner.com', '8 Knutson Street', '06-Mar-1995');

EXEC insertdormmanagementdata.insertproctor('Waldo Cooke', '(376) 5930313', 'wcookem@independent.co.uk', '3885 Mandrake Place', '25-Mar-1998');

EXEC insertdormmanagementdata.insertproctor('Dorita Benazet', '(473) 8018692', 'dbenazetn@aboutads.info', '10457 Springview Plaza', '26-Jul-1996');

EXEC insertdormmanagementdata.insertproctor('Rolland Kobisch', '(795) 3825932', 'rkobischo@state.gov', '530 Summer Ridge Center', '10-Jan-1990');

EXEC insertdormmanagementdata.insertproctor('Imogene Glassborow', '(568) 7069297', 'iglassborowp@nih.gov', '0 High Crossing Way', '21-Feb-1998');

EXEC insertdormmanagementdata.insertproctor('Corliss Durtnel', '(675) 1538337', 'cdurtnelq@cbc.ca', '85 Express Pass', '07-Jun-2002');

EXEC insertdormmanagementdata.insertproctor('Luca Benjamin', '(108) 4477724', 'lbenjaminr@globo.com', '67293 Fuller Avenue', '27-Dec-2002');

EXEC insertdormmanagementdata.insertproctor('Astrid Wedgbrow', '(146) 9584886', 'awedgbrows@skyrock.com', '736 Maple Parkway', '20-Jun-1985');

EXEC insertdormmanagementdata.insertproctor('Coletta Rillatt', '(544) 2787464', 'crillattt@usa.gov', '284 Loomis Terrace', '11-May-1999');

EXEC insertdormmanagementdata.insertproctor('Hedvige Aldin', '(712) 3502252', 'haldinu@cyberchimps.com', '4 Johnson Terrace', '26-Oct-1994');

EXEC insertdormmanagementdata.insertproctor('Bertie Drain', '(191) 5705964', 'bdrainv@google.co.uk', '0 Glendale Hill', '10-Jul-1991');

EXEC insertdormmanagementdata.insertproctor('Shermie Seston', '(880) 4155777', 'ssestonw@xing.com', '8 Browning Alley', '10-Mar-1987');

EXEC insertdormmanagementdata.insertproctor('Barri Micka', '(242) 8322992', 'bmickax@bing.com', '0 Quincy Way', '02-Dec-1998');

EXEC insertdormmanagementdata.insertproctor('Skippy Campkin', '(978) 5818543', 'scampkiny@reddit.com', '1 Elka Point', '26-May-1994');

EXEC insertdormmanagementdata.insertproctor('Morena Demeza', '(296) 9049583', 'mdemezaz@walmart.com', '3832 Anniversary Park', '22-Mar-1995');

EXEC insertdormmanagementdata.insertproctor('Renault Gajownik', '(637) 8370789', 'rgajownik10@simplemachines.org', '64595 Di Loreto Center', '22-Feb-1999');

EXEC insertdormmanagementdata.insertproctor('Kevina Premble', '(783) 3941639', 'kpremble11@behance.net', '5460 Melrose Parkway', '23-May-1999');

EXEC insertdormmanagementdata.insertproctor('Vonnie Chiles', '(378) 3635516', 'vchiles12@umich.edu', '2 Killdeer Point', '03-Sep-1999');

EXEC insertdormmanagementdata.insertproctor('Shelba Gwilliams', '(407) 7570814', 'sgwilliams13@ucoz.com', '9 Northland Lane', '22-Mar-2003');

EXEC insertdormmanagementdata.insertproctor('Lanny Willison', '(588) 1960283', 'lwillison14@google.pl', '8 Barnett Street', '04-Dec-1996');

EXEC insertdormmanagementdata.insertproctor('Georg Laurand', '(121) 7163453', 'glaurand15@fda.gov', '5173 Mockingbird Point', '18-Nov-1990');

EXEC insertdormmanagementdata.insertproctor('Sophi Duxbarry', '(956) 2773458', 'sduxbarry16@wix.com', '5713 Parkside Pass', '01-Jul-2003');

EXEC insertdormmanagementdata.insertproctor('Georgeanne Sabey', '(513) 4332022', 'gsabey17@weather.com', '3 Farmco Terrace', '08-Jul-1997');

EXEC insertdormmanagementdata.insertproctor('Tannie Bagniuk', '(646) 8086371', 'tbagniuk18@ezinearticles.com', '17 Amoth Drive', '15-May-1998');

EXEC insertdormmanagementdata.insertproctor('Sandi Hardington', '(565) 4226108', 'shardington19@reference.com', '750 Buhler Place', '15-Mar-2002');

EXEC insertdormmanagementdata.insertproctor('Elisabeth Paulmann', '(547) 2709116', 'epaulmann1a@youtu.be', '326 Saint Paul Trail', '13-Mar-1994');

EXEC insertdormmanagementdata.insertproctor('Kit Quinney', '(882) 6607718', 'kquinney1b@amazon.com', '3 Milwaukee Street', '22-Mar-1997');

EXEC insertdormmanagementdata.insertproctor('Iago Larrett', '(989) 5770555', 'ilarrett1c@cornell.edu', '4029 Shasta Avenue', '26-May-1988');

EXEC insertdormmanagementdata.insertproctor('Karna Jillis', '(251) 8293901', 'kjillis1d@ebay.com', '02594 Nobel Court', '03-Mar-1986');

EXEC insertdormmanagementdata.insertproctor('Rosa Dugan', '(725) 2111768', 'rdugan1e@e-recht24.de', '3 Hauk Lane', '25-Feb-1991');

EXEC insertdormmanagementdata.insertproctor('Avis Humbee', '(213) 4465920', 'ahumbee1f@wired.com', '93302 Oriole Park', '29-Nov-2002');

EXEC insertdormmanagementdata.insertproctor('Ward Cuttelar', '(332) 2216878', 'wcuttelar1g@amazon.co.uk', '9251 Commercial Pass', '01-Nov-1994');

EXEC insertdormmanagementdata.insertproctor('Dyana Noni', '(540) 4561198', 'dnoni1h@army.mil', '660 Stone Corner Junction', '06-Nov-1995');

EXEC insertdormmanagementdata.insertproctor('Deena Bannerman', '(531) 8497132', 'dbannerman1i@jimdo.com', '601 Caliangt Place', '13-May-1989');

EXEC insertdormmanagementdata.insertproctor('Maximo Strawbridge', '(863) 2464317', 'mstrawbridge1j@parallels.com', '6 Main Avenue', '22-Nov-1985');

EXEC insertdormmanagementdata.insertproctor('Demetris Bentham3', '(831) 2395872', 'dbentham1k@fema.gov', '90 Michigan Terrace', '31-May-2000');

EXEC insertdormmanagementdata.insertproctor('Drusy Margiotta', '(173) 8193038', 'dmargiotta1l@google.de', '3893 Kennedy Junction', '01-Nov-1988');

EXEC insertdormmanagementdata.insertproctor('Ashli Judron', '(924) 9177488', 'ajudron1m@newsvine.com', '2993 Holy Cross Center', '30-Jul-1986');

EXEC insertdormmanagementdata.insertproctor('Brina Muskett', '(857) 5571535', 'bmuskett1n@bbb.org', '57 Roxbury Plaza', '11-Sep-1995');

EXEC insertdormmanagementdata.insertproctor('Daria Scopyn', '(563) 1286838', 'dscopyn1o@webeden.co.uk', '98902 Eastlawn Way', '25-Jan-1999');

EXEC insertdormmanagementdata.insertproctor('Neal Vurley', '(497) 4255070', 'nvurley1p@wunderground.com', '39162 Di Loreto Street', '04-Sep-1989');

EXEC insertdormmanagementdata.insertproctor('Maire Rikel', '(284) 1270943', 'mrikel1q@issuu.com', '34166 Moulton Lane', '01-May-1987');

EXEC insertdormmanagementdata.insertproctor('Abbot Dougal', '(571) 8720969', 'adougal1r@nbcnews.com', '904 Lawn Park', '26-Dec-1989');

EXEC insertdormmanagementdata.insertproctor('Elnar Capaldi', '(854) 8504540', 'ecapaldi1s@yellowbook.com', '138 Charing Cross Road', '28-Feb-1987');

EXEC insertdormmanagementdata.insertproctor('Amalie Filippucci', '(883) 7732508', 'afilippucci1t@mediafire.com', '505 Gulseth Trail', '22-May-1999');

EXEC insertdormmanagementdata.insertproctor('Saundra Hallor', '(735) 3339701', 'shallor1u@intel.com', '9675 Eagle Crest Street', '26-May-2000');

EXEC insertdormmanagementdata.insertproctor('Ty Swindon', '(991) 1419226', 'tswindon1v@narod.ru', '71269 Lillian Crossing', '12-Jul-1993');

EXEC insertdormmanagementdata.insertproctor('Zea O Loughnan', '(998) 7282052', 'zoloughnan1w@sohu.com', '2 Russell Drive', '06-May-1990');

EXEC insertdormmanagementdata.insertproctor('Lucius Kennifick', '(414) 1027211', 'lkennifick1x@barnesandnoble.com', '4218 Northfield Junction', '31-May-1991');

EXEC insertdormmanagementdata.insertproctor('Gerianna Curnick', '(447) 7544119', 'gcurnick1y@163.com', '90492 Kings Hill', '28-Mar-2003');

EXEC insertdormmanagementdata.insertproctor('Renelle Knock', '(547) 2906362', 'rknock1z@nyu.edu', '43 John Wall Drive', '27-Apr-1995');

EXEC insertdormmanagementdata.insertproctor('Susan Spellacey', '(245) 2727544', 'sspellacey20@flickr.com', '12 Duke Junction', '03-Mar-1986');

EXEC insertdormmanagementdata.insertproctor('Cross Basezzi', '(829) 9353194', 'cbasezzi21@jigsy.com', '3430 Kim Pass', '20-Dec-1993');

EXEC insertdormmanagementdata.insertproctor('Pauly Crosthwaite', '(746) 3807309', 'pcrosthwaite22@nba.com', '4241 Stang Place', '13-Mar-1990');

EXEC insertdormmanagementdata.insertproctor('Godfrey Dwelly', '(766) 3198648', 'gdwelly23@answers.com', '8 Delladonna Trail', '31-Dec-1992');

EXEC insertdormmanagementdata.insertproctor('Deloria Asey', '(993) 8540506', 'dasey24@google.com.hk', '62 Monica Park', '07-May-1988');

EXEC insertdormmanagementdata.insertproctor('Clarabelle Goodbarr', '(817) 6351200', 'cgoodbarr25@mayoclinic.com', '159 Banding Place', '03-Dec-1997');

EXEC insertdormmanagementdata.insertproctor('Betsy Cottie', '(349) 1883779', 'bcottie26@edublogs.org', '33 Tennyson Terrace', '04-Oct-1998');

EXEC insertdormmanagementdata.insertproctor('Nathalie Rajchert', '(719) 5961558', 'nrajchert27@linkedin.com', '3893 Toban Road', '30-Jan-1997');

EXEC insertdormmanagementdata.insertproctor('Jarvis Vickerman', '(374) 9435515', 'jvickerman28@twitpic.com', '93873 Bunting Drive', '12-Jan-1987');

EXEC insertdormmanagementdata.insertproctor('Miran Mitkov', '(228) 8169093', 'mmitkov29@homestead.com', '5770 Waxwing Drive', '02-Jun-1997');

EXEC insertdormmanagementdata.insertproctor('Gardener Criag', '(923) 4115027', 'gcriag2a@answers.com', '13126 Cardinal Lane', '31-Mar-1996');

EXEC insertdormmanagementdata.insertproctor('Ervin Szymanski', '(931) 3654362', 'eszymanski2b@clickbank.net', '09 Fairfield Trail', '12-May-1988');

EXEC insertdormmanagementdata.insertproctor('Kaile Sprague', '(136) 8501005', 'ksprague2c@yahoo.co.jp', '062 Clyde Gallagher Alley', '02-Jan-2003');

EXEC insertdormmanagementdata.insertproctor('Berti Babb', '(225) 8055488', 'bbabb2d@tripadvisor.com', '0 Maple Wood Parkway', '05-May-1994');

EXEC insertdormmanagementdata.insertproctor('Luther Armal', '(204) 2175547', 'larmal2e@sbwire.com', '7919 Mallory Center', '16-Oct-1993');

EXEC insertdormmanagementdata.insertproctor('Pablo Etchell', '(258) 7418682', 'petchell2f@examiner.com', '57944 Springs Crossing', '01-Feb-1997');

EXEC insertdormmanagementdata.insertproctor('Ingeberg Lorkins', '(737) 1418639', 'ilorkins2g@sohu.com', '4 Marcy Crossing', '08-Feb-1998');

EXEC insertdormmanagementdata.insertproctor('Saudra Bohea', '(175) 7838999', 'sbohea2h@webs.com', '5092 Havey Circle', '05-Aug-1991');

EXEC insertdormmanagementdata.insertproctor('Olivia Duffield', '(487) 7528440', 'oduffield2i@europa.eu', '3410 Granby Trail', '08-Jan-1989');

EXEC insertdormmanagementdata.insertproctor('Karlen Warsap', '(324) 6531175', 'kwarsap2j@techcrunch.com', '56 Grover Way', '20-Nov-1989');

EXEC insertdormmanagementdata.insertproctor('Daryl De Mitri', '(224) 9141292', 'dde2k@wunderground.com', '70621 Sutteridge Center', '04-Sep-1994');

EXEC insertdormmanagementdata.insertproctor('Frannie Davidai', '(961) 7290191', 'fdavidai2l@google.es', '5 Rockefeller Trail', '27-Nov-1996');

EXEC insertdormmanagementdata.insertproctor('Violetta Girodin', '(865) 4153507', 'vgirodin2m@google.ru', '3 Esch Hill', '24-Jan-1998');

EXEC insertdormmanagementdata.insertproctor('Edgar Coutts', '(252) 2997668', 'ecoutts2n@homestead.com', '08462 Red Cloud Park', '19-Dec-1993');

EXEC insertdormmanagementdata.insertproctor('Ealasaid Sellstrom', '(935) 5461920', 'esellstrom2o@lulu.com', '8374 Shelley Hill', '11-Feb-2001');

EXEC insertdormmanagementdata.insertproctor('Douglas Depport', '(311) 1596507', 'ddepport2p@walmart.com', '52887 Continental Crossing', '24-Sep-1987');

EXEC insertdormmanagementdata.insertsupervisor('Ryley Scrivin', '7842 Longview Way', '(972) 9294324', 'rscrivin0@geocities.com');

EXEC insertdormmanagementdata.insertsupervisor('Roddie Lurriman', '6 Granby Parkway', '(682) 8855719', 'rlurriman1@stanford.edu');

EXEC insertdormmanagementdata.insertsupervisor('Tiffy O Deoran', '653 Surrey Way', '(853) 2811364', 'todeoran2@netlog.com');

EXEC insertdormmanagementdata.insertsupervisor('Garwin Grimston', '5 Glacier Hill Place', '(554) 6005270', 'ggrimston3@gov.uk');

EXEC insertdormmanagementdata.insertsupervisor('Devondra Sweeten', '42 Dixon Point', '(991) 1032260', 'dsweeten4@last.fm');

EXEC insertdormmanagementdata.insertsupervisor('Curr Augustine', '0 Scoville Parkway', '(649) 2290491', 'caugustine5@hibu.com');

EXEC insertdormmanagementdata.insertsupervisor('Julie O Rowane', '7 Division Parkway', '(825) 4420104', 'jorowane6@hp.com');

EXEC insertdormmanagementdata.insertsupervisor('Mordecai Pieters', '43740 Helena Plaza', '(871) 7771832', 'mpieters7@globo.com');

EXEC insertdormmanagementdata.insertsupervisor('Keefe Sidry', '133 Gerald Avenue', '(876) 7687957', 'ksidry8@hhs.gov');

EXEC insertdormmanagementdata.insertsupervisor('Ilyse Springall', '8748 Red Cloud Park', '(229) 5036477', 'ispringall9@google.cn');

EXEC insertdormmanagementdata.insertsupervisor('Novelia Harly', '0757 Butternut Place', '(302) 3326366', 'nharlya@timesonline.co.uk');

EXEC insertdormmanagementdata.insertsupervisor('Tully Betz', '2216 Milwaukee Circle', '(441) 7700490', 'tbetzb@census.gov');

EXEC insertdormmanagementdata.insertsupervisor('Paddie Hamberstone', '100 Weeping Birch Lane', '(357) 6904517', 'phamberstonec@icq.com');

EXEC insertdormmanagementdata.insertsupervisor('Pooh Melross', '8 Shoshone Junction', '(804) 4637144', 'pmelrossd@i2i.jp');

EXEC insertdormmanagementdata.insertsupervisor('Jerry McCobb', '703 Orin Drive', '(131) 1016502', 'jmccobbe@shinystat.com');

EXEC insertdormmanagementdata.insertsupervisor('Eben Sandom', '0 Meadow Valley Avenue', '(315) 2518963', 'esandomf@dedecms.com');

EXEC insertdormmanagementdata.insertsupervisor('Ashly Kochlin', '126 Ludington Crossing', '(927) 2309984', 'akochling@vistaprint.com');

EXEC insertdormmanagementdata.insertsupervisor('Drusie Adney', '22 Briar Crest Circle', '(261) 4626886', 'dadneyh@creativecommons.org');

EXEC insertdormmanagementdata.insertsupervisor('Hans Coopey', '29 Calypso Place', '(166) 5127107', 'hcoopeyi@flickr.com');

EXEC insertdormmanagementdata.insertsupervisor('Viv Kemster', '9645 Kingsford Crossing', '(413) 8925628', 'vkemsterj@1und1.de');

EXEC insertdormmanagementdata.insertshiftmaster('A', to_timestamp('00:00:00', 'hh24:mi:ss'), to_timestamp('08:00:00', 'hh24:mi:ss'));

EXEC insertdormmanagementdata.insertshiftmaster('B', to_timestamp('08:00:00', 'hh24:mi:ss'), to_timestamp('16:00:00', 'hh24:mi:ss'));

EXEC insertdormmanagementdata.insertshiftmaster('C', to_timestamp('16:00:00', 'hh24:mi:ss'), to_timestamp('00:00:00', 'hh24:mi:ss'));

EXEC insertdormmanagementdata.p_utility_entry(1, 3);

EXEC insertdormmanagementdata.p_utility_entry(6, 6);

EXEC insertdormmanagementdata.p_utility_entry(8, 5);

EXEC insertdormmanagementdata.p_utility_entry(2, 4);

EXEC insertdormmanagementdata.p_utility_entry(1, 3);

EXEC insertdormmanagementdata.p_utility_entry(12, 2);

EXEC insertdormmanagementdata.p_utility_entry(14, 1);

EXEC insertdormmanagementdata.p_utility_entry(3, 3);

EXEC insertdormmanagementdata.p_utility_entry(4, 4);

EXEC insertdormmanagementdata.p_utility_entry(2, 5);

EXEC insertdormmanagementdata.p_utility_entry(11, 6);

EXEC insertdormmanagementdata.p_utility_entry(17, 2);

EXEC insertdormmanagementdata.p_utility_entry(19, 4);

EXEC insertdormmanagementdata.p_utility_entry(4, 3);

EXEC insertdormmanagementdata.p_utility_entry(5, 2);

EXEC insertdormmanagementdata.p_utility_entry(7, 1);

EXEC insertdormmanagementdata.p_utility_entry(9, 4);

EXEC insertdormmanagementdata.p_utility_entry(10, 4);

EXEC insertdormmanagementdata.p_utility_entry(15, 5);

EXEC insertdormmanagementdata.p_utility_entry(20, 6);

EXEC insertdormmanagementdata.shiftscheduler(sysdate + 5);

EXEC insertdormmanagementdata.shiftscheduler(sysdate + 6, 3);

EXEC insertdormmanagementdata.insertpolice('Netty Chaman', 'F', '(575) 5845382');

EXEC insertdormmanagementdata.insertpolice('Launce Jacobssen', 'M', '(205) 3514451');

EXEC insertdormmanagementdata.insertpolice('Quinn Barnsdale', 'M', '(836) 4735821');

EXEC insertdormmanagementdata.insertpolice('Bunny de Broke', 'F', '(206) 1664037');

EXEC insertdormmanagementdata.insertpolice('Rodrigo Jenno', 'M', '(354) 2129722');

EXEC insertdormmanagementdata.insertpolice('Manfred Heigho', 'M', '(189) 1843071');

EXEC insertdormmanagementdata.insertpolice('Gilberta Lindl', 'F', '(176) 6915209');

EXEC insertdormmanagementdata.insertpolice('Stanleigh McManus', 'M', '(562) 3307811');

EXEC insertdormmanagementdata.insertpolice('Rabi Tuxwell', 'M', '(497) 2651712');

EXEC insertdormmanagementdata.insertpolice('Fanni Gwyther', 'F', '(595) 9536722');

EXEC insertdormmanagementdata.insertpolice('Sydney Hryskiewicz', 'M', '(348) 5383026');

EXEC insertdormmanagementdata.insertpolice('Bud Stoacley', 'M', '(971) 9175866');

EXEC insertdormmanagementdata.insertpolice('Neal Riepl', 'M', '(829) 3123670');

EXEC insertdormmanagementdata.insertpolice('Dorthea Thebeaud', 'F', '(490) 5207986');

EXEC insertdormmanagementdata.insertpolice('Morgan Anslow', 'M', '(159) 1492591');

EXEC insertdormmanagementdata.insertpolice('Ina Mewton', 'F', '(724) 4234622');

EXEC insertdormmanagementdata.insertpolice('Helen-elizabeth Scuse', 'F', '(248) 3778059');

EXEC insertdormmanagementdata.insertpolice('Kayla Tomalin', 'F', '(145) 9205869');

EXEC insertdormmanagementdata.insertpolice('Seymour Feldstein', 'M', '(887) 2837754');

EXEC insertdormmanagementdata.insertpolice('Zorina Lawrey', 'F', '(797) 3622336');

EXEC insertdormmanagementdata.insertpolice('Amandy Berecloth', 'F', '(229) 4498464');

EXEC insertdormmanagementdata.insertpolice('Claybourne Korba', 'M', '(950) 8790392');

EXEC insertdormmanagementdata.insertpolice('Romain Tinkler', 'M', '(613) 5917243');

EXEC insertdormmanagementdata.insertpolice('Dierdre Mobbs', 'F', '(795) 9034100');

EXEC insertdormmanagementdata.insertpolice('Veronika Biesterfeld', 'F', '(516) 8082160');

EXEC insertdormmanagementdata.insertpolice('Celka Sausman', 'F', '(380) 2138072');

EXEC insertdormmanagementdata.insertpolice('Salomi Sanbrooke', 'F', '(491) 5965973');

EXEC insertdormmanagementdata.insertpolice('Findley Jeavons', 'M', '(133) 5158050');

EXEC insertdormmanagementdata.insertpolice('Rose Hollows', 'F', '(796) 4030955');

EXEC insertdormmanagementdata.insertpolice('Jeana De Fraine', 'F', '(411) 1874525');

EXEC insertdormmanagementdata.insertpolice('Gothart Neumann', 'M', '(227) 1332650');

EXEC insertdormmanagementdata.insertpolice('Elyse Yewdall', 'F', '(735) 6959266');

EXEC insertdormmanagementdata.insertpolice('Lionello Henniger', 'M', '(601) 5239510');

EXEC insertdormmanagementdata.insertpolice('Marin Heathwood', 'F', '(877) 6726823');

EXEC insertdormmanagementdata.insertpolice('Izzy Grinaugh', 'M', '(898) 7197153');

EXEC insertdormmanagementdata.insertpolice('Kermie Labusch', 'M', '(310) 8692523');

EXEC insertdormmanagementdata.insertpolice('Corey Mosconi', 'M', '(390) 2417034');

EXEC insertdormmanagementdata.insertpolice('Loria Gallaccio', 'F', '(707) 7774352');

EXEC insertdormmanagementdata.insertpolice('Matelda Cadle', 'F', '(681) 1742311');

EXEC insertdormmanagementdata.insertpolice('Reece Kuhnt', 'M', '(976) 9824411');

EXEC insertdormmanagementdata.insertpolice('Mart Ogbourne', 'M', '(174) 9842303');

EXEC insertdormmanagementdata.insertpolice('Karleen Pollard', 'F', '(579) 6511336');

EXEC insertdormmanagementdata.insertpolice('Abbie Case', 'F', '(584) 8256647');

EXEC insertdormmanagementdata.insertpolice('Cele Fieldgate', 'F', '(811) 6695259');

EXEC insertdormmanagementdata.insertpolice('Gearard Mazzey', 'M', '(132) 6618331');

EXEC insertdormmanagementdata.insertpolice('Heida Arsey', 'F', '(988) 5399831');

EXEC insertdormmanagementdata.insertpolice('Xenia Eddy', 'F', '(793) 5131320');

EXEC insertdormmanagementdata.insertpolice('Lulita Benitez', 'F', '(816) 4692770');

EXEC insertdormmanagementdata.insertpolice('Ernesta Bowie', 'F', '(400) 4763959');

EXEC insertdormmanagementdata.insertpolice('Zaccaria Ondrasek', 'M', '(454) 4978252');

EXEC insertdormmanagementdata.generatecase(1, 'Shooting', 'Two shots fired inside the dorm');

EXEC insertdormmanagementdata.generatecase(5, 'Cybercrime', 'Account hacked');

EXEC insertdormmanagementdata.generatecase(12, 'Vandalism', 'Someone is breaking the dorm windows');

EXEC insertdormmanagementdata.generatecase(9, 'Theft', 'Armed robbery at Dorm');

EXEC insertdormmanagementdata.generatecase(19, 'Suicide', 'John shot himself');

EXEC insertdormmanagementdata.generatecase(8, 'Homicide', 'Francisco was found dead in his room. He was stabbed!');

EXEC insertdormmanagementdata.generatecase(5, 'Theft', 'Personal items of residents stolen');


-- Police id, Case id, Case status
EXEC insertdormmanagementdata.mapcasetopolice(3, 4, 'Open');

EXEC insertdormmanagementdata.mapcasetopolice(8, 7, 'Open');

EXEC insertdormmanagementdata.mapcasetopolice(24, 1, 'Open');

EXEC insertdormmanagementdata.mapcasetopolice(38, 2, 'Open');

EXEC insertdormmanagementdata.mapcasetopolice(13, 6, 'Open');


SELECT
    *
FROM
    dorm;

SELECT
    *
FROM
    guest;

SELECT
    *
FROM
    police;

SELECT
    *
FROM
    incident;

SELECT
    *
FROM
    police_incident_mapping;

SELECT
    *
FROM
    proctor;

SELECT
    *
FROM
    resident;

SELECT
    *
FROM
    shifts;

SELECT
    *
FROM
    shifts_type_master;

SELECT
    *
FROM
    student;

SELECT
    *
FROM
    supervisor;

SELECT
    *
FROM
    swipe_log;

SELECT
    *
FROM
    utility;

SELECT
    *
FROM
    utility_type_master;
    
