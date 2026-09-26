package com.mealchemy.mealprep.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

/* Import classes */
import com.mealchemy.mealprep.model.MealPlan;

@Repository
public interface MealPlanRepository extends JpaRepository<MealPlan, Integer>{
    Optional<MealPlan> findByVaultId(Integer vaultId);
}
