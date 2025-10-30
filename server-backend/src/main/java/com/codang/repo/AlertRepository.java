package com.codang.repo;

import java.sql.Timestamp;
import java.sql.Types;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
public class AlertRepository {

  private final SimpleJdbcCall call;

  public AlertRepository(DataSource ds) {
    this.call = new SimpleJdbcCall(ds)
      .withProcedureName("pr_check_critical_reading")
      .declareParameters(
        new SqlParameter("p_sensor_id", Types.NUMERIC),
        new SqlParameter("p_value", Types.NUMERIC),
        new SqlParameter("p_when_ts", Types.TIMESTAMP),
        new SqlOutParameter("p_alert_id", Types.NUMERIC)
      );
  }

  public Long checkAndAlert(long sensorId, double value) {
    Map<String,Object> out = call.execute(Map.of(
      "p_sensor_id", sensorId,
      "p_value", value,
      "p_when_ts", new Timestamp(System.currentTimeMillis())
    ));
    Object v = out.get("p_alert_id");
    return v == null ? null : ((Number)v).longValue();
  }
}
