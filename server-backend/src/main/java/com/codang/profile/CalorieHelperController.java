
package com.codang.profile;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

/**
 * Endpoint simples de cálculo diário de calorias recomendado (estimativa)
 * Fórmula Harris-Benedict simplificada (sem sexo/altura -> demo). 
 * Para produção, adicione campos de sexo, altura e nível de atividade.
 */
@RestController
@RequestMapping("/api/diet")
public class CalorieHelperController {

    @PostMapping("/calc")
    public Map<String, Object> calc(@RequestBody Map<String, Object> body) {
        // Entrada: age, weightKg, targetCalories (opcional)
        int age = ((Number) body.getOrDefault("age", 30)).intValue();
        double weightKg = ((Number) body.getOrDefault("weightKg", 70)).doubleValue();

        // estimativa basal simples ~ 24 * peso
        double bmr = 24.0 * weightKg; 
        // ajuste rudimentar por idade
        if (age > 40) bmr *= 0.95;
        if (age > 55) bmr *= 0.90;

        return Map.of(
                "bmrEstimate", Math.round(bmr),
                "suggestion", "Ajuste sua meta de calorias considerando sua rotina diária e objetivos."
        );
    }
}
