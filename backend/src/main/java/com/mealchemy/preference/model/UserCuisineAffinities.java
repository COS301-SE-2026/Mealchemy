package com.mealchemy.preference.model;

/* Import classes */

/* Import libraries */

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import java.time.OffsetDateTime;
import java.util.List;
import java.math.BigDecimal;

public class UserCuisineAffinities {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "affinity_id")
    private Integer affinityId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "cuisine_value", nullable = false)
    private String cuisineValue;

    @Column(name = "affinity_score", precision = 4, scale = 3, nullable = false)
    private BigDecimal affinityScore;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    /* Getters */

    /* Setters */

}
