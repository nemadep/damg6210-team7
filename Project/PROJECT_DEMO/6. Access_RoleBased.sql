SET SERVEROUTPUT ON;

/*
    In case to kill the ongoing session from ADMIN
    1. select * from v$session;
    2. ALTER SYSTEM KILL SESSION '<SID>, <SERIAL>';
    
    
    SELECT * FROM DBA_ROLES;
    SELECT * FROM DBA_USERS;
    SELECT * FROM DBA_TAB_PRIVS;
    select * from DBA_CONNECT_ROLE_GRANTEES;
*/

/*
    Steps to create a session - 
    1. Create a USER
    2. Grant a ROLE or priveledges to the user
    3. Create a session

    Following is the example of creation of USER and allocating the ROLE:
    1. CREATE USER sysadmin1 IDENTIFIED BY "Demo@DMDD6210";
    2. GRANT r_sysadmin TO sysadmin1;
    3. GRANT CREATE SESSION TO sysadmin1;
    
    
    Steps to add or login into a user are - 
    1. Right click on the custer > Properties > Change Name, UserName, Password. 
    DONE!
    
    You can access the tables by the prefixing the name of the owner.
*/


BEGIN
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating Users');

/*
    Package - manage_users_and_access
    Procedure - create_user
    Arguments - @username, @password
*/
    manage_users_and_access.create_user('sysadmin1', 'Demo@DMDD6210');
    manage_users_and_access.create_user('supervisor1', 'Demo@DMDD6210');
    manage_users_and_access.create_user('resident1', 'Demo@DMDD6210');
    manage_users_and_access.create_user('proctor1', 'Demo@DMDD6210');
    manage_users_and_access.create_user('police1', 'Demo@DMDD6210');
    dbms_output.put_line('Users created successfully!!');
    dbms_output.put_line('Creating ROLE - SYSADMIN');
    manage_users_and_access.create_role('r_sysadmin');
    dbms_output.put_line('ROLE - SYSADMIN created successfully!');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access giving to ROLE - SYSADMIN....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('resident', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('guest', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('shifts', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('supervisor', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('swipe_log', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('proctor', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('dorm', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility_type_master', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('incident', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('police', 'r_sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - SYSADMIN');
    dbms_output.put_line('TABLE: STUDENT  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: RESIDENT  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: GUEST  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: SHIFTS  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: SUPERVISOR  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: SWIPE_LOG  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: PROCTOR  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: DORM  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: UTILITY  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: UTILITY_TYPE_MASTER - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: INCIDENT  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: POLICE  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating ROLE - SUPERVISOR');
    manage_users_and_access.create_role('r_supervisor');
    dbms_output.put_line('ROLE - SUPERVISOR created successfully!');
    dbms_output.put_line('Access giving to ROLE - SUPERVISOR....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'r_supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('guest', 'r_supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('shifts', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('supervisor', 'r_supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('swipe_log', 'r_supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('proctor', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('dorm', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility_type_master', 'r_supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('incident', 'r_supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('police', 'r_supervisor', 'SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - SUPERVISOR');
    dbms_output.put_line('TABLE: STUDENT  - SELECT');
    dbms_output.put_line('TABLE: RESIDENT  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: GUEST  - SELECT');
    dbms_output.put_line('TABLE: SHIFTS  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: SUPERVISOR  - SELECT');
    dbms_output.put_line('TABLE: SWIPE_LOG  - SELECT');
    dbms_output.put_line('TABLE: PROCTOR  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: DORM  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: UTILITY  - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: UTILITY_TYPE_MASTER - SELECT, INSERT, UPDATE, DELETE');
    dbms_output.put_line('TABLE: INCIDENT  - SELECT');
    dbms_output.put_line('TABLE: POLICE  - SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating ROLE - RESIDENT');
    manage_users_and_access.create_role('r_resident');
    dbms_output.put_line('ROLE - RESIDENT created successfully!');
    dbms_output.put_line('Access giving to ROLE - RESIDENT....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'r_resident', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'r_resident', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'r_resident', 'SELECT');
    manage_users_and_access.manage_role_access('utility', 'r_resident', 'SELECT');
    manage_users_and_access.manage_role_access('utility_type_master', 'r_resident', 'SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - RESIDENT');
    dbms_output.put_line('TABLE: STUDENT  - SELECT');
    dbms_output.put_line('TABLE: RESIDENT  - SELECT');
    dbms_output.put_line('TABLE: DORM  - SELECT');
    dbms_output.put_line('TABLE: UTILITY  - SELECT');
    dbms_output.put_line('TABLE: UTILITY_TYPE_MASTER - SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating ROLE - PROCTOR');
    manage_users_and_access.create_role('r_proctor');
    dbms_output.put_line('ROLE - PROCTOR created successfully!');
    dbms_output.put_line('Access giving to ROLE - PROCTOR....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('guest', 'r_proctor', 'SELECT, INSERT, UPDATE');
    manage_users_and_access.manage_role_access('shifts', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('supervisor', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('swipe_log', 'r_proctor', 'SELECT, INSERT');
    manage_users_and_access.manage_role_access('proctor', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('utility', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('utility_type_master', 'r_proctor', 'SELECT');
    manage_users_and_access.manage_role_access('incident', 'r_proctor', 'SELECT, INSERT, UPDATE');
    manage_users_and_access.manage_role_access('police', 'r_proctor', 'SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - PROCTOR');
    dbms_output.put_line('TABLE: STUDENT  - SELECT');
    dbms_output.put_line('TABLE: RESIDENT  - SELECT');
    dbms_output.put_line('TABLE: GUEST  - SELECT, INSERT, UPDATE');
    dbms_output.put_line('TABLE: SHIFTS  - SELECT');
    dbms_output.put_line('TABLE: SUPERVISOR  - SELECT');
    dbms_output.put_line('TABLE: SWIPE_LOG  - SELECT, INSERT');
    dbms_output.put_line('TABLE: PROCTOR  - SELECT');
    dbms_output.put_line('TABLE: DORM  - SELECT');
    dbms_output.put_line('TABLE: UTILITY  - SELECT');
    dbms_output.put_line('TABLE: UTILITY_TYPE_MASTER - SELECT');
    dbms_output.put_line('TABLE: INCIDENT  - SELECT, INSERT, UPDATE');
    dbms_output.put_line('TABLE: POLICE  - SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating ROLE - POLICE');
    manage_users_and_access.create_role('r_police');
    dbms_output.put_line('ROLE - POLICE created successfully!');
    dbms_output.put_line('Access giving to ROLE - POLICE....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('supervisor', 'r_police', 'SELECT');
    manage_users_and_access.manage_role_access('proctor', 'r_police', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'r_police', 'SELECT');
    manage_users_and_access.manage_role_access('incident', 'r_police', 'SELECT, UPDATE');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - POLICE');
    dbms_output.put_line('TABLE: SUPERVISOR  - SELECT');
    dbms_output.put_line('TABLE: PROCTOR  - SELECT');
    dbms_output.put_line('TABLE: DORM  - SELECT');
    dbms_output.put_line('TABLE: INCIDENT  - SELECT, UPDATE');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Allocating Roles...');
/*
    Package - manage_users_and_access
    Procedure - grant_role_to_user
    Arguments - @rolename, @username
*/
    manage_users_and_access.grant_role_to_user('r_sysadmin', 'sysadmin1');
    manage_users_and_access.grant_role_to_user('r_supervisor', 'supervisor1');
    manage_users_and_access.grant_role_to_user('r_resident', 'resident1');
    manage_users_and_access.grant_role_to_user('r_proctor', 'proctor1');
    manage_users_and_access.grant_role_to_user('r_police', 'police1');
    dbms_output.put_line('Roles allocated successfully...');
END;
/

