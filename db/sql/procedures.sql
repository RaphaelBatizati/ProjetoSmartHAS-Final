
-- procedures.sql: PL/SQL procedures for Smart HAS

-- A) Register alerts when thresholds exceeded (POWER or TEMP)
CREATE OR REPLACE PROCEDURE P_REGISTER_ALERTS (
  P_POWER_THRESHOLD IN NUMBER DEFAULT 1000,
  P_TEMP_THRESHOLD  IN NUMBER DEFAULT 75
) IS
BEGIN
  -- Power alerts
  INSERT INTO alert (sensor_id, alert_ts, level, message, meta_json)
  SELECT r.sensor_id, SYSTIMESTAMP, 'WARN',
         'High power usage', F_FORMAT_ALERT(r.sensor_id, 24)
  FROM sensor_reading r
  JOIN sensor s ON s.sensor_id = r.sensor_id
  WHERE s.type = 'POWER'
    AND r.reading_ts >= SYSTIMESTAMP - 1/24
    AND NVL(r.power_w,0) > P_POWER_THRESHOLD;

  -- Temperature alerts
  INSERT INTO alert (sensor_id, alert_ts, level, message, meta_json)
  SELECT r.sensor_id, SYSTIMESTAMP, 'CRITICAL',
         'High temperature', F_FORMAT_ALERT(r.sensor_id, 6)
  FROM sensor_reading r
  JOIN sensor s ON s.sensor_id = r.sensor_id
  WHERE s.type = 'TEMP'
    AND r.reading_ts >= SYSTIMESTAMP - 1/24
    AND NVL(r.temp_c,0) > P_TEMP_THRESHOLD;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
SHOW ERRORS;


-- B) Generate consumption summary per user into CONSUMPTION_SUMMARY
CREATE OR REPLACE PROCEDURE P_GENERATE_USER_CONSUMPTION (
  P_USER_ID IN NUMBER,
  P_DAYS    IN NUMBER
) IS
  v_from_ts TIMESTAMP := SYSTIMESTAMP - P_DAYS;
  v_to_ts   TIMESTAMP := SYSTIMESTAMP;
  v_total_kwh NUMBER;
  v_avg_power NUMBER;
BEGIN
  -- Compute power summaries for all sensors of the user
  SELECT NVL(SUM(hour_avg)/1000,0), NVL(AVG(hour_avg),0)
    INTO v_total_kwh, v_avg_power
    FROM (
      SELECT AVG(r.power_w) AS hour_avg
      FROM sensor s
      JOIN sensor_reading r ON r.sensor_id = s.sensor_id
      WHERE s.user_id = P_USER_ID
        AND r.reading_ts >= v_from_ts
        AND r.reading_ts <= v_to_ts
      GROUP BY TRUNC(r.reading_ts,'HH')
    );

  INSERT INTO consumption_summary (user_id, from_ts, to_ts, total_kwh, avg_power_w)
  VALUES (P_USER_ID, v_from_ts, v_to_ts, v_total_kwh, v_avg_power);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
SHOW ERRORS;


-- C) Example procedure using CURSOR to upsert (simple) sensor by name for a user
CREATE OR REPLACE PROCEDURE P_UPSERT_SENSOR (
  P_USER_ID IN NUMBER,
  P_NAME    IN VARCHAR2,
  P_TYPE    IN VARCHAR2,
  P_LOCATION IN VARCHAR2,
  P_SENSOR_ID OUT NUMBER
) IS
  CURSOR c IS SELECT sensor_id FROM sensor WHERE user_id = P_USER_ID AND name = P_NAME FOR UPDATE;
  v_id NUMBER;
BEGIN
  OPEN c;
  FETCH c INTO v_id;
  IF c%FOUND THEN
    -- Update
    UPDATE sensor SET type = P_TYPE, location = P_LOCATION WHERE sensor_id = v_id;
    P_SENSOR_ID := v_id;
  ELSE
    -- Insert
    INSERT INTO sensor (user_id, name, type, location) VALUES (P_USER_ID, P_NAME, P_TYPE, P_LOCATION)
    RETURNING sensor_id INTO P_SENSOR_ID;
  END IF;
  CLOSE c;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
SHOW ERRORS;
