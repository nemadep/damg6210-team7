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

    FUNCTION f_get_first_available_dorm RETURN NUMBER;

    PROCEDURE p_guest_entry (
        guestname    VARCHAR,
        guestcontact VARCHAR,
        residentid   NUMBER
    );

    PROCEDURE p_swipe_me (
        residentid NUMBER,
        dormid     NUMBER
    );

    PROCEDURE p_resident_addition (
        studentid  NUMBER,
        isresident VARCHAR
    );

END;
/

CREATE OR REPLACE PACKAGE manage_users_and_access AS
    PROCEDURE create_user (
        username VARCHAR,
        password VARCHAR
    );

    PROCEDURE create_role (
        rolename VARCHAR
    );

    PROCEDURE manage_role_access (
        tablename   VARCHAR,
        rolename    VARCHAR,
        accesstypes VARCHAR
    );

    PROCEDURE grant_role_to_user (
        rolename VARCHAR,
        username VARCHAR
    );

    FUNCTION f_is_user_already_created (
        username VARCHAR
    ) RETURN NUMBER;

END;
/