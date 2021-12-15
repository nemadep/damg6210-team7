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