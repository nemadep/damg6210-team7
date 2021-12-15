-- Close case procedure
create or replace PROCEDURE closeCase (

    policeID    NUMBER,
    caseID      NUMBER,
    caseStatus  VARCHAR 

) IS
    
    is_police_available             NUMBER;
    is_case_available               NUMBER;
    is_case_already_closed          NUMBER;
    is_case_mapped_to_given_police  NUMBER;

    
    e_police_valid                      EXCEPTION;
    e_case_valid                        EXCEPTION;
    e_case_already_closed               EXCEPTION;
    e_case_status_not_valid             EXCEPTION;
    e_case_not_mapped_to_given_police   EXCEPTION;
   
BEGIN
    
    -- Check if given case is mapped to the given police
    SELECT 
        COUNT(*)
    INTO is_case_mapped_to_given_police
    FROM
        police_incident_mapping
    WHERE (case_id = caseId AND police_id = policeId);
    
    -- Check if case is already closed
    SELECT 
        COUNT(*)
    INTO is_case_already_closed
    FROM
        police_incident_mapping
    WHERE (case_id = caseId AND case_status = caseStatus);
        
    -- Check if police exists
    SELECT
        COUNT(*)
    INTO is_police_available
    FROM
        police
    WHERE
        police_id = policeID;
        
    -- Check is case exists
    SELECT
        COUNT(*)
    INTO is_case_available
    FROM
        incident
    WHERE
        case_id = caseID;
    
    IF is_police_available = 0 THEN
        RAISE e_police_valid;
            
    ELSIF is_case_available = 0 THEN
        RAISE e_case_valid;
            
    ELSIF is_case_mapped_to_given_police = 0 THEN
        RAISE e_case_not_mapped_to_given_police;
    
    ELSIF caseStatus != 'Closed' THEN
        RAISE e_case_status_not_valid;
        
    ELSIF is_case_already_closed > 0 THEN
        RAISE e_case_already_closed;
            
    ELSE
        UPDATE police_incident_mapping
        SET case_status = caseStatus
        WHERE case_id = caseID;
            
    END IF;
    
    
EXCEPTION

    WHEN e_case_already_closed THEN
        dbms_output.put_line('Case already closed!');
    
    WHEN e_police_valid THEN
        dbms_output.put_line('Invalid police!');
    
    WHEN e_case_valid THEN
        dbms_output.put_line('Invalid case!');
        
    WHEN e_case_status_not_valid THEN
        dbms_output.put_line('Case status is not valid!');
        
    WHEN e_case_not_mapped_to_given_police THEN
        dbms_output.put_line('Case is not mapped to the given police!');
        
END;
/

-- Police id, Case id, Case status
EXEC closeCase(3, 4, 'Closed');

EXEC closeCase(8, 7, 'Closed');

EXEC closeCase(2, 1, 'Closed');

EXEC closeCase(38, 2, 'Open');

EXEC closeCase(13, 4, 'Closed');

EXEC closeCase(143, 54, 'Closed');

EXEC closeCase(13, 54, 'Closed');