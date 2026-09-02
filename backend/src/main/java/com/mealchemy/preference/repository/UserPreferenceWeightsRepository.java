package com.mealchemy.preference.repository;

/* Import classes */

/* Import libraries */

import com.mealchemy.preference.model.UserPreferenceWeights;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.*;

public interface UserPreferenceWeightsRepository extends JpaRepository<UserPreferenceWeights, Integer>
{
    Optional<UserPreferenceWeights> findByUserId(Integer userId);

    @Modifying
    @Query("""
        UPDATE UserPreferenceWeights w
        SET w.pantryMatch = :pantryMatch, w.cuisine = :cuisine, w.nutrition = :nutrition,
            w.freshness = :freshness, w.novelty = :novelty, w.stateVersion = w.stateVersion + 1
        WHERE w.userId = :userId AND w.stateVersion = :stateVersion
        """)
    int updateWeightsIfVersionMatches(
        @Param("userId") Integer userId,
        @Param("pantryMatch") BigDecimal pantryMatch,
        @Param("cuisine") BigDecimal cuisine,
        @Param("nutrition") BigDecimal nutrition,
        @Param("freshness") BigDecimal freshness,
        @Param("novelty") BigDecimal novelty,
        @Param("stateVersion") Integer stateVersion
    );
}
