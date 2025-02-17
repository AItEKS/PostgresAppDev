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

        INSERT INTO egor.constant_params_1 (temperature, delta) 
		VALUES (-1, 0), (0, 0.5), (5, 0.5), (10, 1), (15, 1), (20, 1.5), (25, 2), (30, 3.5), (40, 4.5);

        RAISE NOTICE 'Table "constant_params_1" created.';
		
    ELSE
        RAISE NOTICE 'Table "constant_params_1" already exists.';
    
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
		IF in_temperature < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'temperature') OR 
		in_temperature > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'temperature') THEN
			RAISE EXCEPTION 'Temperature value is out of range!';
		END IF;
	
		IF in_pressure < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'pressure') OR 
		in_pressure > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'pressure') THEN
			RAISE EXCEPTION 'Pressure value is out of range!';
		END IF;
		
		IF in_wind_direction < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'wind_direction') OR 
		in_wind_direction > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'wind_direction') THEN
			RAISE EXCEPTION 'Wind_direction value is out of range!';
		END IF;
		
		IF in_bullet_speed < (SELECT min_value FROM egor.measure_settings WHERE const_name = 'bullet_speed') OR 
		in_bullet_speed > (SELECT max_value FROM egor.measure_settings WHERE const_name = 'bullet_speed') THEN
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


	----- fn_calculate_meteo_average() -----
	CREATE OR REPLACE FUNCTION egor.fn_calculate_meteo_average(
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
	
	ALTER FUNCTION egor.fn_calculate_meteo_average(egor.input_params)
	    OWNER TO admin;

	
END $$;