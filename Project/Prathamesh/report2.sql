-- guests logs

CREATE OR REPLACE VIEW v_guests_stats AS
    WITH resident_info AS (
        SELECT
            resident.resident_id AS resident_id,
            student.student_name AS resident_name,
            resident.to_date     AS resident_to_date
        FROM
            resident
            LEFT JOIN student ON resident.student_id = student.student_id
        WHERE
            to_date(resident.to_date, 'DD-MM-YYYY') >= to_date(sysdate, 'DD-MM-YYYY')
    ), guest_count AS (
        SELECT DISTINCT
            resident_info.resident_name,
            COUNT(*)
            OVER(PARTITION BY resident_info.resident_id) AS count_guest
        FROM
            resident_info
            LEFT JOIN guest ON resident_info.resident_id = guest.resident_id
    )
    SELECT
        resident_name,
        count_guest
    FROM
        (
            SELECT
                guest_count.*,
                ROW_NUMBER()
                OVER(
                    ORDER BY
                        count_guest DESC
                ) row_number
            FROM
                guest_count
            ORDER BY
                count_guest DESC
        )
    WHERE
        row_number <= 10;

SELECT
    *
FROM
    v_guests_stats;