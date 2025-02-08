DO $$
DECLARE 
    params egor.interpolation_params;
	target_x numeric := 60;
BEGIN
	IF target_x <= -1 THEN 
		RAISE NOTICE 'Interpolation: %', (SELECT delta FROM egor.constant_params_1 ORDER BY temperature ASC LIMIT 1);
	ELSIF target_x >= 40 THEN
		RAISE NOTICE 'Interpolation: %', (SELECT delta FROM egor.constant_params_1 ORDER BY temperature DESC LIMIT 1);
	ELSE	
		SELECT t1.temperature AS x0, t1.delta AS y0, t2.temperature AS x1, t2.delta AS y1 INTO params
		FROM egor.constant_params_1 t1 
		JOIN egor.constant_params_1 t2 ON t2.temperature > t1.temperature AND t2.delta > t1.delta
		WHERE t1.temperature = (SELECT temperature FROM egor.constant_params_1 WHERE temperature < target_x ORDER BY temperature DESC LIMIT 1) LIMIT 1;
		
		IF param.x0 = param.y0 THEN
			RAISE NOTICE 'Division by zero!';
		ELSE
			RAISE NOTICE 'Interpolation: %', params.y1 + ((params.x1 - params.y1) / (params.x0 - params.y0)) * (target_x - params.y0);
		END IF;
		
	END IF;
	
END $$;
