package com.smarthas.oracle;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Types;
import java.util.Map;

@Repository
public class OracleProceduresRepository {

    private final JdbcTemplate jdbcTemplate;

    public OracleProceduresRepository(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public double avgPower(long deviceId, int hoursBack) {
        return jdbcTemplate.queryForObject(
                "SELECT FN_AVG_POWER(?, ?) FROM dual",
                Double.class, deviceId, hoursBack
        );
    }

    public String deviceStatusJson(long deviceId) {
        return jdbcTemplate.queryForObject(
                "SELECT FN_DEVICE_STATUS_JSON(?) FROM dual",
                String.class, deviceId
        );
    }

    public String summaryUserConsumption(long userId) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("PR_SUMMARY_USER_CONSUMPTION")
                .declareParameters(
                        new SqlParameter("P_USER_ID", Types.NUMERIC),
                        new SqlOutParameter("P_JSON", Types.CLOB)
                );
        Map<String, Object> out = call.execute(userId);
        Object clob = out.get("P_JSON");
        return clob != null ? clob.toString() : "[]";
    }

    public void checkAndRegisterAlerts(long deviceId, double powerMax, double tempMin, double tempMax) {
        jdbcTemplate.update("CALL PR_CHECK_AND_REGISTER_ALERTS(?, ?, ?, ?)",
                deviceId, powerMax, tempMin, tempMax);
    }
}