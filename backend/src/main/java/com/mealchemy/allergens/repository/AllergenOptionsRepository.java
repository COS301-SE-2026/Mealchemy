package com.mealchemy.allergens.repository;

// import classes 
import com.mealchemy.allergens.model.AllergenOptions;
import com.mealchemy.allergens.dto.AllergenOptionsResponse;

// import libraries
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AllergenOptionsRepository extends JpaRepository<AllergenOptions, Integer> {
    @Query("""
            SELECT new com.mealchemy.allergens.dto.AllergenOptionsResponse(
                a.id,
                a.value,
                a.label
            )
            FROM AllergenOptions a
        """)
        List<AllergenOptionsResponse> getAllAllergenOptions();

    @Query("""
        SELECT a.value from AllergenOptions a
    """)
    List<String> getAllAllergenValues();
}
