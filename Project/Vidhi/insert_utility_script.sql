CREATE OR REPLACE FUNCTION f_is_valid_utility (
    utilityid IN NUMBER
) RETURN NUMBER IS
    is_valid_utility NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO is_valid_utility
    FROM
        utility_type_master 
    WHERE
        utility_id = utilityid;

    RETURN is_valid_utility;
END;
/

CREATE OR REPLACE PROCEDURE p_utility_entry (
    utilityid   NUMBER,
    residentid   NUMBER
) AS
    is_valid_utility NUMBER;
    is_valid_resident NUMBER;
    e_valid_resident EXCEPTION;
    e_valid_utility EXCEPTION;
    dormid NUMBER;
BEGIN
    is_valid_utility := f_is_valid_utility(utilityid);
    IF is_valid_utility = 0 THEN
        RAISE e_valid_utility;
    END IF;

    is_valid_resident := f_is_valid_resident(residentid);
    IF is_valid_resident = 0 THEN
        RAISE e_valid_resident;
    END IF;

    SELECT dorm_id into dormid
    FROM resident
    WHERE resident_id = reisdentid;

    INSERT INTO utility (
        utility_id,
        access_date,
        dorm_id,
        resident_id
    ) VALUES (
        utilityid,
        sysdate,
        dormid,
        residentid
    );

EXCEPTION
    WHEN e_valid_resident THEN
        dbms_output.put_line('Invalid resdient. Resident doesnt exists!');
    WHEN e_valid_utility THEN
        dbms_output.put_line('Invalid utility. Utility doesnt exists!');
    WHEN OTHERS
        dbms_output.put_line(SQLERRM);
END;
/


-- Example
EXEC p_utility_entry(1, 3);
EXEC p_utility_entry(6, 6);
EXEC p_utility_entry(8, 5);
EXEC p_utility_entry(2, 4);
EXEC p_utility_entry(1, 3);

EXEC p_utility_entry(12, 2);
EXEC p_utility_entry(14, 1);
EXEC p_utility_entry(3, 3);
EXEC p_utility_entry(4, 4);
EXEC p_utility_entry(2, 5);

EXEC p_utility_entry(11, 6);
EXEC p_utility_entry(17, 2);
EXEC p_utility_entry(19, 4);
EXEC p_utility_entry(4, 3);
EXEC p_utility_entry(5, 2);

EXEC p_utility_entry(7, 1);
EXEC p_utility_entry(9, 4);
EXEC p_utility_entry(10, 4);
EXEC p_utility_entry(15, 5);
EXEC p_utility_entry(20, 6);


SELECT * FROM utility;