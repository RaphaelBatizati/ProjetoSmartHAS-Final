
-- functions.sql: PL/SQL functions for Smart HAS

-- 1) Indicator: average consumption (kWh) for a sensor in the last N days
-- Assumes POWER_W as instantaneous watt readings hourly; kWh ~ sum(W)/1000 since step=1h
CREATE OR REPLACE FUNCTION F_CALC_AVG_CONSUMPTION (
  P_SENSOR_ID IN NUMBER,
  P_DAYS      IN NUMBER
) RETURN NUMBER IS
  v_avg_kwh NUMBER;
BEGIN
  SELECT AVG(power_w)/1000
    INTO v_avg_kwh
    FROM (
      SELECT sensor_id, TRUNC(reading_ts, 'HH') AS ts_hour, AVG(power_w) AS power_w
      FROM sensor_reading
      WHERE sensor_id = P_SENSOR_ID
        AND reading_ts >= SYSTIMESTAMP - P_DAYS
      GROUP BY sensor_id, TRUNC(reading_ts, 'HH')
    );
  RETURN NVL(v_avg_kwh, 0);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    -- log as needed
    RETURN NULL;
END;
/
SHOW ERRORS;


-- 2) Formatted data: return a concise JSON string with latest reading summary
CREATE OR REPLACE FUNCTION F_FORMAT_ALERT (
  P_SENSOR_ID IN NUMBER,
  P_HOURS     IN NUMBER
) RETURN VARCHAR2 IS
  v_min NUMBER; v_max NUMBER; v_avg NUMBER;
  v_type VARCHAR2(50); v_name VARCHAR2(100);
  v_json VARCHAR2(4000);
BEGIN
  SELECT s.type, s.name INTO v_type, v_name FROM sensor s WHERE s.sensor_id = P_SENSOR_ID;

  SELECT MIN(NVL(power_w, NVL(temp_c, 0))),
         MAX(NVL(power_w, NVL(temp_c, 0))),
         AVG(NVL(power_w, NVL(temp_c, 0)))
    INTO v_min, v_max, v_avg
    FROM sensor_reading r
    WHERE r.sensor_id = P_SENSOR_ID
      AND r.reading_ts >= SYSTIMESTAMP - (P_HOURS/24);

  v_json := '{' ||
    '"sensorId":'||P_SENSOR_ID||',' ||
    '"sensorName":"'||v_name||'",' ||
    '"type":"'||v_type||'",' ||
    '"windowHours":'||P_HOURS||',' ||
    '"min":'||NVL(v_min,0)||',' ||
    '"max":'||NVL(v_max,0)||',' ||
    '"avg":'||NVL(v_avg,0) ||
    '}';

  RETURN v_json;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN '{"error":"sensor not found or no data"}';
  WHEN OTHERS THEN
    RETURN '{"error":"unexpected"}';
END;
/
SHOW ERRORS;
