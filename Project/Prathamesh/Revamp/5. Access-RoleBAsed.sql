BEGIN
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating Users');

/*
    Package - manage_users_and_access
    Procedure - create_user
    Arguments - @username, @password
*/
    manage_users_and_access.create_user('sysadmin1', 'Abc@1234');
    manage_users_and_access.create_user('supervisor1', 'Abc@1234');
    manage_users_and_access.create_user('resident1', 'Abc@1234');
    manage_users_and_access.create_user('proctor1', 'Abc@1234');
    manage_users_and_access.create_user('police1', 'Abc@1234');
    
    dbms_output.put_line('Users created successfully!!');
    dbms_output.put_line('Creating ROLE - SYSADMIN');
    manage_users_and_access.create_role('sysadmin');
    dbms_output.put_line('ROLE - SYSADMIN created successfully!');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access giving to ROLE - SYSADMIN....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('resident', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('guest', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('shifts', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('supervisor', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('swipe_log', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('proctor', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('dorm', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility_type_master', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('incident', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('police', 'sysadmin', 'SELECT, INSERT, UPDATE, DELETE');
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
    manage_users_and_access.create_role('supervisor');
    dbms_output.put_line('ROLE - SUPERVISOR created successfully!');
    dbms_output.put_line('Access giving to ROLE - SUPERVISOR....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('guest', 'supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('shifts', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('supervisor', 'supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('swipe_log', 'supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('proctor', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('dorm', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('utility_type_master', 'supervisor', 'SELECT, INSERT, UPDATE, DELETE');
    manage_users_and_access.manage_role_access('incident', 'supervisor', 'SELECT');
    manage_users_and_access.manage_role_access('police', 'supervisor', 'SELECT');
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
    manage_users_and_access.create_role('resident');
    dbms_output.put_line('ROLE - RESIDENT created successfully!');
    dbms_output.put_line('Access giving to ROLE - RESIDENT....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'resident', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'resident', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'resident', 'SELECT');
    manage_users_and_access.manage_role_access('utility', 'resident', 'SELECT');
    manage_users_and_access.manage_role_access('utility_type_master', 'resident', 'SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Access Granted to - RESIDENT');
    dbms_output.put_line('TABLE: STUDENT  - SELECT');
    dbms_output.put_line('TABLE: RESIDENT  - SELECT');
    dbms_output.put_line('TABLE: DORM  - SELECT');
    dbms_output.put_line('TABLE: UTILITY  - SELECT');
    dbms_output.put_line('TABLE: UTILITY_TYPE_MASTER - SELECT');
    dbms_output.put_line('***************************');
    dbms_output.put_line('Creating ROLE - PROCTOR');
    manage_users_and_access.create_role('proctor');
    dbms_output.put_line('ROLE - PROCTOR created successfully!');
    dbms_output.put_line('Access giving to ROLE - PROCTOR....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('student', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('resident', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('guest', 'proctor', 'SELECT, INSERT, UPDATE');
    manage_users_and_access.manage_role_access('shifts', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('supervisor', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('swipe_log', 'proctor', 'SELECT, INSERT');
    manage_users_and_access.manage_role_access('proctor', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('utility', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('utility_type_master', 'proctor', 'SELECT');
    manage_users_and_access.manage_role_access('incident', 'proctor', 'SELECT, INSERT, UPDATE');
    manage_users_and_access.manage_role_access('police', 'proctor', 'SELECT');
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
    manage_users_and_access.create_role('police');
    dbms_output.put_line('ROLE - POLICE created successfully!');
    dbms_output.put_line('Access giving to ROLE - POLICE....');
/*
    Package - manage_users_and_access
    Procedure - manage_role_access
    Arguments - @tablename, @role, @access_type
*/
    manage_users_and_access.manage_role_access('supervisor', 'police', 'SELECT');
    manage_users_and_access.manage_role_access('proctor', 'police', 'SELECT');
    manage_users_and_access.manage_role_access('dorm', 'police', 'SELECT');
    manage_users_and_access.manage_role_access('incident', 'police', 'SELECT, UPDATE');
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
    manage_users_and_access.grant_role_to_user('sysadmin', 'sysadmin1');
    manage_users_and_access.grant_role_to_user('supervisor', 'supervisor1');
    manage_users_and_access.grant_role_to_user('resident', 'resident1');
    manage_users_and_access.grant_role_to_user('proctor', 'proctor1');
    manage_users_and_access.grant_role_to_user('police', 'police1');
    dbms_output.put_line('Roles allocated successfully...');
END;
/
