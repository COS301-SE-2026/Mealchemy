package com.mealchemy.mealprep.dto;

/* Import libraries */

/* Import classes */
import com.mealchemy.mealprep.model.MealPlan;

public record MealPlanResponse(
    Integer planId,
    Integer vaultId,
    Integer createdBy
)
{
    public static MealPlanResponse from(MealPlan plan)
    {
        return new MealPlanResponse(
            plan.getPlanId(),
            plan.getVaultId(),
            plan.getCreatedBy()
        );
    }
}