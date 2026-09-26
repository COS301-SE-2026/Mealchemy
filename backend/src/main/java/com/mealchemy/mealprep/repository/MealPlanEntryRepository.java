package com.mealchemy.mealprep.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.*;
import java.time.LocalDate;

/* Import classes */
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.shared.enums.MealSlot;

@Repository
public interface MealPlanEntryRepository extends JpaRepository<MealPlanEntry, Integer>{
    Optional<MealPlanEntry> findByPlan_PlanIdAndEntryDateAndMealSlot(Integer planId, LocalDate entryDate, MealSlot mealSlot);
    
    Optional<MealPlanEntry> findByEntryIdAndPlan_PlanId(Integer entryId, Integer planId);
    
    List<MealPlanEntry> findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(Integer planId, LocalDate start, LocalDate end);
    
    List<MealPlanEntry> findByPlan_PlanIdAndEntryDateLessThanOrderByEntryDateAscMealTimeAsc(Integer planId, LocalDate date);
    
    @Query("SELECT e.recipeId FROM MealPlanEntry e WHERE e.plan.planId = :planId")
    List<Integer> findRecipeIdsByPlanId(@Param("planId") Integer planId);
}
