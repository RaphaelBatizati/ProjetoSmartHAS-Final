package com.codang.sensors;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import javax.sql.DataSource;
import java.sql.*;
import java.util.Map;

@RestController
@RequestMapping("/api/sensors")
public class SensorController {
    private final DataSource dataSource;
    public SensorController(DataSource dataSource) { this.dataSource = dataSource; }

    @PostMapping(path = "/reading", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> insertReading(@RequestBody Map<String, Object> body) throws Exception {
        Number sensorId = (Number) body.getOrDefault("sensorId", 1);
        Number valueW   = (Number) body.getOrDefault("valueW", 1000);
        Number tempC    = (Number) body.getOrDefault("tempC", null);
        Number humPct   = (Number) body.getOrDefault("humPct", null);

        try (Connection conn = dataSource.getConnection()) {
            try (CallableStatement cs = conn.prepareCall("{call PKG_SMART_HAS.PR_INSERT_READING_AND_ALERT(?,?,?,?,?)}")) {
                cs.setInt(1, sensorId.intValue());
                cs.setBigDecimal(2, new java.math.BigDecimal(valueW.toString()));
                if (tempC == null) cs.setNull(3, Types.NUMERIC); else cs.setBigDecimal(3, new java.math.BigDecimal(tempC.toString()));
                if (humPct == null) cs.setNull(4, Types.NUMERIC); else cs.setBigDecimal(4, new java.math.BigDecimal(humPct.toString()));
                cs.registerOutParameter(5, Types.NUMERIC);
                cs.execute();
                int alertId = cs.getInt(5);
                return Map.of("status","ok","sensorId",sensorId,"valueW",valueW,"alertId",alertId);
            }
        }
    }
}
