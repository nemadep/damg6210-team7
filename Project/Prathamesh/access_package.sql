SET SERVEROUTPUT ON;

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

END;
/

CREATE OR REPLACE PACKAGE BODY manage_users_and_access AS

    PROCEDURE create_user (
        username VARCHAR,
        password VARCHAR
    ) IS
    BEGIN
        dbms_output.put_line('CREATE USER '
                             || username
                             || ' IDENTIFIED BY '
                             || password);
        EXECUTE IMMEDIATE 'CREATE USER '
                          || ''
                          || username
                          || ''
                          || ' IDENTIFIED BY '
                          || '"'
                          || password
                          || '"';

    END;

    PROCEDURE create_role (
        rolename VARCHAR
    ) IS
        is_role_available NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO is_role_available
        FROM
            dba_roles
        WHERE
            lower(role) = lower(rolename);

        IF ( is_role_available = 1 ) THEN
            dbms_output.put_line('Role already created!!');
        ELSE
            EXECUTE IMMEDIATE 'CREATE ROLE ' || rolename;
        END IF;

    END;

    PROCEDURE manage_role_access (
        tablename   VARCHAR,
        rolename    VARCHAR,
        accesstypes VARCHAR
    ) IS
        is_role_available NUMBER;
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
            dbms_output.put_line('Role not created!!');
        END IF;

    END;

END;
/

-- username, password
EXEC manage_users_and_access.create_user('student', 'Abc@1234');
-- rolename
EXEC manage_users_and_access.create_role('police');
-- tablename, rolename, allow-what
EXEC manage_users_and_access.manage_role_access('supervisor', 'police', 'SELECT');





/*
SELECT
    *
FROM
    user_tab_privs
WHERE
    grantee = 'POLICE';
*/

SHOW USER;