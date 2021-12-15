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
        
select * from proctorwithmaxshifts;