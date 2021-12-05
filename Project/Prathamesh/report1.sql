-- swipe logs ranking

CREATE OR REPLACE VIEW v_log_stats AS
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
    ), resident_log_details AS (
        SELECT
            resident_info.resident_name,
            swipe_log.swipe_time,
            dorm.dorm_name
        FROM
            resident_info
            LEFT JOIN swipe_log ON resident_info.resident_id = swipe_log.resident_id
            LEFT JOIN dorm ON dorm.dorm_id = swipe_log.dorm_id
        WHERE
            swipe_log.swipe_time IS NOT NULL
    ), resident_counts AS (
        SELECT DISTINCT
            resident_name,
            COUNT(*)
            OVER(PARTITION BY resident_name) AS swipe_count
        FROM
            resident_log_details
    )
    SELECT
        resident_name,
        swipe_count
    FROM
        (
            SELECT
                resident_name,
                swipe_count,
                ROW_NUMBER()
                OVER(
                    ORDER BY
                        swipe_count DESC
                ) AS count_rank
            FROM
                resident_counts
            ORDER BY
                swipe_count DESC
        )
    WHERE
        count_rank <= 10;

SELECT
    *
FROM
    v_log_stats;