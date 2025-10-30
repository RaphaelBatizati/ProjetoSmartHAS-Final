
-- seed.sql: sample data for Smart HAS

INSERT INTO APP_USER (NAME, EMAIL) VALUES ('Raphael Batizati', 'raphael@example.com');
INSERT INTO APP_USER (NAME, EMAIL) VALUES ('Test User', 'test@example.com');

-- Example sensors
INSERT INTO SENSOR (USER_ID, NAME, TYPE, LOCATION) VALUES (1, 'Meter Main', 'POWER', 'Building A');
INSERT INTO SENSOR (USER_ID, NAME, TYPE, LOCATION) VALUES (1, 'Boiler Temp', 'TEMP', 'Boiler Room');
INSERT INTO SENSOR (USER_ID, NAME, TYPE, LOCATION) VALUES (2, 'Office Meter', 'POWER', 'Office A');

-- Simulated readings (POWER_W in Watts; TEMP_C in Celsius)
-- We'll insert multiple days of POWER readings to enable averages
BEGIN
  FOR d IN 0..6 LOOP
    FOR i IN 0..23 LOOP
      INSERT INTO SENSOR_READING (SENSOR_ID, READING_TS, POWER_W)
      VALUES (1, SYSTIMESTAMP - d - (i/24), 500 + (DBMS_RANDOM.VALUE(-50, 150)));
      INSERT INTO SENSOR_READING (SENSOR_ID, READING_TS, POWER_W)
      VALUES (3, SYSTIMESTAMP - d - (i/24), 300 + (DBMS_RANDOM.VALUE(-30, 100)));
    END LOOP;
  END LOOP;
  -- Temperature sensor
  FOR d IN 0..2 LOOP
    FOR i IN 0..23 LOOP
      INSERT INTO SENSOR_READING (SENSOR_ID, READING_TS, TEMP_C)
      VALUES (2, SYSTIMESTAMP - d - (i/24), 60 + (DBMS_RANDOM.VALUE(-2, 5)));
    END LOOP;
  END LOOP;
END;
/
COMMIT;
