
package com.codang.profile;

import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    private final JdbcTemplate jdbc;

    public ProfileController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Profile> PROFILE_MAPPER = (rs, rowNum) -> new Profile(
        rs.getLong("USER_ID"),
        rs.getString("NAME"),
        rs.getObject("AGE") != null ? rs.getInt("AGE") : null,
        rs.getObject("WEIGHT_KG") != null ? rs.getDouble("WEIGHT_KG") : null,
        rs.getObject("TARGET_CALORIES") != null ? rs.getInt("TARGET_CALORIES") : null
    );

    @GetMapping("/{userId}")
    public Profile get(@PathVariable Long userId) {
        return jdbc.queryForObject(
            "SELECT USER_ID, NAME, AGE, WEIGHT_KG, TARGET_CALORIES FROM USER_PROFILE WHERE USER_ID = ?",
            PROFILE_MAPPER, userId
        );
    }

    @PostMapping("/upsert")
    public Map<String, Object> upsert(@RequestBody Profile p) {
        if (p.getUserId() == null) {
            // insert
            jdbc.update("INSERT INTO USER_PROFILE(NAME, AGE, WEIGHT_KG, TARGET_CALORIES) VALUES(?,?,?,?)",
                    p.getName(), p.getAge(), p.getWeightKg(), p.getTargetCalories());
            Long id = jdbc.queryForObject("SELECT MAX(USER_ID) FROM USER_PROFILE", Long.class);
            p.setUserId(id);
            return Map.of("status", "created", "userId", id);
        } else {
            // update
            int rows = jdbc.update("UPDATE USER_PROFILE SET NAME=?, AGE=?, WEIGHT_KG=?, TARGET_CALORIES=? WHERE USER_ID=?",
                    p.getName(), p.getAge(), p.getWeightKg(), p.getTargetCalories(), p.getUserId());
            return Map.of("status", rows > 0 ? "updated" : "not_found", "userId", p.getUserId());
        }
    }
}
