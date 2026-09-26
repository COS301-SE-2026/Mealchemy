package com.mealchemy.mealprep.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */
import com.mealchemy.mealprep.model.MealPlan;

public class MealPlanRepository extends JPARepository<MealPlan, Integer>{
    Optional<MealPlan> findByVaultId(Integer vaultId);
}
