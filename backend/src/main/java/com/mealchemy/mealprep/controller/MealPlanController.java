package com.mealchemy.mealprep.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;
import java.time.LocalDate;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.mealprep.dto.MealPlanRequest;
import com.mealchemy.mealprep.dto.MealPlanResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryRequest;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;
import com.mealchemy.mealprep.service.MealPlanService;

// swagger
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;


@RestController
@RequestMapping("/api/meal-plans")
@Tag(name = "Meal Plans", description = "Meal plan and meal plan entry management for a vault")
public class MealPlanController
{
    private final MealPlanService mealPlanService;

    public MealPlanController(MealPlanService mealPlanService)
    {
        this.mealPlanService = mealPlanService;
    }

    /* Mapping Functions */

    // Post get or create plan
    @Operation(summary = "Get or create the meal plan for a vault", description = "Returns the vault's single ongoing meal plan, creating it on first access.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Meal plan retrieved or created successfully", content = @Content(schema = @Schema(implementation = MealPlanResponse.class))),
        @ApiResponse(responseCode = "400", description = "vaultId missing from request body", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or caller has no access to it", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("")
    public MealPlanResponse getOrCreatePlan(@Valid @RequestBody MealPlanRequest request, @AuthenticationPrincipal String userId)
    {
        return mealPlanService.getOrCreatePlan(request.vaultId(), Integer.parseInt(userId));
    }

    
    // Get meal plans entries over a specific time period
    @Operation(summary = "Fetch meal plan entries in a date range", description = "Returns every entry scheduled for the vault's meal plan between startDate and endDate, inclusive, ordered by date then meal time.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Entries retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = MealPlanEntryResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or caller has no access to it", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public List<MealPlanEntryResponse> getEntries(@RequestParam Integer vaultId, @RequestParam LocalDate startDate, @RequestParam LocalDate endDate, @AuthenticationPrincipal String userId)
    {
        MealPlanResponse plan = mealPlanService.getOrCreatePlan(vaultId, Integer.parseInt(userId));
        return mealPlanService.getEntries(plan.planId(), Integer.parseInt(userId), startDate, endDate);
    }


    // Post - add new meal plan entry
    @Operation(summary = "Manually assign a recipe to a slot", description = "Creates a manual entry for a given date and meal slot. Fails if slot is already occpied.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Entry created successfully", content = @Content(schema = @Schema(implementation = MealPlanEntryResponse.class))),
        @ApiResponse(responseCode = "400", description = "mealTime is outside the valid range for the given mealSlot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the vault owner or an editor", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "An entry already existis for that date and meal slot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{planId}/entries")
    public MealPlanEntryResponse createManualEntry(@PathVariable Integer planId, @Valid @RequestBody MealPlanEntryRequest request, @AuthenticationPrincipal String userId)
    {
        return mealPlanService.createManualEntry(planId, Integer.parseInt(userId), request);
    }


    // Put - update an existing entry
    @Operation(summary = "Swap a slot's entry", description = "Replaces the recipe/time/title/note for an existing entry. Downgrades the entry's source to MANUAL, even if it was previously RECOMMENDED.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Entry updated successfully", content = @Content(schema = @Schema(implementation = MealPlanEntryResponse.class))),
        @ApiResponse(responseCode = "400", description = "mealTime is outside the valid range for the given mealSlot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the vault owner or an editor", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan or entry not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "An entry already existis for that date and meal slot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{planId}/entries/{entryId}")
    public MealPlanEntryResponse updateEntry(@PathVariable Integer planId, @PathVariable Integer entryId, @Valid @RequestBody MealPlanEntryRequest request, @AuthenticationPrincipal String userId)
    {
        return mealPlanService.updateEntry(planId, entryId, Integer.parseInt(userId), request);
    }


    // Delete - add new meal plan entry
    @Operation(summary = "Remove a slot's entry", description = "Deletes an entry from the meal plan.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Entry deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the vault owner or an editor", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan or entry not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{planId}/entries/{entryId}")
    public ResponseEntity<Void> removeEntry(@PathVariable Integer planId, @PathVariable Integer entryId, @AuthenticationPrincipal String userId)
    {
        mealPlanService.removeEntry(planId, entryId, Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }
}