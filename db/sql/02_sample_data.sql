-- db/sql/02_sample_data.sql
INSERT INTO users (full_name, email, birth_date, height_cm) VALUES ('Raphael Batizati', 'raphael@example.com', DATE '2002-05-01', 178.0);
INSERT INTO users (full_name, email, birth_date, height_cm) VALUES ('Maria Silva', 'maria@example.com', DATE '1995-03-15', 165.0);
INSERT INTO sensors (user_id, sensor_type, name, critical_min, critical_max, unit) VALUES (1, 'GLUCOSE', 'Glicosímetro A', 70, 140, 'mg/dL');
INSERT INTO sensors (user_id, sensor_type, name, critical_min, critical_max, unit) VALUES (1, 'SCALE', 'Balança Inteligente', 50, 120, 'kg');
INSERT INTO sensor_reading (sensor_id, value_num, unit, reading_ts) VALUES (1, 95, 'mg/dL', SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO sensor_reading (sensor_id, value_num, unit, reading_ts) VALUES (1, 160, 'mg/dL', SYSTIMESTAMP - INTERVAL '1' HOUR);
INSERT INTO sensor_reading (sensor_id, value_num, unit, reading_ts) VALUES (2, 82.4, 'kg', SYSTIMESTAMP - INTERVAL '3' DAY);
INSERT INTO food_item (name, kcal_per_100g, protein_g_100g, carbs_g_100g, fat_g_100g) VALUES ('Arroz cozido',130,2.4,28.0,0.3);
INSERT INTO food_item (name, kcal_per_100g, protein_g_100g, carbs_g_100g, fat_g_100g) VALUES ('Peito de frango grelhado',165,31.0,0.0,3.6);
INSERT INTO food_item (name, kcal_per_100g, protein_g_100g, carbs_g_100g, fat_g_100g) VALUES ('Feijão cozido',95,6.0,17.0,0.5);
INSERT INTO meal_log (user_id, food_id, grams, eaten_at, note) VALUES (1, 1, 200, SYSTIMESTAMP - INTERVAL '6' HOUR, 'Almoço');
INSERT INTO meal_log (user_id, food_id, grams, eaten_at, note) VALUES (1, 2, 150, SYSTIMESTAMP - INTERVAL '5' HOUR, 'Almoço');
INSERT INTO meal_log (user_id, food_id, grams, eaten_at, note) VALUES (1, 3, 120, SYSTIMESTAMP - INTERVAL '5' HOUR, 'Almoço');
INSERT INTO user_goal (user_id, goal_type, target_value, unit, valid_from) VALUES (1, 'DAILY_CALORIES', 2200, 'kcal', TRUNC(SYSDATE)-7);
COMMIT;
