-- Generate case procedure
create or replace PROCEDURE generateCase (

    dormID           NUMBER,
    caseType         VARCHAR,
    caseDescription  VARCHAR
    
) IS

    is_available           NUMBER;
    e_dorm_valid           EXCEPTION;

BEGIN

    -- Check if dorm exists
    SELECT
        COUNT(*)
    INTO is_available
    FROM
        dorm
    WHERE
        dorm_id = dormID;

    IF is_available > 0 THEN

        INSERT INTO incident (
                dorm_id,
                case_type,
                case_description
            ) VALUES (
                dormID,
                caseType,
                caseDescription
            );

    ELSE
        RAISE e_dorm_valid;
    END IF;

EXCEPTION

    WHEN e_dorm_valid THEN
        dbms_output.put_line('Invalid dorm!');
END;
/

-- Example:
-- Dorm id, Case type, Case description
EXEC generateCase(1, 'Shooting', 'Two shots fired inside the dorm');

EXEC generateCase(5, 'Cybercrime', 'Account hacked');

EXEC generateCase(9, 'Theft', 'Armed robbery at Dorm');

EXEC generateCase(19, 'Suicide', 'John shot himself');

EXEC generateCase(8, 'Homicide', 'Francisco was found dead in his room. He was stabbed!');

EXEC generateCase(5, 'Theft', 'Personal items of residents stolen');

EXEC generateCase(8, 'Cybercrime', 'Account of a resident hacked');

EXEC generateCase(1, 'Drug possession', 'One resident found taking drugs');

EXEC generateCase(5, 'Vandalism', 'Someone is breaking the dorm windows');

EXEC generateCase(8, 'Drug possession', 'Tim found taking drugs');

EXEC generateCase(12, 'Vandalism', 'Someone is breaking the dorm property');

EXEC generateCase(9, 'Theft', 'Robbery at Dorm');

EXEC generateCase(8, 'Suicide', 'Fred jumped from sixth floor!');

EXEC generateCase(5, 'Murder', 'Someone killed two residents outside the dorm');

EXEC generateCase(1, 'Theft', 'Expensive items found stolen');

EXEC generateCase(5, 'Drug possession', 'Two residents found taking drugs');

EXEC generateCase(8, 'Murder attempt', 'Janet tried to stab Karen');

EXEC generateCase(12, 'Suicide', 'David shot himself');

EXEC generateCase(9, 'Theft', 'Personal items of a resident found stolen');

EXEC generateCase(5, 'Theft', 'Armed robbery at dorm');

EXEC generateCase(9, 'Murder', 'David killed Sarah');


SELECT
    *
FROM
    incident;