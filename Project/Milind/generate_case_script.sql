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
        RAISE_APPLICATION_ERROR(-20210, 'Invalid dorm!');
END;
/

-- Example:
-- Dorm id, Case type, Case description
EXEC generateCase(1, 'Shooting', 'Two shots fired inside the dorm');

EXEC generateCase(5, 'Cybercrime', 'Account hacked');

EXEC generateCase(12, 'Vandalism', 'Someone is breaking the dorm windows');

EXEC generateCase(9, 'Theft', 'Armed robbery at Dorm');

EXEC generateCase(19, 'Suicide', 'John shot himself');

EXEC generateCase(8, 'Homicide', 'Francisco was found dead in his room. He was stabbed!');

EXEC generateCase(5, 'Theft', 'Personal items of residents stolen');


SELECT
    *
FROM
    incident;