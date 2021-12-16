----------------------- REPORTS ------------------------------

--report to show top 10 utilities that are most accessed by residents.
CREATE OR REPLACE VIEW v_utility_access AS
    WITH utility_info AS(
        SELECT 
            distinct(u.utility_id), 
            um.utility_name
        FROM 
            utility_type_master um 
            RIGHT JOIN utility u ON um.utility_id = u.utility_id
    ),utiltiy_access_count AS(
        SELECT 
            utility_id, 
            count(access_date) AS count_utiltity
        FROM 
            utility
        GROUP BY 
            utility_id
    ),info_access AS(
        SELECT  
            c.utility_id, 
            i.utility_name, 
            c.count_utiltity
        FROM 
        utility_info i 
        INNER JOIN utiltiy_access_count c
        ON i.utility_id = c.utility_id
    )
    SELECT
        utility_id,
        utility_name,
        count_utiltity
    FROM
        (
            SELECT
                info_access.*,
                ROW_NUMBER()
                OVER(
                    ORDER BY
                        count_utiltity DESC
                ) row_number
            FROM
                info_access
            ORDER BY
                count_utiltity DESC
        )
    WHERE
        row_number <= 10;

SELECT * 
FROM 
v_utility_access;

--report to show number of cases generated from respective dorms
CREATE OR REPLACE VIEW v_no_of_cases AS
    WITH cases_count AS(
        SELECT 
            dorm_id, 
            count(case_id) AS count_cases
        FROM 
            incident
        GROUP BY 
            dorm_id
    ), info_dorm AS(
        SELECT  
            c.dorm_id, 
            d.dorm_name, 
            c.count_cases
        FROM 
        dorm d 
        INNER JOIN cases_count c
        ON d.dorm_id = c.dorm_id
    )
    SELECT
        (select count(*) from incident) total_cases,
        dorm_name,
        count_cases
    FROM
        (
            SELECT
                info_dorm.*
                
            FROM
                info_dorm
            ORDER BY
                count_cases DESC 
 );

SELECT * 
FROM 
v_no_of_cases;

--report to show top 10 residents with maximum swipes
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

--report to show top 10 residents who boards maximum no. of guests
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


/*Report to find the proctor scheduled with max number of shifts*/

CREATE OR REPLACE VIEW proctorwithmaxshifts AS
    WITH shift_dist AS (
        SELECT
            proctor_id,
            COUNT(*) shift_count
        FROM
            shifts
        GROUP BY
            proctor_id
    )
    SELECT
        *
    FROM
        (
            SELECT
                distribution.proctor_id,
                proc_details.proctor_name,
                distribution.shift_count
            FROM
                     proctor proc_details
                JOIN shift_dist distribution ON proc_details.proctor_id = distribution.proctor_id
            ORDER BY
                shift_count DESC
        );

SELECT
    *
FROM
    proctorwithmaxshifts;


--Report to check how many dorm are occupied   
CREATE OR REPLACE VIEW dorm_occupancy AS
    WITH dorm_cap AS (
        SELECT
            dorm_id,
            dorm_capacity
        FROM
            dorm
    ), dorm_occ AS (
        SELECT
            res.dorm_id,
            COUNT(*) dorm_count
        FROM
            resident res
        WHERE
            to_date >= sysdate
        GROUP BY
            res.dorm_id
    )
    SELECT
        dc.dorm_id, dc.dorm_capacity,
        nvl((dc.dorm_capacity - do.dorm_count), dc.dorm_capacity) AS rooms_left
    FROM
        dorm_cap dc
        LEFT JOIN dorm_occ do ON dc.dorm_id = do.dorm_id;

SELECT
    *
FROM
    dorm_occupancy;

--Report students opting for dorms   
CREATE OR REPLACE VIEW students_opting_dorms AS
    SELECT
        (select count(*) from student) total_students,
        is_resident,
        COUNT(*) student_count
    FROM
        student
    GROUP BY
        is_resident
    order by student_count;


SELECT
    *
FROM
    students_opting_dorms;