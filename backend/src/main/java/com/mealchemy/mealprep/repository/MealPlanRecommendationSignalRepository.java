package com.mealchemy.mealprep.repository;

/* Import libraries */
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */
import com.mealchemy.mealprep.model.MealPlanRecommendationSignal;

@Repository
public interface MealPlanRecommendationSignalRepository extends JpaRepository<MealPlanRecommendationSignal, Integer>{
    Optional<MealPlanRecommendationSignal> findByEntryId(Integer entryId);

    List<MealPlanRecommendationSignal> findByProcessedAtIsNull();
}
