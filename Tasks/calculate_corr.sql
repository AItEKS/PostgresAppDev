DO $$
DECLARE
  params egor.interpolation_params;
  var_interpolation NUMERIC(4,2); 
  var_temperature NUMERIC(4,2);
  var_max_temperature NUMERIC(4,2);
  var_min_temperature NUMERIC(4,2);

BEGIN
	var_temperature = 15;

	DROP TABLE IF EXISTS temp_constant_params_1;
	DROP SEQUENCE IF EXISTS temp_constant_params_1_seq;
	CREATE TEMPORARY TABLE temp_constant_params_1 AS SELECT * FROM egor.constant_params_1;
	ALTER TABLE temp_constant_params_1 ADD COLUMN id INTEGER;
	CREATE SEQUENCE temp_constant_params_1_seq;
	ALTER TABLE temp_constant_params_1 ALTER COLUMN id SET DEFAULT nextval('temp_constant_params_1_seq');
	UPDATE temp_constant_params_1 SET id = nextval('temp_constant_params_1_seq');

	var_max_temperature = (SELECT MAX(temperature) FROM temp_constant_params_1);
	var_min_temperature = (SELECT MIN(temperature) FROM temp_constant_params_1);

	IF var_temperature < var_min_temperature THEN
		RAISE EXCEPTION 'Value is out of range!';
		
	ELSIF var_temperature > var_max_temperature THEN
		RAISE EXCEPTION 'Value is out of range!';
		
	ELSE
		SELECT temperature, delta, (
			SELECT temperature FROM temp_constant_params_1 
				WHERE temperature >= var_temperature ORDER BY id LIMIT 1) AS temperature1, (
					SELECT delta FROM temp_constant_params_1  
						WHERE temperature >= var_temperature ORDER BY id LIMIT 1) AS delta1
		INTO params.x0, params.y0, params.x1, params.y1
		FROM temp_constant_params_1 AS t1 WHERE temperature <= var_temperature ORDER BY id DESC LIMIT 1;
	
		IF params.x0 = params.x1 THEN
			var_interpolation = params.y0;
			RAISE NOTICE 'Interpolation: %', var_interpolation;
			
		ELSE
			var_interpolation = (params.y0 * params.x1 - params.y1 * params.x0) / (params.x1 - params.x0) + var_temperature * (params.y1 - params.y0) / (params.x1 - params.x0);
			RAISE NOTICE 'Interpolation: %', var_interpolation;
			
		END IF;
		
	END IF;
END$$;
