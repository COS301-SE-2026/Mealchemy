package com.mealchemy.cuisinetype.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/* Import classes */

import com.mealchemy.cuisinetype.model.FlavourProfileOptions;

@Repository
public interface FlavourProfileOptionsRepository extends JpaRepository<FlavourProfileOptions, Integer>
{
    boolean existsByValue(String value);

    @Query("""
        SELECT f.value FROM FlavourProfileOptions f
    """)
    List<String> getAllValues();
}
