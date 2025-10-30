-- db/sql/03_plsql_functions.sql
CREATE OR REPLACE FUNCTION fn_daily_calories(p_user_id IN NUMBER, p_day IN DATE) RETURN NUMBER IS
  v_total NUMBER := 0;
BEGIN
  SELECT NVL(SUM( (fi.kcal_per_100g/100) * ml.grams ), 0)
    INTO v_total
    FROM meal_log ml JOIN food_item fi ON fi.food_id = ml.food_id
   WHERE ml.user_id = p_user_id AND TRUNC(ml.eaten_at) = TRUNC(p_day);
  RETURN v_total;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 0; WHEN OTHERS THEN RETURN NULL; END;
/

CREATE OR REPLACE FUNCTION fn_user_bmi(p_user_id IN NUMBER) RETURN NUMBER IS
  v_height_cm users.height_cm%TYPE; v_weight_kg NUMBER; v_bmi NUMBER;
BEGIN
  SELECT height_cm INTO v_height_cm FROM users WHERE user_id = p_user_id;
  SELECT sr.value_num INTO v_weight_kg
    FROM sensors s JOIN sensor_reading sr ON sr.sensor_id = s.sensor_id
   WHERE s.user_id = p_user_id AND s.sensor_type = 'SCALE'
   ORDER BY sr.reading_ts DESC FETCH FIRST 1 ROWS ONLY;
  IF v_height_cm IS NULL OR v_height_cm = 0 THEN RETURN NULL; END IF;
  v_bmi := v_weight_kg / POWER(v_height_cm/100, 2);
  RETURN ROUND(v_bmi, 2);
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL; WHEN OTHERS THEN RETURN NULL; END;
/

CREATE OR REPLACE FUNCTION fn_user_bmi_summary(p_user_id IN NUMBER) RETURN VARCHAR2 IS
  v_bmi NUMBER; v_name users.full_name%TYPE; v_msg VARCHAR2(300);
BEGIN
  v_bmi := fn_user_bmi(p_user_id); SELECT full_name INTO v_name FROM users WHERE user_id = p_user_id;
  IF v_bmi IS NULL THEN v_msg := 'BMI indisponível para '||v_name||' (altura/peso ausentes).';
  ELSE v_msg := 'Usuário '||v_name||' possui BMI = '||TO_CHAR(v_bmi,'FM9990.00'); END IF;
  RETURN v_msg;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Usuário inexistente.'; WHEN OTHERS THEN RETURN 'Erro ao calcular resumo de BMI.'; END;
/
