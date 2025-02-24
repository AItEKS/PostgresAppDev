SELECT
    t3.first_name,
    t3.last_name,
    t4.position_name,
    COUNT(t1.measurment_batch_id) AS total_measurement_count,
    SUM(CASE WHEN egor.fn_has_error(t2.height, t2.temperature, t2.pressure, t2.wind_direction, t2.bullet_speed) THEN 1 ELSE 0 END) AS error_measurement_count
FROM
    egor.measurment_batch t1
INNER JOIN
    egor.measurment_params AS t2 ON t1.measurment_batch_id = t2.measurment_batch_id
INNER JOIN
    egor.users AS t3 ON t3.user_id = t1.user_id
INNER JOIN
    egor.military_positions AS t4 ON t3.military_positions_id = t4.military_positions_id
GROUP BY
    t3.first_name,
    t3.last_name,
    t4.position_name
ORDER BY
    error_measurement_count DESC;