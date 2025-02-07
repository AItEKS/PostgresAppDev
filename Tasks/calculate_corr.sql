DO $$
DECLARE 
    params egor.interpolation_params;
	target_x numeric := 23;
BEGIN
	SELECT t1.temperature AS x0, t1.delta AS y0, t2.temperature AS x1, t2.delta AS y1 INTO params
	FROM egor.constant_params_1 t1 
	JOIN egor.constant_params_1 t2 ON t2.temperature > t1.temperature AND t2.delta > t1.delta
	WHERE t1.temperature = (SELECT temperature FROM egor.constant_params_1 WHERE temperature < target_x ORDER BY temperature DESC LIMIT 1) LIMIT 1;

	RAISE NOTICE 'Correction: %', ROUND(params.y1 + ((params.x1 - params.y1) / (params.x0 - params.y0)) * (target_x - params.y0) + target_x - 15.9, 0);
	
END $$;
