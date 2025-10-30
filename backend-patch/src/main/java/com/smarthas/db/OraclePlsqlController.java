
package com.smarthas.db;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;
import java.sql.Types;
import java.util.Map;

@RestController
public class OraclePlsqlController {

    @Autowired
    private JdbcTemplate jdbc;

    private SimpleJdbcCall pRegisterAlerts;
    private SimpleJdbcCall pGenerateUserConsumption;
    private SimpleJdbcCall pUpsertSensor;

    @PostConstruct
    void init() {
        pRegisterAlerts = new SimpleJdbcCall(jdbc)
                .withProcedureName("P_REGISTER_ALERTS");

        pGenerateUserConsumption = new SimpleJdbcCall(jdbc)
                .withProcedureName("P_GENERATE_USER_CONSUMPTION")
                .declareParameters(
                        new SqlParameter("P_USER_ID", Types.NUMERIC),
                        new SqlParameter("P_DAYS", Types.NUMERIC)
                );

        pUpsertSensor = new SimpleJdbcCall(jdbc)
                .withProcedureName("P_UPSERT_SENSOR")
                .declareParameters(
                        new SqlParameter("P_USER_ID", Types.NUMERIC),
                        new SqlParameter("P_NAME", Types.VARCHAR),
                        new SqlParameter("P_TYPE", Types.VARCHAR),
                        new SqlParameter("P_LOCATION", Types.VARCHAR),
                        new SqlOutParameter("P_SENSOR_ID", Types.NUMERIC)
                );
    }

    @GetMapping("/db/avg-consumption")
    public Double avgConsumption(@RequestParam int sensorId,
                                 @RequestParam(defaultValue = "3") int days) {
        Double result = jdbc.queryForObject(
                "SELECT F_CALC_AVG_CONSUMPTION(?, ?) FROM dual",
                Double.class, sensorId, days);
        return result != null ? result : 0d;
    }

    @GetMapping("/db/format-alert")
    public String formatAlert(@RequestParam int sensorId,
                              @RequestParam(defaultValue = "24") int hours) {
        return jdbc.queryForObject(
                "SELECT F_FORMAT_ALERT(?, ?) FROM dual",
                String.class, sensorId, hours);
    }

    @PostMapping("/db/run-alerts")
    public String runAlerts(@RequestParam(defaultValue = "900") int powerThresh,
                            @RequestParam(defaultValue = "70") int tempThresh) {
        pRegisterAlerts.execute(Map.of(
                "P_POWER_THRESHOLD", powerThresh,
                "P_TEMP_THRESHOLD", tempThresh
        ));
        return "Alerts registered (if any).";
    }

    @PostMapping("/db/generate-report")
    public String generateReport(@RequestParam int userId,
                                 @RequestParam(defaultValue = "3") int days) {
        pGenerateUserConsumption.execute(Map.of(
                "P_USER_ID", userId,
                "P_DAYS", days
        ));
        return "Consumption summary generated.";
    }

    @PostMapping("/db/upsert-sensor")
    public Map<String, Object> upsertSensor(@RequestParam int userId,
                                            @RequestParam String name,
                                            @RequestParam String type,
                                            @RequestParam(defaultValue = "Unknown") String location) {
        Map<String, Object> out = pUpsertSensor.execute(Map.of(
                "P_USER_ID", userId,
                "P_NAME", name,
                "P_TYPE", type,
                "P_LOCATION", location
        ));
        return out;
    }
}
