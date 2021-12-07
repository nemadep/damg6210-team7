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