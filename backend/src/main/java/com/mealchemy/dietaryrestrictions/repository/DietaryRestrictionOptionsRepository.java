package com.mealchemy.dietaryrestrictions.repository;

// import classes 
import com.mealchemy.dietaryrestrictions.model.DietaryRestrictionOptions;
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;

// import libraries
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DietaryRestrictionOptionsRepository extends JpaRepository<DietaryRestrictionOptions, Integer> {
    @Query("""
            SELECT new com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse(
                d.id,
                d.value,
                d.label
            )
            FROM DietaryRestrictionOptions d
        """)
        List<DietaryRestrictionOptionsResponse> getAllDietaryRestrictionOptions();

    @Query("""
        SELECT d.value from DietaryRestrictionOptions d
    """)
    List<String> getAllDietaryRestrictionOptionsValues();
}
