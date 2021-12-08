-- Cases count 
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
        dorm_id,
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