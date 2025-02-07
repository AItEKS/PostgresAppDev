----- create schema -----
CREATE SCHEMA IF NOT EXISTS egor;


----- military_positions table -----
CREATE TABLE IF NOT EXISTS egor.military_positions(
	military_positions_id INTEGER NOT NULL PRIMARY KEY,
	position_name CHARACTER VARYING(100) NOT NULL
);

INSERT INTO egor.military_positions (military_positions_id, position_name) VALUES (1, 'Командир');
INSERT INTO egor.military_positions (military_positions_id, position_name) VALUES (2, 'Заместитель командира');
INSERT INTO egor.military_positions (military_positions_id, position_name) VALUES (3, 'Начальник штаба');
INSERT INTO egor.military_positions (military_positions_id, position_name) VALUES (4, 'Офицер');
INSERT INTO egor.military_positions (military_positions_id, position_name) VALUES (5, 'Сержант');


----- users table -----
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

INSERT INTO egor.users (first_name, last_name, military_positions_id) VALUES ('Иван', 'Иванов', 1);
INSERT INTO egor.users (first_name, last_name, military_positions_id) VALUES ('Петр', 'Петров', 2);
INSERT INTO egor.users (first_name, last_name, military_positions_id) VALUES ('Сергей', 'Сергеев', 3);
INSERT INTO egor.users (first_name, last_name, military_positions_id) VALUES ('Алексей', 'Алексеев', 4);
INSERT INTO egor.users (first_name, last_name, military_positions_id) VALUES ('Дмитрий', 'Дмитриев', 5);


----- measurment_type table -----
CREATE TABLE IF NOT EXISTS egor.measurment_type(
	measurment_type_id INTEGER NOT NULL PRIMARY KEY,
	equip_type CHARACTER VARYING(100) NOT NULL
);

INSERT INTO egor.measurment_type (measurment_type_id, equip_type) VALUES(1, 'ДМК');
INSERT INTO egor.measurment_type (measurment_type_id, equip_type) VALUES(2, 'ВР');


----- measurment_batch table -----
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
VALUES ('2025-01-31 10:20:00', 6.5, 3.5, 1);

INSERT INTO egor.measurment_batch (start_period, position_x, position_y, user_id)
VALUES ('2025-01-31 10:29:00', 7.2, 4.5, 2);


----- measurment_params table -----
CREATE SEQUENCE IF NOT EXISTS egor.measurment_params_seq START 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS egor.measurment_params (
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

INSERT INTO egor.measurment_params (measurment_type_id, measurment_batch_id, height, temperature, pressure, wind_speed, wind_direction, bullet_speed)
VALUES (1, 1, 100, 15, 750, 0, 0, 0);
INSERT INTO egor.measurment_params (measurment_type_id, measurment_batch_id, height, temperature, pressure, wind_speed, wind_direction, bullet_speed)
VALUES (2, 2, 100, 12, 34, 0, 0.2, 45);


----- constant_params_1 table -----
CREATE TABLE IF NOT EXISTS egor.constant_params_1 (
	temperature INTEGER,
	delta NUMERIC(4,2)
);

INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (-1, 0);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (0, 0.5);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (5, 0.5);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (10, 1);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (15, 1);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (20, 1.5);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (25, 2);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (30, 3.5);
INSERT INTO egor.constant_params_1 (temperature, delta) VALUES (40, 4.5);


----- interpolation_params -----
CREATE TYPE egor.interpolation_params AS
(
	x0 numeric(4,2),
	x1 numeric(4,2),
	y0 numeric(4,2),
	y1 numeric(4,2),
	x numeric(4,2)
);

ALTER TYPE egor.interpolation_params
    OWNER TO admin;


SELECT * FROM egor.measurment_type;
