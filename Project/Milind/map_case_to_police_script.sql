-- Mapping case to police procedure
create or replace PROCEDURE mapCaseToPolice (

    policeID    NUMBER,
    caseID      NUMBER,
    caseStatus  VARCHAR

) IS
    
    is_police_available     NUMBER;
    is_case_available       NUMBER;
    is_case_already_mapped  NUMBER;
    
    e_police_valid          EXCEPTION;
    e_case_valid            EXCEPTION;
    e_case_already_mapped   EXCEPTION;
    
BEGIN
    
    -- Check if case is already assigned to a police
    SELECT 
        COUNT(*)
    INTO is_case_already_mapped
    FROM
        police_incident_mapping
    WHERE case_id = caseID;
        
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
                    policeID,
                    caseID,
                    caseStatus
                );
            
        END IF;
    
    ELSE
        RAISE e_case_already_mapped;
    END IF;
    
EXCEPTION

    WHEN e_case_already_mapped THEN
        dbms_output.put_line('Case already mapped to police!');
    
    WHEN e_police_valid THEN
        dbms_output.put_line('Invalid police!');
    
    WHEN e_case_valid THEN
        dbms_output.put_line('Invalid case!');
END;
/

-- Example:
-- Police id, Case id, Case status
EXEC mapCaseToPolice(3, 4, 'Open');

EXEC mapCaseToPolice(8, 7, 'Open');

EXEC mapCaseToPolice(24, 1, 'Open');

EXEC mapCaseToPolice(38, 2, 'Open');

EXEC mapCaseToPolice(13, 6, 'Open');


SELECT
    *
FROM
    police_incident_mapping;
    
    SELECT
    *
FROM
    police;