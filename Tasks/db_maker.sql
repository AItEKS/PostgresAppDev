DO $$
BEGIN
	----- drop full scheme -----
	DROP SCHEMA IF EXISTS egor CASCADE;

	
	----- create schema "egor" -----
	IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'egor') THEN 
		CREATE SCHEMA egor;
		RAISE NOTICE 'Schema "egor" created.';
	ELSE 
		RAISE NOTICE 'Schema "egor" already exists.';
	END IF;

	
	----- military_positions table ----- 
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'military_positions') THEN
		CREATE TABLE IF NOT EXISTS egor.military_positions(
			military_positions_id INTEGER NOT NULL PRIMARY KEY,
			position_name CHARACTER VARYING(100) NOT NULL
		);
		
		INSERT INTO egor.military_positions (military_positions_id, position_name) 
		VALUES (1, 'Командир'), (2, 'Заместитель командира'), (3, 'Начальник штаба'), (4, 'Офицер'), (5, 'Сержант');
		
		RAISE NOTICE 'Table "military_positions" created.';
		
	ELSE 
		RAISE NOTICE 'Table "military_positions" already exists.';
		
	END IF;

	
	----- users table -----
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'users') THEN
	    CREATE SEQUENCE IF NOT EXISTS egor.users_seq START 1 INCREMENT BY 1;

		CREATE TABLE IF NOT EXISTS egor.users (
		    user_id INTEGER NOT NULL DEFAULT nextval('egor.users_seq') PRIMARY KEY,
		    first_name CHARACTER VARYING(100) NOT NULL,
		    last_name CHARACTER VARYING(100) NOT NULL,
		    military_positions_id INTEGER NOT NULL,
		    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
		
			CONSTRAINT military_positions_id_constraint FOREIGN KEY (military_positions_id)
				REFERENCES egor.military_positions (military_positions_id)
		);

		CREATE INDEX IF NOT EXISTS idx_users_military_positions_id ON egor.users (military_positions_id);


		INSERT INTO egor.users (first_name, last_name, military_positions_id) 
		VALUES ('Иван', 'Иванов', 1), ('Петр', 'Петров', 2), ('Сергей', 'Сергеев', 3), ('Алексей', 'Алексеев', 4), ('Дмитрий', 'Дмитриев', 5);
		
		RAISE NOTICE 'Table "users" created.';

	ELSE 
		RAISE NOTICE 'Table "users" already exists.';

	END IF;
	

	----- measurment_type table -----
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'measurment_type') THEN
		CREATE TABLE IF NOT EXISTS egor.measurment_type(
			measurment_type_id INTEGER NOT NULL PRIMARY KEY,
			equip_type CHARACTER VARYING(100) NOT NULL
		);

		INSERT INTO egor.measurment_type (measurment_type_id, equip_type)
		VALUES (1, 'ДМК'), (2, 'ВР');

		RAISE NOTICE 'Table "measurment_type" created.';

	ELSE 
		RAISE NOTICE 'Table "measurment_type" already exists.';

	END IF;


	----- measurment_batch table -----
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'measurment_batch') THEN
		CREATE SEQUENCE IF NOT EXISTS egor.measurment_batch_seq START 1 INCREMENT BY 1;
  
		CREATE TABLE IF NOT EXISTS egor.measurment_batch (
		    measurment_batch_id INTEGER NOT NULL DEFAULT nextval('egor.measurment_batch_seq') PRIMARY KEY,
		    start_period TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
		    position_x NUMERIC(3,2),
		    position_y NUMERIC(3,2),
		    user_id INTEGER NOT NULL,
		
			CONSTRAINT user_id_constraint FOREIGN KEY (user_id)
				REFERENCES egor.users (user_id)
		);

		CREATE INDEX IF NOT EXISTS idx_measurment_batch_user_id ON egor.measurment_batch (user_id);


		INSERT INTO egor.measurment_batch (start_period, position_x, position_y, user_id)
		VALUES ('2025-01-31 10:20:00', 6.5, 3.5, 1), ('2025-01-31 10:29:00', 7.2, 4.5, 2);

		RAISE NOTICE 'Table "measurment_batch" created.';

	ELSE 
		RAISE NOTICE 'Table "measurment_batch" already exists.';

	END IF;


	----- measurment_params table -----
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'measurment_params') THEN
    	CREATE SEQUENCE IF NOT EXISTS egor.measurment_params_seq START 1 INCREMENT BY 1;

	    CREATE TABLE egor.measurment_params (
	        measurment_params_id INTEGER NOT NULL DEFAULT nextval('egor.measurment_params_seq') PRIMARY KEY,
	        measurment_type_id INTEGER NOT NULL,
	        measurment_batch_id INTEGER NOT NULL,
	        height NUMERIC(8,2),
	        temperature NUMERIC(8,2),
	        pressure NUMERIC(8,2),
	        wind_speed NUMERIC(8,2),
	        wind_direction NUMERIC(8,2),
	        bullet_speed NUMERIC(8,2),
	
	        CONSTRAINT measurment_type_id_constraint FOREIGN KEY (measurment_type_id)
	            REFERENCES egor.measurment_type (measurment_type_id),
	        CONSTRAINT measurment_batch_id_constraint FOREIGN KEY (measurment_batch_id)
	            REFERENCES egor.measurment_batch (measurment_batch_id)
	    );

		CREATE INDEX IF NOT EXISTS idx_measurment_params_measurment_type_id ON egor.measurment_params (measurment_type_id);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_measurment_batch_id ON egor.measurment_params (measurment_batch_id);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_height ON egor.measurment_params (height);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_temperature ON egor.measurment_params (temperature);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_pressure ON egor.measurment_params (pressure);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_wind_speed ON egor.measurment_params (wind_speed);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_wind_direction ON egor.measurment_params (wind_direction);
		CREATE INDEX IF NOT EXISTS idx_measurment_params_bullet_speed ON egor.measurment_params (bullet_speed);


    	RAISE NOTICE 'Table "measurment_params" created.';
	
	ELSE
    	RAISE NOTICE 'Table "measurment_params" already exists.';
  
	END IF;
  

	----- measure_settings table -----
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'measure_settings') THEN
		CREATE TABLE egor.measure_settings (
			const_name CHARACTER VARYING(100),
            min_value NUMERIC(8,2),
            max_value NUMERIC(8,2),
			units CHARACTER VARYING(100)
        );

		CREATE INDEX IF NOT EXISTS idx_measure_settings_const_name ON egor.measure_settings (const_name);

        INSERT INTO egor.measure_settings (const_name, min_value, max_value, units) 
		VALUES ('temperature', -58, 58, '°C'), ('pressure', 500, 900, 'mmHg'), ('wind_direction', 0, 59, ''), 
			   ('wind_speed', 0, 15, 'm/s'), ('bullet_speed', 0, 150, 'm'), ('H', 750, 750, 'mmHg'), ('T', 15.9, 15.9, '°C');

        RAISE NOTICE 'Table "measure_settings" created.';
		
    ELSE
        RAISE NOTICE 'Table "measure_settings" already exists.';
    
	END IF;
	
	
	----- constant_params_1 table -----
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'constant_params_1') THEN
		CREATE TABLE egor.constant_params_1 (
            temperature NUMERIC(4,2),
            delta NUMERIC(4,2)
        );

		CREATE INDEX IF NOT EXISTS idx_constant_params_1_temperature ON egor.constant_params_1 (temperature);

        INSERT INTO egor.constant_params_1 (temperature, delta) 
		VALUES (-1, 0), (0, 0.5), (5, 0.5), (10, 1), (15, 1), (20, 1.5), (25, 2), (30, 3.5), (40, 4.5);

        RAISE NOTICE 'Table "constant_params_1" created.';
		
    ELSE
        RAISE NOTICE 'Table "constant_params_1" already exists.';
    
	END IF;


	----- constant_params_2 table -----
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'constant_params_2') THEN
		CREATE SEQUENCE IF NOT EXISTS egor.constant_params_2_seq START 1 INCREMENT BY 1;
		
		CREATE TABLE egor.constant_params_2 (
		    id INTEGER NOT NULL DEFAULT nextval('egor.constant_params_2_seq'::regclass),
		    height INTEGER NOT NULL,
		    is_positive BOOLEAN NOT NULL,
		    const_values INTEGER[] NOT NULL
        );

		CREATE INDEX IF NOT EXISTS idx_constant_params_2_height ON egor.constant_params_2 (height);
		CREATE INDEX IF NOT EXISTS idx_constant_params_2_is_positive ON egor.constant_params_2 (is_positive);


        INSERT INTO egor.constant_params_2 (height, is_positive, const_values) 
		VALUES (200, FALSE, ARRAY[-1, -2, -3, -4, -5, -6, -7, -8, -9, -20, -29, -39, -49]), 
				(200, TRUE , ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(400, FALSE, ARRAY[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -38, -48]),
				(400, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), 
				(800, FALSE, ARRAY[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),
				(800, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(1200, FALSE, ARRAY[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),
				(1200, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(1600, FALSE, ARRAY[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]),
				(1600, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(2000, FALSE, ARRAY[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),
				(2000, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(2400, FALSE, ARRAY[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),
				(2400, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(3000, FALSE, ARRAY[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),
				(3000, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
				(4000, FALSE, ARRAY[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]),
				(4000, TRUE, ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]);

        RAISE NOTICE 'Table "constant_params_2" created.';
		
    ELSE
        RAISE NOTICE 'Table "constant_params_2" already exists.';
    
	END IF;


	-- Создание таблицы height_alphay
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'height_alphay') THEN
		CREATE TABLE egor.height_alphay (
			height INTEGER NOT NULL PRIMARY KEY,
			alphay NUMERIC(4, 2) NOT NULL
		);

		INSERT INTO egor.height_alphay (height, alphay)
		VALUES 
			(200, 1), 
			(400, 2), 
			(800, 3), 
			(1200, 3), 
			(1600, 4), 
			(2000, 4), 
			(2400, 4), 
			(3000, 5), 
			(4000, 5);

		RAISE NOTICE 'Table "height_alphay" created.';
	ELSE
		RAISE NOTICE 'Table "height_alphay" already exists.';
	END IF;

	-- Создание таблицы constant_params_3_dmk
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'constant_params_3_dmk') THEN
		CREATE SEQUENCE IF NOT EXISTS egor.constant_params_3_dmk_seq START 1 INCREMENT BY 1;

		CREATE TABLE egor.constant_params_3_dmk (
			id INTEGER NOT NULL DEFAULT nextval('egor.constant_params_3_dmk_seq'::regclass),
			height INTEGER NOT NULL,
			const_values INTEGER[] NOT NULL,
			CONSTRAINT fk_height_dmk FOREIGN KEY (height) REFERENCES egor.height_alphay(height)
		);

		CREATE INDEX IF NOT EXISTS idx_constant_params_3_dmk_height ON egor.constant_params_3_dmk (height);

		INSERT INTO egor.constant_params_3_dmk (height, const_values)
		VALUES 
			(200, ARRAY[4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22]),
			(400, ARRAY[5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25, 27]),
			(800, ARRAY[5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27, 28]),
			(1200, ARRAY[5, 8, 11, 12, 13, 16, 19, 20, 22, 24, 26, 28, 30]),
			(1600, ARRAY[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]),
			(2000, ARRAY[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]),
			(2400, ARRAY[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]),
			(3000, ARRAY[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]),
			(4000, ARRAY[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]);

		RAISE NOTICE 'Table "constant_params_3_dmk" created.';
	ELSE
		RAISE NOTICE 'Table "constant_params_3_dmk" already exists.';
	END IF;

	-- Создание таблицы constant_params_3_bp
	IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'egor' AND tablename = 'constant_params_3_bp') THEN
		CREATE SEQUENCE IF NOT EXISTS egor.constant_params_3_bp_seq START 1 INCREMENT BY 1;

		CREATE TABLE egor.constant_params_3_bp (
			id INTEGER NOT NULL DEFAULT nextval('egor.constant_params_3_bp_seq'::regclass),
			height INTEGER NOT NULL,
			const_values INTEGER[] NOT NULL,
			CONSTRAINT fk_height_bp FOREIGN KEY (height) REFERENCES egor.height_alphay(height)
		);

		CREATE INDEX IF NOT EXISTS idx_constant_params_3_bp_height ON egor.constant_params_3_bp (height);

		INSERT INTO egor.constant_params_3_bp (height, const_values)
		VALUES 
			(200, ARRAY[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]),
			(400, ARRAY[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
			(800, ARRAY[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]),
			(1200, ARRAY[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]),
			(1600, ARRAY[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]),
			(2000, ARRAY[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]),
			(2400, ARRAY[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]),
			(3000, ARRAY[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]),
			(4000, ARRAY[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]);

		RAISE NOTICE 'Table "constant_params_3_bp" created.';
	ELSE
		RAISE NOTICE 'Table "constant_params_3_bp" already exists.';
	END IF;
	
	
	----- interpolation_params -----
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'interpolation_params') THEN
        CREATE TYPE egor.interpolation_params AS
        (
            x0 NUMERIC(4,2),
            x1 NUMERIC(4,2),
            y0 NUMERIC(4,2),
            y1 NUMERIC(4,2),
            x NUMERIC(4,2)
        );

        RAISE NOTICE 'Type "interpolation_params" created.';
		
    ELSE
        RAISE NOTICE 'Type "interpolation_params" already exists.';
		
    END IF;


	----- user input_params -----
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'input_params') THEN
        CREATE TYPE egor.input_params AS
        (
            us_height NUMERIC(8,2),
            us_temperature NUMERIC(8,2),
            us_pressure NUMERIC(8,2),
            us_wind_direction NUMERIC(8,2),
            us_bullet_speed NUMERIC(8,2)
        );

        RAISE NOTICE 'Type "input_params" created.';
		
    ELSE
        RAISE NOTICE 'Type "input_params" already exists.';
		
    END IF;


---------- functions ----------


	----- fn_calculate_interpolation() -----
	CREATE OR REPLACE FUNCTION egor.fn_calculate_interpolation(var_temperature NUMERIC(4, 2))
	RETURNS NUMERIC(4, 2)
	LANGUAGE 'plpgsql'
	AS $BODY$
	DECLARE
		params egor.interpolation_params;
	  	var_interpolation NUMERIC(4,2);
	  	var_max_temperature NUMERIC(4,2);
	  	var_min_temperature NUMERIC(4,2);
	
	BEGIN
	  	SELECT MAX(temperature), MIN(temperature)
	  	INTO var_max_temperature, var_min_temperature
	  	FROM egor.constant_params_1;
	
		IF var_temperature >= var_max_temperature AND var_temperature <= (SELECT max_value FROM egor.measure_settings WHERE const_name = 'temperature') THEN
			var_interpolation :=  (SELECT MAX(delta) FROM egor.constant_params_1);
			RAISE NOTICE 'max';
			RETURN var_interpolation;
		END IF;
		
		IF var_temperature <= var_min_temperature AND var_temperature >= (SELECT min_value FROM egor.measure_settings WHERE const_name = 'temperature') THEN
			var_interpolation :=  (SELECT MIN(delta) FROM egor.constant_params_1);
			RETURN var_interpolation;
		END IF;
		
		IF var_max_temperature IS NULL OR var_min_temperature IS NULL THEN
	    	RAISE EXCEPTION 'Table "constant_params_1" is empty, cannot perform interpolation.';
	 	END IF;
	
	  	IF var_temperature < var_min_temperature OR var_temperature > var_max_temperature THEN
	    	RAISE EXCEPTION 'Input temperature % is out of range [%, %]!', var_temperature, var_min_temperature, var_max_temperature;
	  	END IF;
	
	  	SELECT t1.temperature, t1.delta, t2.temperature, t2.delta
	  	INTO params.x0, params.y0, params.x1, params.y1
		  
	  	FROM egor.constant_params_1 t1
	  	JOIN egor.constant_params_1 t2 ON t2.temperature = (SELECT MIN(temperature) FROM egor.constant_params_1 WHERE temperature >= var_temperature)
	  	WHERE t1.temperature = (SELECT MAX(temperature) FROM egor.constant_params_1 WHERE temperature <= var_temperature);
	
	  	IF params.x0 = params.x1 THEN
	    	var_interpolation := params.y0;
	  
	 	ELSE
	    	var_interpolation := (params.y0 * params.x1 - params.y1 * params.x0) / (params.x1 - params.x0) + var_temperature * (params.y1 - params.y0) / (params.x1 - params.x0);
	  
	  	END IF;
	
	  	RETURN var_interpolation;
		  
	END;
	$BODY$;


	----- fn_get_input_params() -----
	CREATE OR REPLACE FUNCTION egor.fn_get_input_params(in_height NUMERIC(8, 2), in_temperature NUMERIC(8, 2), 
													 in_pressure NUMERIC(8, 2), in_wind_direction NUMERIC(8, 2), 
													 in_bullet_speed NUMERIC(8, 2))
    RETURNS egor.input_params
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
	AS $BODY$
	DECLARE
		in_params egor.input_params;
	
	BEGIN
		IF in_height IS NULL THEN
			RAISE EXCEPTION 'Height value is out of range!';
		END IF;
	
		IF in_temperature < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'temperature') OR 
		in_temperature > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'temperature') OR in_temperature IS NULL THEN
			RAISE EXCEPTION 'Temperature value is out of range!';
		END IF;
	
		IF in_pressure < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'pressure') OR 
		in_pressure > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'pressure') OR in_pressure IS NULL THEN
			RAISE EXCEPTION 'Pressure value is out of range!';
		END IF;
		
		IF in_wind_direction < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'wind_direction') OR 
		in_wind_direction > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'wind_direction')  OR in_wind_direction IS NULL THEN
			RAISE EXCEPTION 'Wind_direction value is out of range!';
		END IF;
		
		IF in_bullet_speed < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'bullet_speed') OR 
		in_bullet_speed > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'bullet_speed') OR in_bullet_speed IS NULL THEN
			RAISE EXCEPTION 'Bullet_speed value is out of range!';
		END IF;
		
	    in_params.us_height := in_height;
		in_params.us_temperature := in_temperature;
	    in_params.us_pressure := in_pressure;
	    in_params.us_wind_direction := in_wind_direction;
	    in_params.us_bullet_speed := in_bullet_speed;
	
	    RETURN in_params;
		
	END;
	$BODY$;


	----- fn_has_error() -----
	CREATE OR REPLACE FUNCTION egor.fn_has_error(in_height NUMERIC(8, 2), in_temperature NUMERIC(8, 2), 
													 in_pressure NUMERIC(8, 2), in_wind_direction NUMERIC(8, 2), 
													 in_bullet_speed NUMERIC(8, 2))
	RETURNS BOOLEAN
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE PARALLEL UNSAFE
	AS $BODY$
	DECLARE
	    input_params egor.input_params;
	BEGIN
	    BEGIN
	        input_params := egor.fn_get_input_params(in_height, in_temperature, in_pressure, in_wind_direction, in_bullet_speed);
	        RETURN FALSE;
	    EXCEPTION
	        WHEN OTHERS THEN
	            RAISE NOTICE 'Exception caught!';
	            RETURN TRUE;
	    END;
	END;
	$BODY$;
	
	
	------ fn_get_date() ------
	CREATE OR REPLACE FUNCTION egor.fn_get_date()
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
	AS $BODY$
	BEGIN
		RETURN (SELECT SUBSTRING(now()::text, 6, 2) || SUBSTRING(now()::text, 12, 2) || SUBSTRING(now()::text, 15, 1));
	END;
	$BODY$;
	
	ALTER FUNCTION egor.fn_get_date()
	    OWNER TO admin;


	----- fn_calculate_meteo_approximate() -----
	CREATE OR REPLACE FUNCTION egor.fn_calculate_meteo_approximate(
	in_params egor.input_params)
    RETURNS text[]
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
	AS $BODY$
	DECLARE 
		results text[3];
		pressure text;
		temperature text;
		height text;
		
	BEGIN
		results[0] = egor.fn_get_date();
		
		height = ROUND(in_params.us_height)::TEXT;
		CASE
	        WHEN LENGTH(height) = 3 THEN
	            height = '0' || height;
	
			WHEN LENGTH(height) = 2 THEN
	            height = '00' || height;
	
	        WHEN LENGTH(height) = 1 THEN
	            height = '000' || height;
	
	        ELSE
	            height = '0000';
				
	    END CASE;
	
		results[1] = height;
	
		pressure = ROUND(in_params.us_pressure - (SELECT min_value FROM egor.measure_settings WHERE const_name = 'H'))::TEXT;
	    CASE
	        WHEN LENGTH(pressure) = 2 AND SUBSTRING(pressure, 1, 1) != '-' THEN
	            pressure = '0' || pressure;
	
			WHEN LENGTH(pressure) = 2 AND SUBSTRING(pressure, 1, 1) = '-' THEN
	            pressure = '5' || SUBSTRING(pressure, 2);
	
	        WHEN LENGTH(pressure) = 1 AND SUBSTRING(pressure, 1, 1) != '-' THEN
	            pressure = '00' || pressure;
	
			WHEN LENGTH(pressure) = 1 AND SUBSTRING(pressure, 1, 1) = '-' THEN
	            pressure = '50' || SUBSTRING(pressure, 2);
	
	        ELSE
	            pressure = '000';
				
	    END CASE;
		
		temperature = ROUND(in_params.us_temperature + egor.fn_calculate_interpolation(in_params.us_temperature) - (SELECT min_value FROM egor.measure_settings WHERE const_name = 'T'))::TEXT;
		CASE
	        WHEN LENGTH(temperature) = 1 THEN
	            temperature = '0' || temperature;
			ELSE temperature = temperature;
				
	    END CASE;
		
		results[2] = pressure||temperature;
		
		RETURN results;
	END;
	$BODY$;
	
	ALTER FUNCTION egor.fn_calculate_meteo_approximate(egor.input_params)
	    OWNER TO admin;


