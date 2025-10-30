package com.codang.web;

import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api", produces = MediaType.APPLICATION_JSON_VALUE)
public class ApiController {

  @GetMapping
  public Map<String, Object> index() {
    return Map.of(
        "home", "/",
        "endpoints", new String[]{
            "/db/avg-consumption?sensorId=1&days=3",
            "/db/format-alert?sensorId=1&hours=24",
            "/db/run-alerts?powerThresh=900&tempThresh=70",
            "/db/upsert-sensor?userId=1&name=Fridge1&type=TEMP&location=Kitchen",
            "/db/report?userId=1&start=2025-09-01&end=2025-09-30",
            "/db/report-last-days?userId=1&days=7",
            "/db/check-critical?sensorId=1&value=95.5"
        }
    );
  }

  @GetMapping("/ping")
  public Map<String, String> ping() {
    return Map.of("status", "ok", "service", "api");
  }
}
