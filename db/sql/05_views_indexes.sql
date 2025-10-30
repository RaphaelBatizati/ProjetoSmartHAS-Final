-- db/sql/05_views_indexes.sql
CREATE OR REPLACE VIEW vw_user_latest_weight AS
SELECT u.user_id, u.full_name,
       ( SELECT sr.value_num FROM sensors s JOIN sensor_reading sr ON sr.sensor_id = s.sensor_id
          WHERE s.user_id = u.user_id AND s.sensor_type = 'SCALE'
          ORDER BY sr.reading_ts DESC FETCH FIRST 1 ROWS ONLY) AS weight_kg
FROM users u;
CREATE INDEX ix_sensor_reading_sensor_ts ON sensor_reading(sensor_id, reading_ts);
CREATE INDEX ix_meal_log_user_dt ON meal_log(user_id, eaten_at);
