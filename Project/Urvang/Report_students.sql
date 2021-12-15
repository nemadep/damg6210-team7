CREATE OR REPLACE VIEW students_opting_dorms AS
    SELECT
        is_resident, (select count(*) from student) total_students,
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