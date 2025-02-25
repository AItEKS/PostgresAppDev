SELECT
    u.first_name,
    u.last_name,
    mp.position_name,
    (
        SELECT COUNT(mb.measurment_batch_id)
        FROM egor.measurment_batch mb
        WHERE mb.user_id = u.user_id
    ) AS total_measurement_count,
    (
        SELECT SUM(CASE WHEN egor.fn_has_error(mp2.height, mp2.temperature, mp2.pressure, mp2.wind_direction, mp2.bullet_speed) THEN 1 ELSE 0 END)
        FROM egor.measurment_batch mb2
        INNER JOIN egor.measurment_params mp2 ON mb2.measurment_batch_id = mp2.measurment_batch_id
        WHERE mb2.user_id = u.user_id
    ) AS error_measurement_count
FROM
    egor.users u
INNER JOIN
    egor.military_positions mp ON u.military_positions_id = mp.military_positions_id
ORDER BY
    error_measurement_count DESC;