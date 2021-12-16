--PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY insertdormmanagementdata AS

    FUNCTION f_get_first_available_dorm RETURN NUMBER IS
        available_dorm NUMBER;
    BEGIN
        SELECT
            dm.dorm_id
        INTO available_dorm
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
                )
            AND ROWNUM = 1;

        RETURN available_dorm;
    END f_get_first_available_dorm;

    PROCEDURE p_resident_addition (
        studentid  NUMBER,
        isresident VARCHAR
    ) IS
        available_dorm NUMBER;
        available_name VARCHAR(50);
    BEGIN
        IF ( isresident = 'TRUE' ) THEN
            available_dorm := f_get_first_available_dorm();
            dbms_output.put_line('dom' || available_dorm);
            SELECT
                dorm_name
            INTO available_name
            FROM
                dorm
            WHERE
                dorm_id = available_dorm;

            BEGIN
                insertdormmanagementdata.p_makestudentaresident(studentid, available_name, current_timestamp, add_months(current_timestamp,
                12));
            END;

            dbms_output.put_line('Made as resident');
        END IF;
    END;

    PROCEDURE insertutilitymaster (
        uname VARCHAR,
        udesc VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
        invalidinsert EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            utility_type_master utm
        WHERE
            uname = utm.utility_name;

        IF alreadyinserted = 0 THEN
            INSERT INTO utility_type_master (
                utility_name,
                utility_desc
            ) VALUES (
                uname,
                udesc
            );

        ELSE
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Utility type already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
        alreadyinserted NUMBER := 0;
        invalidinsert EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            dorm d
        WHERE
                dname = d.dorm_name
            AND dzip = d.dorm_zip;

        IF alreadyinserted = 0 THEN
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
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Dorm already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
        alreadyinserted NUMBER := 0;
        insertstudent   NUMBER;
        invalidinsert EXCEPTION;
        temp_student_id NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            student s
        WHERE
                sname = s.student_name
            AND sdob = s.student_dob
            AND semail = s.student_email;

        IF alreadyinserted = 0 THEN
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

            SELECT
                student_id
            INTO temp_student_id
            FROM
                student
            WHERE
                    student_name = sname
                AND student_contact = scontact
                AND student_dob = sdob
                AND permanent_address = permaddress
                AND student_email = semail;

            BEGIN
                insertdormmanagementdata.p_resident_addition(temp_student_id, resident);
            END;
        ELSE
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Student already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
        -- already_resident EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_already_exists
        FROM
            resident
        WHERE
            student_id = studuentid;

        IF is_already_exists = 0 THEN
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
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE p_swipe_me (
        residentid NUMBER,
        dormid     NUMBER
    ) AS
    BEGIN
        dbms_output.put_line(residentid || dormid);
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
        invalidinsert EXCEPTION;
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
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Shift type already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE insertproctor (
        pname    VARCHAR,
        pcontact VARCHAR,
        pemail   VARCHAR,
        paddress VARCHAR,
        pdob     VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
        invalidinsert EXCEPTION;
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
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Proctor already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE insertsupervisor (
        supname    VARCHAR,
        supaddress VARCHAR,
        supcontact VARCHAR,
        supemail   VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
        invalidinsert EXCEPTION;
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
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Supervisor already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;
    
    PROCEDURE remove_proctor (
        procid NUMBER
    ) AS
        procfound NUMBER := 0;
        no_proctor EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO procfound
        FROM
            proctor
        WHERE
            proctor_id = procid;
    
        IF procfound = 0 THEN
            RAISE no_proctor;
        ELSE
            DELETE FROM proctor
            WHERE
                proctor_id = procid;
    
            dbms_output.put_line('--Proctor deleted--');
        END IF;
    
    EXCEPTION
        WHEN no_proctor THEN
            dbms_output.put_line('--Proctor not found--');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;
    
    PROCEDURE remove_supervisor (
        supid NUMBER
    ) AS
        supfound NUMBER := 0;
        no_sup EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO supfound
        FROM
            supervisor
        WHERE
            supervisor_id = supid;
    
        IF supfound = 0 THEN
            RAISE no_sup;
        ELSE
            DELETE FROM supervisor
            WHERE
                supervisor_id = supid;
    
            dbms_output.put_line('--Supervisor deleted--');
        END IF;
    
    EXCEPTION
        WHEN no_sup THEN
            dbms_output.put_line('--Supervisor not found--');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
            current_timestamp,
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

    PROCEDURE shiftscheduler (
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
                        ELSE
                            dbms_output.put_line('New shift inserted for given date and dorm');
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
            dbms_output.put_line('---No proctor data found---');
        WHEN no_supervisors THEN
            dbms_output.put_line('---No supervisor data found---');
        WHEN no_dorm THEN
            dbms_output.put_line('---No dorm data found---');
        WHEN no_shift_master THEN
            dbms_output.put_line('---No shift master data found---');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE shiftscheduler (
        schdate DATE,
        tillday NUMBER
    ) IS

        datecount       NUMBER := 0;
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

    /*loop over days*/
        FOR schday IN 0..tillday LOOP
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
                            inputcomplete := shiftcreated(procid, supid, did.dorm_id, schdate + schday, stype.shift_type);

                            IF inputcomplete = 2 THEN
                                RAISE shift_already_done;
                            ELSIF inputcomplete = 0 THEN
                                RAISE proctor_limit;
                            ELSE
                                dbms_output.put_line('New shift inserted for given date and dorm');
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
        END LOOP;

    EXCEPTION
        WHEN no_proctors THEN
            dbms_output.put_line('---No proctor data found---');
        WHEN no_supervisors THEN
            dbms_output.put_line('---No supervisor data found---');
        WHEN no_dorm THEN
            dbms_output.put_line('---No dorm data found---');
        WHEN no_shift_master THEN
            dbms_output.put_line('---No shift master data found---');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE insertpolice (
        policename    VARCHAR,
        policegender  CHAR,
        policecontact VARCHAR
    ) IS
        alreadyinserted NUMBER := 0;
        invalidinsert EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO alreadyinserted
        FROM
            police pol
        WHERE
                policename = pol.police_name
            AND policecontact = pol.police_contact;

        IF alreadyinserted = 0 THEN
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
            RAISE invalidinsert;
        END IF;

    EXCEPTION
        WHEN invalidinsert THEN
            dbms_output.put_line('----Police already exists----');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
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
            dbms_output.put_line('Case already mapped to police!');
        WHEN e_police_valid THEN
            raise_application_error(-20320, 'Invalid police!');
        WHEN e_case_valid THEN
            raise_application_error(-20330, 'Invalid case!');
    END;

END;
/

CREATE OR REPLACE PACKAGE BODY manage_users_and_access AS

    PROCEDURE create_user (
        username VARCHAR,
        password VARCHAR
    ) IS

        sqls              VARCHAR2(255);
        user_exists EXCEPTION;
        PRAGMA exception_init ( user_exists, -2002 );
        is_user_available NUMBER;
    BEGIN
        sqls := 'CREATE USER '
                || username
                || ' IDENTIFIED BY "'
                || password
                || '" ';
        EXECUTE IMMEDIATE sqls;
        dbms_output.put_line('  OK: ' || sqls);
    EXCEPTION
        WHEN user_exists THEN
            dbms_output.put_line('WARN: ' || sqls);
            dbms_output.put_line('Already exists');
        WHEN OTHERS THEN
            dbms_output.put_line('FAIL: ' || sqls);
    END;

    PROCEDURE create_role (
        rolename VARCHAR
    ) IS
        sqls VARCHAR2(255);
        role_exists EXCEPTION;
        PRAGMA exception_init ( role_exists, -2002 );
    BEGIN
        sqls := 'CREATE ROLE ' || rolename;
        EXECUTE IMMEDIATE sqls;
        dbms_output.put_line('  OK: ' || sqls);
    EXCEPTION
        WHEN role_exists THEN
            dbms_output.put_line('WARN: ' || sqls);
            dbms_output.put_line('Already exists');
        WHEN OTHERS THEN
            dbms_output.put_line('FAIL: ' || sqls);
    END;

    PROCEDURE manage_role_access (
        tablename   VARCHAR,
        rolename    VARCHAR,
        accesstypes VARCHAR
    ) IS
        is_role_available NUMBER;
        e_role_already_created EXCEPTION;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_role_available
        FROM
            dba_roles
        WHERE
            lower(role) = lower(rolename);

        IF ( is_role_available = 1 ) THEN
            EXECUTE IMMEDIATE 'GRANT '
                              || accesstypes
                              || ' ON '
                              || tablename
                              || ' TO '
                              || rolename;

        ELSE
            RAISE e_role_already_created;
        END IF;

    EXCEPTION
        WHEN e_role_already_created THEN
            dbms_output.put_line('Role not created!!');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlerrm);
    END;

    PROCEDURE grant_role_to_user (
        rolename VARCHAR,
        username VARCHAR
    ) IS

        is_role_available NUMBER;
        sqls              VARCHAR2(255);
        role_exists EXCEPTION;
        PRAGMA exception_init ( role_exists, -2002 );
    BEGIN
        sqls := 'GRANT '
                || rolename
                || ' TO '
                || '"'
                || username
                || '"';

        EXECUTE IMMEDIATE sqls;
        dbms_output.put_line('  OK: ' || sqls);
    EXCEPTION
        WHEN role_exists THEN
            dbms_output.put_line('WARN: ' || sqls);
            dbms_output.put_line('Already exists');
        WHEN OTHERS THEN
            dbms_output.put_line('FAIL: ' || sqls);
            dbms_output.put_line(sqlerrm);
    END;

    FUNCTION f_is_user_already_created (
        username VARCHAR
    ) RETURN NUMBER IS
        is_available NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_available
        FROM
            dba_users
        WHERE
            username = upper(username);

        dbms_output.put_line('userName!!' || username);
        dbms_output.put_line('is_available!!' || is_available);
        IF is_available > 0 THEN
            is_available := 1; --already created
        END IF;
        RETURN is_available;
    END f_is_user_already_created;

END;
/
