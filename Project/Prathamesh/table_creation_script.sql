DROP TABLE shifts_type_master;
DROP TABLE student;

CREATE TABLE shifts_type_master (
    shift_type CHAR(4) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time   TIMESTAMP NOT NULL,
    CONSTRAINT shifts_type_master_pk PRIMARY KEY ( shift_type )
);

CREATE TABLE student (
    student_id      INTEGER NOT NULL,
    student_name    VARCHAR(50) NOT NULL,
    student_contact VARCHAR(15) NOT NULL CHECK ( student_contact LIKE '(???)???-????' ),
    student_dob     DATE NOT NULL,
    student_gender  CHAR(1) NOT NULL CHECK ( student_gender = 'M'
                                            OR student_gender = 'F' ),
    is_resident     CHAR(5) DEFAULT 'FALSE' CHECK ( is_resident IN ( 'TRUE', 'FALSE' ) ),
    permanent_address VARCHAR2(320) NOT NULL,
    student_email     VARCHAR2(100) NOT NULL CHECK ( REGEXP_LIKE ( student_email,
                                                               '^(\S+)\@(\S+)\.(\S+)$' ) ),
    CONSTRAINT student_pk PRIMARY KEY ( student_id )
);

CREATE SEQUENCE student_seq;

CREATE OR REPLACE TRIGGER student_seq BEFORE
    INSERT ON student
    FOR EACH ROW
BEGIN
    SELECT
        student_seq.NEXTVAL
    INTO :new.student_id
    FROM
        dual;
END;