---------- procedures ----------


	------ pd_get_avg_air_deviation() ------
	CREATE OR REPLACE PROCEDURE egor.pd_get_avg_air_deviation(
	    var_temperature NUMERIC(4, 2),
	    OUT result_array INTEGER[]
	)
	LANGUAGE 'plpgsql'
	AS $BODY$
	DECLARE
	    var_interpolation INTEGER := ROUND(egor.fn_calculate_interpolation(var_temperature));
	    approximate_temperature INTEGER := ROUND(var_interpolation + var_temperature - (SELECT min_value FROM egor.measure_settings WHERE const_name = 'T'))::INTEGER;
	    dozens INTEGER := (approximate_temperature / 10)::INTEGER;
	    units INTEGER := MOD(approximate_temperature, 10);
	
	    element_h INTEGER;
	    current_result NUMERIC;
	    array_index INTEGER := 1;
	    array_length INTEGER := (SELECT COUNT(DISTINCT height) FROM egor.constant_params_2);
	
	BEGIN
	    result_array := ARRAY[NULL::NUMERIC];
	    result_array := array_fill(NULL::NUMERIC, ARRAY[array_length]);
	    
	    FOR element_h IN SELECT DISTINCT height FROM egor.constant_params_2 ORDER BY height LOOP
	        IF dozens = 0 THEN
	            IF approximate_temperature < 0 THEN
	                current_result := (SELECT const_values[ABS(units)] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=FALSE) + 50;
	            ELSE
	                current_result := (SELECT const_values[units] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=TRUE);
	            END IF;
	
	        ELSIF units = 0 THEN
	            IF approximate_temperature < 0 THEN
	                current_result := (SELECT const_values[10+dozens] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=FALSE) + 50;
	            ELSE
	                current_result := (SELECT const_values[10+dozens] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=TRUE);
	            END IF;
	
	        ELSIF dozens < 0 THEN
	            current_result := ((SELECT const_values[ABS(units)] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=FALSE) +
	                                 (SELECT const_values[ABS(dozens)] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=FALSE));
	
	        ELSE
	            current_result := ((SELECT const_values[units] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=TRUE) +
	                                 (SELECT const_values[dozens] FROM egor.constant_params_2 WHERE height=element_h AND is_positive=TRUE));
	        END IF;
	
	        result_array[array_index] := current_result;
	        array_index := array_index + 1;
	    END LOOP;
	END;
	$BODY$;


	------ pd_get_avg_air_speed() ------
	CREATE OR REPLACE PROCEDURE egor.pd_get_avg_air_speed(
		var_speed NUMERIC(4, 2),
		measurement_type INTEGER,
		OUT result_array1 INTEGER[],
		OUT result_array2 NUMERIC[]
	)
	LANGUAGE 'plpgsql'
	AS $BODY$
	DECLARE
		row_data RECORD;
		index_value INTEGER;
		min_val INTEGER;
		max_val INTEGER;
		coeff NUMERIC(4, 2);
		table_name TEXT;
	BEGIN
		IF measurement_type = 1 THEN
			min_val := 3;
			max_val := 15;
			table_name := 'constant_params_3_dmk';
			coeff := 1;
		ELSE
			min_val := 40;
			max_val := 150;
			table_name := 'constant_params_3_bp';
			coeff := 10;
		END IF;

		IF var_speed < min_val THEN
			result_array1 := ARRAY[0, 0, 0, 0, 0, 0, 0, 0];
			result_array2 := ARRAY[0, 0, 0, 0, 0, 0, 0, 0];
		ELSIF var_speed BETWEEN min_val AND max_val THEN
			result_array1 := ARRAY[]::INTEGER[];
			result_array2 := ARRAY[]::NUMERIC[];
			FOR row_data IN EXECUTE format('
				SELECT cp.height, cp.const_values, ha.alphay 
				FROM egor.%I cp 
				JOIN egor.height_alphay ha ON cp.height = ha.height 
				ORDER BY cp.height', table_name)
			LOOP
				index_value := ROUND((var_speed - min_val) / coeff);

				IF index_value >= 0 AND index_value < array_length(row_data.const_values, 1) THEN
					result_array1 := array_append(result_array1, row_data.const_values[index_value + 1]); 
				ELSE
					result_array1 := array_append(result_array1, NULL);
				END IF;
				result_array2 := array_append(result_array2, var_speed + row_data.alphay);
			END LOOP;
		ELSE
			result_array1 := ARRAY[]::INTEGER[];
			result_array2 := ARRAY[]::NUMERIC[];
			FOR row_data IN EXECUTE format('
				SELECT cp.height, cp.const_values, ha.alphay 
				FROM egor.%I cp 
				JOIN egor.height_alphay ha ON cp.height = ha.height 
				ORDER BY cp.height', table_name)
			LOOP
				result_array1 := array_append(result_array1, (SELECT MAX(value) FROM unnest(row_data.const_values) AS value));
				result_array2 := array_append(result_array2, var_speed + row_data.alphay);
			END LOOP;
		END IF;
	END;
	$BODY$;


	
END $$;