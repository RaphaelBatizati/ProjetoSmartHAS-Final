
package com.codang.profile;

public class Profile {
    private Long userId;
    private String name;
    private Integer age;
    private Double weightKg;
    private Integer targetCalories;

    public Profile() {}

    public Profile(Long userId, String name, Integer age, Double weightKg, Integer targetCalories) {
        this.userId = userId;
        this.name = name;
        this.age = age;
        this.weightKg = weightKg;
        this.targetCalories = targetCalories;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public Double getWeightKg() { return weightKg; }
    public void setWeightKg(Double weightKg) { this.weightKg = weightKg; }

    public Integer getTargetCalories() { return targetCalories; }
    public void setTargetCalories(Integer targetCalories) { this.targetCalories = targetCalories; }
}
