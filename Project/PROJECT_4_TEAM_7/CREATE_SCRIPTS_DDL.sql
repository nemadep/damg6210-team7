----------------------- CREATE SQL SCRIPTS DDL ------------------------------

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION func_is_table_created (
    find_table_name IN VARCHAR
) RETURN NUMBER AS
    is_available NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO is_available
    FROM
        user_tables
    WHERE
        table_name = upper(find_table_name);

    RETURN is_available;
END func_is_table_created;
/

CREATE OR REPLACE FUNCTION func_is_seq_created (
    find_deq_name IN VARCHAR
) RETURN NUMBER AS
    is_available NUMBER;
BEGIN
    SELECT
        CASE
            WHEN EXISTS (
                SELECT
                    *
                FROM
                    all_sequences
                WHERE
                    lower(sequence_name) = find_deq_name
            ) THEN
                1
            ELSE
                0
        END
    INTO is_available
    FROM
        dual;

    RETURN is_available;
END func_is_seq_created;
/

CREATE OR REPLACE PROCEDURE p_intial_reset AS

    c_shifts_type_master      INT;
    c_student                 INT;
    c_supervisor              INT;
    c_utility_type_master     INT;
    c_utility                 INT;
    c_proctor                 INT;
    c_guest                   INT;
    c_resident                INT;
    c_dorm                    INT;
    c_swipe_log               INT;
    c_shifts                  INT;
    c_police                  INT;
    c_incident                INT;
    c_police_incident_mapping INT;
    c_guest_seq               INT;
    c_student_seq             INT;
