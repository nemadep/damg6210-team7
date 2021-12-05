CREATE OR REPLACE FUNCTION f_is_valid_resident (
    residentid IN NUMBER
) RETURN NUMBER IS
    is_valid_resident NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO is_valid_resident
    FROM
        resident
    WHERE
        resident_id = residentid;

    RETURN is_valid_resident;
END;
/

CREATE OR REPLACE PROCEDURE p_guest_entry (
    guestname    VARCHAR,
    guestcontact VARCHAR,
    residentid   NUMBER
) AS
    is_valid_resident NUMBER;
    e_valid_resident EXCEPTION;
BEGIN
    is_valid_resident := f_is_valid_resident(residentid);
    IF is_valid_resident = 0 THEN
        RAISE e_valid_resident;
    END IF;
    INSERT INTO guest (
        guest_name,
        guest_contact,
        visit_date,
        resident_id
    ) VALUES (
        guestname,
        guestcontact,
        current_timestamp,
        residentid
    );

EXCEPTION
    WHEN e_valid_resident THEN
        dbms_output.put_line('Invalid resdient. Resident doesnt exists!');
END;
/

-- Example
EXEC p_guest_entry('Prathamesh', '(857) 3186354', 1);
EXEC p_guest_entry('Viraj', '(123) 2354566', 2);
EXEC p_guest_entry('Urvang', '(233) 3545465', 3);
EXEC p_guest_entry('Vidhi', '(442) 2345456', 4);
EXEC p_guest_entry('Milind', '(562) 8765433', 5);

SELECT * FROM guest;