DO $$
DECLARE
  user_id_counter INTEGER;
  measurement_counter INTEGER;
  new_batch_id INTEGER;

BEGIN
  INSERT INTO egor.users (first_name, last_name, military_positions_id)
  VALUES
  ('Анна', 'Александрова', 1),
  ('Елена', 'Егорова', 2),
  ('Мария', 'Иванова', 3),
  ('Ольга', 'Петрова', 4),
  ('Светлана', 'Сидорова', 5);

  FOR user_id_counter IN (SELECT user_id FROM egor.users) LOOP
    measurement_counter := 0; 
    WHILE measurement_counter < 100 LOOP
      INSERT INTO egor.measurment_batch (start_period, position_x, position_y, user_id)
      VALUES (now() - INTERVAL '1 day' * measurement_counter,  random() * 10, random() * 10, user_id_counter)
      RETURNING measurment_batch_id INTO new_batch_id;

      INSERT INTO egor.measurment_params (measurment_type_id, measurment_batch_id, height, temperature, pressure, wind_speed, wind_direction, bullet_speed)
      VALUES (1 + (measurement_counter % 2), new_batch_id,
              (floor(random() * 300) - 100)::INTEGER,
              (floor(random() * 116) - 58)::NUMERIC(4,2),
              (floor(random() * 401) + 500)::INTEGER,
              (floor(random() * 16))::INTEGER,
              (floor(random() * 60))::INTEGER,
              (floor(random() * 151))::INTEGER);
      
      measurement_counter := measurement_counter + 1;
    END LOOP;
  END LOOP;
  
END $$;