BEGIN
    SELECT
        func_is_table_created('shifts_type_master')
    INTO c_shifts_type_master
    FROM
        dual;

    SELECT
        func_is_table_created('student')
    INTO c_student
    FROM
        dual;

    SELECT
        func_is_table_created('supervisor')
    INTO c_supervisor
    FROM
        dual;

    SELECT
        func_is_table_created('utility_type_master')
    INTO c_utility_type_master
    FROM
        dual;

    SELECT
        func_is_table_created('utility')
    INTO c_utility
    FROM
        dual;

    SELECT
        func_is_table_created('proctor')
    INTO c_proctor
    FROM
        dual;

    SELECT
        func_is_table_created('guest')
    INTO c_guest
    FROM
        dual;

    SELECT
        func_is_table_created('resident')
    INTO c_resident
    FROM
        dual;

    SELECT
        func_is_table_created('dorm')
    INTO c_dorm
    FROM
        dual;

    SELECT
        func_is_table_created('swipe_log')
    INTO c_swipe_log
    FROM
        dual;

    SELECT
        func_is_table_created('shifts')
    INTO c_shifts
    FROM
        dual;

    SELECT
        func_is_table_created('police')
    INTO c_police
    FROM
        dual;

    SELECT
        func_is_table_created('incident')
    INTO c_incident
    FROM
        dual;

    SELECT
        func_is_table_created('police_incident_mapping')
    INTO c_police_incident_mapping
    FROM
        dual;

    SELECT
        func_is_seq_created('guest_seq')
    INTO c_guest_seq
    FROM
        dual;

    SELECT
        func_is_seq_created('student_seq')
    INTO c_student_seq
    FROM
        dual;

    IF c_guest_seq = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------SEQUENCE - GUEST_SEQ-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE SEQUENCE guest_seq!';
        dbms_output.put_line('Created : SEQUENCE - GUEST_SEQ');
    END IF;

    IF c_student_seq = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------SEQUENCE - STUDENT_SEQ-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE SEQUENCE student_seq!';
        dbms_output.put_line('Created : SEQUENCE - STUDENT_SEQ');
    END IF;

    IF c_dorm = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - DORM-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE dorm (
            dorm_id            NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            dorm_name          VARCHAR(50) NOT NULL,
            dorm_capacity      NUMBER NOT NULL,
            dorm_city          VARCHAR(50) NOT NULL,
            dorm_state         VARCHAR(50) NOT NULL,
            dorm_zip           CHAR(5) NOT NULL,
            dorm_address_line1 VARCHAR(50) NOT NULL,
            dorm_address_line2 VARCHAR(50),
            CONSTRAINT dorm_unique PRIMARY KEY ( dorm_id )
        )!';
        dbms_output.put_line('Created : TABLE - DORM');
    END IF;

    IF c_shifts_type_master = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - SHIFTS_TYPE_MASTER-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE shifts_type_master (
            shift_type CHAR(4) NOT NULL,
            start_time TIMESTAMP NOT NULL,
            end_time   TIMESTAMP NOT NULL,
            CONSTRAINT shifts_type_master_pk PRIMARY KEY ( shift_type )
        )!';
        dbms_output.put_line('Created : TABLE - SHIFTS_TYPE_MASTER');
    END IF;

    IF c_student = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - STUDENT-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE student (
            student_id        NUMBER NOT NULL,
            student_name      VARCHAR(50) NOT NULL,
            student_contact   VARCHAR(15) NOT NULL CHECK ( REGEXP_LIKE (
                                            student_contact, '(???) ???????' ) ),
            student_dob       DATE NOT NULL,
            student_gender    CHAR(1) NOT NULL CHECK ( student_gender = 'M'
                                                    OR student_gender = 'F' ),
            is_resident       CHAR(5) DEFAULT 'FALSE' CHECK ( is_resident IN ( 'TRUE', 'FALSE' ) ),
            permanent_address VARCHAR2(320) NOT NULL,
            student_email     VARCHAR2(100) NOT NULL CHECK ( REGEXP_LIKE ( student_email,
                                                                       '^(\S+)\@(\S+)\.(\S+)$' ) ),
            CONSTRAINT student_pk PRIMARY KEY ( student_id )
        )!';
        dbms_output.put_line('Created : TABLE - STUDENT');
    END IF;

    IF c_supervisor = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - SUPERVISOR-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE supervisor (
            supervisor_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            supervisor_name    VARCHAR(50) NOT NULL,
            supervisor_address VARCHAR(320) NOT NULL,
            supervisor_contact VARCHAR(15) NOT NULL CHECK ( REGEXP_LIKE (
                                            supervisor_contact, '(???) ???????' ) ),
            supervisor_email   VARCHAR(50) NOT NULL CHECK ( REGEXP_LIKE ( supervisor_email,
                                                                        '^(\S+)\@(\S+)\.(\S+)$' ) ),
            CONSTRAINT supervisor_pk PRIMARY KEY ( supervisor_id )
        )!';
        dbms_output.put_line('Created : TABLE - SUPERVISOR');
    END IF;

    IF c_utility_type_master = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - UTILITY_TYPE_MASTER-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE utility_type_master (
            utility_id   NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            utility_name VARCHAR(50) NOT NULL,
            utility_desc VARCHAR(100) NOT NULL,
            CONSTRAINT utility_master_unique PRIMARY KEY ( utility_id )
        )!';
        dbms_output.put_line('Created : TABLE - UTILITY_TYPE_MASTER');
    END IF;

    IF c_proctor = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - PROCTOR-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE proctor (
            proctor_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            proctor_name    VARCHAR(50) NOT NULL,
            proctor_contact VARCHAR(15) NOT NULL CHECK ( REGEXP_LIKE (
                                            proctor_contact, '(???) ???????' ) ),
            proctor_email   VARCHAR(50) NOT NULL CHECK ( REGEXP_LIKE ( proctor_email,
                                                                     '^(\S+)\@(\S+)\.(\S+)$' ) ),
            proctor_address VARCHAR(320) NOT NULL,
            proctor_dob     DATE NOT NULL,
            CONSTRAINT proctor_pk PRIMARY KEY ( proctor_id )
        )!';
        dbms_output.put_line('Created : TABLE - PROCTOR');
    END IF;

    IF c_resident = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - RESIDENT-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE resident (
            resident_id NUMBER
                GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1
            NOT NULL,
            dorm_id     NUMBER NOT NULL,
            student_id  NUMBER NOT NULL,
            to_date     DATE NOT NULL,
            from_date   DATE NOT NULL,
            CONSTRAINT resident_pk PRIMARY KEY ( resident_id ),
            CONSTRAINT dorm_resident_fk FOREIGN KEY ( dorm_id )
                REFERENCES dorm ( dorm_id )
                    ON DELETE CASCADE,
            CONSTRAINT dorm_student_fk FOREIGN KEY ( student_id )
                REFERENCES student ( student_id)
                    ON DELETE CASCADE
        )!';
        dbms_output.put_line('Created : TABLE - RESIDENT');
    END IF;

    IF c_swipe_log = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - SWIPE_LOG-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE swipe_log (
            resident_id NUMBER,
            dorm_id     NUMBER,
            swipe_time  TIMESTAMP WITH LOCAL TIME ZONE NOT NULL,
            CONSTRAINT swipe_dorm_fk FOREIGN KEY ( dorm_id )
                REFERENCES dorm ( dorm_id )
                    ON DELETE CASCADE,
            CONSTRAINT swipe_resident_fk FOREIGN KEY ( resident_id )
                REFERENCES resident ( resident_id )
                    ON DELETE CASCADE,
            CONSTRAINT swipe_unique PRIMARY KEY ( resident_id,
                                                  dorm_id,
                                              swipe_time )
        )!';
        dbms_output.put_line('Created : TABLE - SWIPE_LOG');
    END IF;

    IF c_shifts = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - SHIFTS-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE shifts (
            shift_type    CHAR(4) NOT NULL,
            proctor_id    NUMBER NOT NULL,
            shift_date    DATE NOT NULL,
            create_at     DATE NOT NULL,
            update_at     DATE NOT NULL,
            supervisor_id NUMBER NOT NULL,
            dorm_id       NUMBER NOT NULL,
            CONSTRAINT shift_pk PRIMARY KEY ( shift_type,
                                              proctor_id,
                                              shift_date ),
            CONSTRAINT shift_type_fk FOREIGN KEY ( shift_type )
                REFERENCES shifts_type_master ( shift_type )
                    ON DELETE CASCADE,
            CONSTRAINT proctor_fk FOREIGN KEY ( proctor_id )
                REFERENCES proctor ( proctor_id )
                    ON DELETE CASCADE,
            CONSTRAINT supervisor_fk FOREIGN KEY ( supervisor_id )
                REFERENCES supervisor ( supervisor_id )
                    ON DELETE CASCADE,
            CONSTRAINT dorm_fk FOREIGN KEY ( dorm_id )
                REFERENCES dorm ( dorm_id )
                    ON DELETE CASCADE
    )!';
        dbms_output.put_line('Created : TABLE - SHIFTS');
    END IF;

    IF c_police = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - POLICE-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE police (
            police_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            police_name    VARCHAR(50) NOT NULL,
            police_gender  CHAR(1) NOT NULL CHECK ( police_gender = 'M'
                                                   OR police_gender = 'F' ),
            police_contact VARCHAR(15) NOT NULL CHECK ( REGEXP_LIKE (
                                            police_contact, '(???) ???????' ) ),
            CONSTRAINT police_pk PRIMARY KEY ( police_id )
        )!';
        dbms_output.put_line('Created : TABLE - POLICE');
    END IF;

    IF c_incident = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - INCIDENT-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE incident (
            case_id          NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
            dorm_id          NUMBER NOT NULL,
            case_type        VARCHAR(50) NOT NULL,
            case_description VARCHAR(100) NOT NULL,
            CONSTRAINT incident_pk PRIMARY KEY ( case_id ),
            CONSTRAINT incident_dorm_fk FOREIGN KEY ( dorm_id )
                REFERENCES dorm ( dorm_id )
                    ON DELETE CASCADE
        )!';
        dbms_output.put_line('Created : TABLE - INCIDENT');
    END IF;

    IF c_police_incident_mapping = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - POLICE_INCIDENT_MAPPING-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE police_incident_mapping (
            police_id   NUMBER NOT NULL,
            case_id     NUMBER NOT NULL,
            case_status VARCHAR(50) NOT NULL,
            CONSTRAINT police_case_mapping_pk PRIMARY KEY ( police_id,
                                                            case_id ),
            CONSTRAINT police_case_mapping_police_fk FOREIGN KEY ( police_id )
                REFERENCES police ( police_id )
                    ON DELETE CASCADE,
            CONSTRAINT police_case_mapping_incident_fk FOREIGN KEY ( case_id )
                REFERENCES incident ( case_id )
                    ON DELETE CASCADE
        )!';
        dbms_output.put_line('Created : TABLE - POLICE_INCIDENT_MAPPING');
    END IF;

    IF c_utility = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - UTILITY-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE utility (
            utility_id  NUMBER,
            access_date DATE NOT NULL,
            dorm_id     NUMBER,
            resident_id NUMBER NOT NULL,
            CONSTRAINT utility_master_fk FOREIGN KEY ( utility_id )
                REFERENCES utility_type_master ( utility_id )
                    ON DELETE CASCADE,
            CONSTRAINT utility_dorm_fk FOREIGN KEY ( dorm_id )
                REFERENCES dorm ( dorm_id )
                    ON DELETE CASCADE,
            CONSTRAINT utility_unique PRIMARY KEY ( utility_id,
                                                    access_date,
                                                    dorm_id )
        )!';
        dbms_output.put_line('Created : TABLE - UTILITY');
    END IF;

    IF c_guest = 1 THEN
        dbms_output.put_line('===================================');
        dbms_output.put_line('-------TABLE - GUEST-------');
        dbms_output.put_line('---------Already Exists--------');
        dbms_output.put_line('===================================');
    ELSE
        EXECUTE IMMEDIATE q'!CREATE TABLE guest (
            guest_id      NUMBER NOT NULL,
            guest_name    VARCHAR(50) NOT NULL,
            guest_contact VARCHAR(15) NOT NULL CHECK ( REGEXP_LIKE (
                                            guest_contact, '(???) ???????' ) ),
            visit_date    TIMESTAMP NOT NULL,
            resident_id   NUMBER NOT NULL,
            CONSTRAINT guest_pk PRIMARY KEY ( guest_id ),
            CONSTRAINT guest_fk FOREIGN KEY ( resident_id )
                REFERENCES resident ( resident_id )
                    ON DELETE CASCADE
        )!';
        dbms_output.put_line('Created : TABLE - GUEST');
    END IF;

    EXECUTE IMMEDIATE q'!CREATE OR REPLACE TRIGGER tri_guest BEFORE
            INSERT ON guest
            FOR EACH ROW
        BEGIN
            SELECT
                guest_seq.NEXTVAL
            INTO :new.guest_id
            FROM
                dual;
        END;!';
    dbms_output.put_line('Created : TRIGGER - TRI_GUEST');
    
    EXECUTE IMMEDIATE q'!CREATE OR REPLACE TRIGGER tri_student BEFORE
            INSERT ON student
            FOR EACH ROW
        BEGIN
            SELECT
                student_seq.NEXTVAL
            INTO :new.student_id
            FROM
                dual;
        END;!';
    dbms_output.put_line('Created : TRIGGER - TRI_STUDENT');
END;
/

EXEC p_intial_reset();