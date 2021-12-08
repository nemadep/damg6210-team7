
-- usage of sysdate instead of current_timestamp would give you UTC time

CREATE OR REPLACE PROCEDURE p_swipe_me (
    residentid NUMBER,
    dormid     NUMBER
) AS
BEGIN
    INSERT INTO swipe_log (
        resident_id,
        swipe_time,
        dorm_id
    ) VALUES (
        residentid,
        current_timestamp,
        dormid
    );

END;
/

-- Example
-- studentId, dormId
EXEC p_swipe_me(1, 8);
EXEC p_swipe_me(2, 1);
EXEC p_swipe_me(3, 2);
EXEC p_swipe_me(4, 3);
EXEC p_swipe_me(5, 9);

/*
SELECT
    *
FROM
    swipe_log;
*/

--TRUNCATE TABLE swipe_log;