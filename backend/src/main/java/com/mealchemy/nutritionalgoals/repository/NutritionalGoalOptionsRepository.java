package com.mealchemy.nutritionalgoals.repository;

// import classes 
import com.mealchemy.nutritionalgoals.model.NutritionalGoalOptions;
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;

// import libraries
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NutritionalGoalOptionsRepository extends JpaRepository<NutritionalGoalOptions, Integer> {
    @Query("""
            SELECT new com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse(
                n.id,
                n.value,
                n.label
            )
            FROM NutritionalGoalOptions n
        """)
        List<NutritionalGoalOptionsResponse> getAllNutritionalGoalOptions();

    @Query("""
        SELECT n.value from NutritionalGoalOptions n
    """)
    List<String> getAllNutritionalGoalOptionsValues();
}
