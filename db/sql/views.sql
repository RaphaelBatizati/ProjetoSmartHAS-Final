
-- views.sql: helper views & verification queries

CREATE OR REPLACE VIEW V_SENSOR_LATEST AS
SELECT s.sensor_id, s.name, s.type,
       (SELECT MAX(reading_ts) FROM sensor_reading r WHERE r.sensor_id = s.sensor_id) AS last_ts
FROM sensor s;

-- Examples:
-- SELECT F_CALC_AVG_CONSUMPTION(1, 3) FROM dual;
-- SELECT F_FORMAT_ALERT(1, 24) FROM dual;
-- BEGIN P_REGISTER_ALERTS(900, 70); END; /
-- BEGIN P_GENERATE_USER_CONSUMPTION(1, 3); END; /
