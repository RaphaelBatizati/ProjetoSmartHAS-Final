package com.codang.db;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.PostConstruct;

@RestController
@RequestMapping("/db")
public class OraclePlsqlController {

    @Autowired
    private JdbcTemplate jdbc;

    private SimpleJdbcCall pRegisterAlerts;
    private SimpleJdbcCall pGenerateUserConsumption;
    private SimpleJdbcCall pUpsertSensor;

    @PostConstruct
    public void init() {
        // Inicializa as chamadas para procedures
        this.pRegisterAlerts = new SimpleJdbcCall(jdbc).withProcedureName("PR_REGISTER_ALERTS");
        this.pGenerateUserConsumption = new SimpleJdbcCall(jdbc).withProcedureName("PR_USER_CONSUMPTION_REPORT");
        this.pUpsertSensor = new SimpleJdbcCall(jdbc).withProcedureName("PR_UPSERT_SENSOR");
    }

    @GetMapping("/avg-consumption")
    public Double avgConsumption(@RequestParam int sensorId,
            @RequestParam(defaultValue = "3") int days) {
        Double result = jdbc.queryForObject(
                "SELECT F_CALC_AVG_CONSUMPTION(?, ?) FROM dual",
                Double.class, sensorId, days);
        return result != null ? result : 0d;
    }

    @GetMapping("/format-alert")
    public String formatAlert(@RequestParam int sensorId,
            @RequestParam(defaultValue = "24") int hours) {
        return jdbc.queryForObject(
                "SELECT F_FORMAT_ALERT(?, ?) FROM dual",
                String.class, sensorId, hours);
    }

    @PostMapping("/run-alerts")
    public String runAlerts(@RequestParam(defaultValue = "900") int powerThresh,
            @RequestParam(defaultValue = "70") int tempThresh) {
        pRegisterAlerts.execute(Map.of(
                "P_POWER_THRESHOLD", powerThresh,
                "P_TEMP_THRESHOLD", tempThresh
        ));
        return "Alerts registered (if any).";
    }

    @PostMapping("/generate-report")
    public String generateReport(@RequestParam int userId,
            @RequestParam(defaultValue = "3") int days) {
        pGenerateUserConsumption.execute(Map.of(
                "P_USER_ID", userId,
                "P_DAYS", days
        ));
        return "Consumption summary generated.";
    }

    @PostMapping("/upsert-sensor")
    public Map<String, Object> upsertSensor(@RequestParam int userId,
            @RequestParam String name,
            @RequestParam String type,
            @RequestParam(defaultValue = "Unknown") String location) {
        return pUpsertSensor.execute(Map.of(
                "P_USER_ID", userId,
                "P_NAME", name,
                "P_TYPE", type,
                "P_LOCATION", location
        ));
    }
}
