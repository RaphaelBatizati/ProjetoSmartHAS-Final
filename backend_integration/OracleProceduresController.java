package com.smarthas.oracle;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/oracle")
public class OracleProceduresController {

    private final OracleProceduresService service;

    public OracleProceduresController(OracleProceduresService service) {
        this.service = service;
    }

    @GetMapping("/avg-power/{deviceId}")
    public double avgPower(@PathVariable long deviceId, @RequestParam(defaultValue = "24") int hours) {
        return service.avgPower(deviceId, hours);
    }

    @GetMapping("/device-status/{deviceId}")
    public String deviceStatus(@PathVariable long deviceId) {
        return service.deviceStatus(deviceId);
    }

    @GetMapping("/summary/{userId}")
    public String summaryByUser(@PathVariable long userId) {
        return service.summaryByUser(userId);
    }

    @PostMapping("/alerts/{deviceId}")
    public void alerts(@PathVariable long deviceId,
                       @RequestParam double powerMax,
                       @RequestParam double tempMin,
                       @RequestParam double tempMax) {
        service.registerAlerts(deviceId, powerMax, tempMin, tempMax);
    }
}