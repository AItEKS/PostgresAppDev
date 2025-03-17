-- Создание функции триггера
CREATE OR REPLACE FUNCTION public.fn_tr_temp_input_params()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
declare 
	var_check_result public.check_result_type;
	var_input_params public.input_params_type;
	var_response jsonb;
	var_calc_result public.calc_result_type[];
	var_header jsonb;
	var_user_id integer;
	var_meas_input_params_id integer;
begin

	-- Проверяем параметры
	var_check_result := fn_check_input_params(  
				NEW.height,
				NEW.temperature,
				NEW.pressure,
				NEW.wind_direction,
				NEW.wind_speed,
				NEW.bullet_demolition_range
			);

	if var_check_result.is_check = False then
		raise notice 'error %',  var_check_result.error_message;
		NEW.error_message := var_check_result.error_message;
		return NEW;
	else
		INSERT INTO public.employees (name, birthday, military_rank_id) 
    	VALUES (NEW.emploee_name, '2025-02-15', 1)
    	RETURNING id INTO var_user_id;

		INSERT INTO public.measurment_input_params (measurment_type_id, height, temperature, pressure, wind_direction, wind_speed, bullet_demolition_range) 
    	VALUES (NEW.measurment_type_id, NEW.height, NEW.temperature, NEW.pressure, NEW.wind_direction, NEW.wind_speed, NEW.bullet_demolition_range)
    	RETURNING id INTO var_meas_input_params_id;

		INSERT INTO public.measurment_baths (emploee_id, measurment_input_param_id, started)
		VALUES (var_user_id, var_meas_input_params_id, NOW());
	
	end if;

	var_input_params := var_check_result.params;

	-- Формируем заговок
	var_header := public.fn_calc_header_meteo_avg(var_input_params);

	-- Формируем расчет
	call public.sp_calc_corrections(par_input_params => var_input_params, 
		par_measurement_type_id => NEW.measurment_type_id, 
		par_results => var_calc_result);
		
	-- Создаем jsonb объект с header и calc_result
	var_response := jsonb_build_object(
		'header', var_header,
		'calc_result', to_jsonb(var_calc_result)
	);
	
	-- Запоминаем результат
	NEW.calc_result = var_response;
	return NEW;
end;
$BODY$;

-- Создание триггера
CREATE TRIGGER tr_temp_input_params
BEFORE INSERT ON temp_input_params
FOR EACH ROW
EXECUTE FUNCTION fn_tr_temp_input_params();

-- Пример вставки данных
INSERT INTO temp_input_params (
    emploee_name,
    measurment_type_id,
    height,
    temperature,
    pressure,
    wind_direction,
    wind_speed,
    bullet_demolition_range,
    measurment_input_params_id,
    error_message,
    calc_result
)
VALUES (
    'Иванов Иван Иванович',
    1,
    10.50,
    15.00,
    1013.25,
    270.00,
    5.00,
    500.00,
    1,
    NULL,
    '{}'::jsonb
);
