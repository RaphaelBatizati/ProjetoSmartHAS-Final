package com.smarthas.oracle;

import org.springframework.stereotype.Service;

@Service
public class OracleProceduresService {

    private final OracleProceduresRepository repo;

    public OracleProceduresService(OracleProceduresRepository repo) {
        this.repo = repo;
    }

    public double avgPower(long deviceId, int hoursBack) {
        return repo.avgPower(deviceId, hoursBack);
    }

    public String deviceStatus(long deviceId) {
        return repo.deviceStatusJson(deviceId);
    }

    public String summaryByUser(long userId) {
        return repo.summaryUserConsumption(userId);
    }

    public void registerAlerts(long deviceId, double powerMax, double tempMin, double tempMax) {
        repo.checkAndRegisterAlerts(deviceId, powerMax, tempMin, tempMax);
    }
}