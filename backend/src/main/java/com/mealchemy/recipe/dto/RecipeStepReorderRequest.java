package com.mealchemy.recipe.dto;

/* Import libraries */

import jakarta.validation.constraints.*;
import java.util.*;

/* Import classes */

public record RecipeStepReorderRequest(
    @NotNull List<Integer> orderedStepIds
){}