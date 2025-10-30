package com.codang.repo;

import java.sql.Date;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
public class ReportRepository {

  private final SimpleJdbcCall call;

  public ReportRepository(DataSource ds) {
    this.call = new SimpleJdbcCall(ds)
      .withProcedureName("pr_user_consumption_report")
      .declareParameters(
        new SqlParameter("p_user_id", Types.NUMERIC),
        new SqlParameter("p_start", Types.DATE),
        new SqlParameter("p_end", Types.DATE),
        new SqlOutParameter("p_result", Types.REF_CURSOR) // CURSOR → REF_CURSOR
      );
  }

  @SuppressWarnings("unchecked")
  public List<Map<String,Object>> report(long userId, LocalDate start, LocalDate end) {
    Map<String,Object> out = call.execute(Map.of(
      "p_user_id", userId,
      "p_start", Date.valueOf(start),
      "p_end", Date.valueOf(end)
    ));
    return (List<Map<String,Object>>) out.get("p_result");
  }
}
