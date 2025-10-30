-- db/sql/04_plsql_procedures.sql
CREATE OR REPLACE PROCEDURE pr_check_critical_reading(
  p_sensor_id IN NUMBER, p_value IN NUMBER, p_when_ts IN TIMESTAMP, p_alert_id OUT NUMBER
) IS
  v_min sensors.critical_min%TYPE; v_max sensors.critical_max%TYPE; v_unit sensors.unit%TYPE;
  v_type VARCHAR2(20); v_msg VARCHAR2(400); v_reading_id NUMBER;
BEGIN
  p_alert_id := NULL;
  SELECT critical_min, critical_max, unit INTO v_min, v_max, v_unit FROM sensors WHERE sensor_id = p_sensor_id;
  INSERT INTO sensor_reading (sensor_id, value_num, unit, reading_ts)
  VALUES (p_sensor_id, p_value, v_unit, NVL(p_when_ts, SYSTIMESTAMP))
  RETURNING reading_id INTO v_reading_id;
  IF v_min IS NOT NULL AND p_value < v_min THEN
     v_type := 'CRITICAL_MIN'; v_msg := 'Valor abaixo do mínimo: '||p_value||' '||NVL(v_unit,'')||' (min='||v_min||')';
  ELSIF v_max IS NOT NULL AND p_value > v_max THEN
     v_type := 'CRITICAL_MAX'; v_msg := 'Valor acima do máximo: '||p_value||' '||NVL(v_unit,'')||' (max='||v_max||')';
  END IF;
  IF v_type IS NOT NULL THEN
     INSERT INTO alert (sensor_id, reading_id, alert_type, message, severity)
     VALUES (p_sensor_id, v_reading_id, v_type, v_msg, 'HIGH')
     RETURNING alert_id INTO p_alert_id;
  END IF;
  COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20001, 'Sensor inexistente: '||p_sensor_id);
        WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/

CREATE OR REPLACE PROCEDURE pr_user_consumption_report(
  p_user_id IN NUMBER, p_start IN DATE, p_end IN DATE, p_result OUT SYS_REFCURSOR
) IS
BEGIN
  OPEN p_result FOR
    SELECT TRUNC(ml.eaten_at) AS dia,
           ROUND(SUM( (fi.kcal_per_100g/100) * ml.grams ),2) AS total_kcal,
           ROUND(SUM( (fi.protein_g_100g/100) * ml.grams ),2) AS total_protein_g,
           ROUND(SUM( (fi.carbs_g_100g/100) * ml.grams ),2)   AS total_carbs_g,
           ROUND(SUM( (fi.fat_g_100g/100) * ml.grams ),2)     AS total_fat_g
      FROM meal_log ml JOIN food_item fi ON fi.food_id = ml.food_id
     WHERE ml.user_id = p_user_id
       AND TRUNC(ml.eaten_at) BETWEEN TRUNC(p_start) AND TRUNC(p_end)
     GROUP BY TRUNC(ml.eaten_at) ORDER BY dia;
END;
/

CREATE OR REPLACE PROCEDURE pr_scan_readings_and_alert(p_sensor_id IN NUMBER) IS
  CURSOR c_read IS SELECT reading_id, value_num, unit, reading_ts FROM sensor_reading WHERE sensor_id = p_sensor_id ORDER BY reading_ts;
  v_alert_id NUMBER;
BEGIN
  FOR r IN c_read LOOP
    pr_check_critical_reading(p_sensor_id => p_sensor_id, p_value => r.value_num, p_when_ts => r.reading_ts, p_alert_id => v_alert_id);
  END LOOP;
END;
/
