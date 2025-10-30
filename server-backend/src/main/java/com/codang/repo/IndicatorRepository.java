package com.codang.repo;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.sql.Date;
import java.time.LocalDate;

@Repository
public class IndicatorRepository {
  private final JdbcTemplate jdbc;
  public IndicatorRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }
  public Double dailyCalories(long userId, LocalDate day) {
    return jdbc.queryForObject("SELECT fn_daily_calories(?, ?) FROM dual", Double.class, userId, Date.valueOf(day));
  }
  public String bmiSummary(long userId) {
    return jdbc.queryForObject("SELECT fn_user_bmi_summary(?) FROM dual", String.class, userId);
  }
}
