package com.mealchemy.pantry.controller;

// import dtos
import com.mealchemy.pantry.dto.*;
// import services
import com.mealchemy.pantry.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/pantry") 
public class PantryController {

    private final PantryService pantryService;

    public PantryController(PantryService pantryService) {
        this.pantryService = pantryService;
    }

    // get all users pantry ingredients
    @GetMapping("")
    public ResponseEntity<List<PantryIngredientResponse>> getUsersPantry(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(pantryService.getUserPantryItems(Integer.parseInt(userId)));
    }

    // user manually adds a new ingredient
    @PostMapping("")
    public ResponseEntity<PantryIngredientResponse> addPantryIngredientManually(@AuthenticationPrincipal String userId, @RequestBody PantryIngredientRequest request) {
        return ResponseEntity.ok(pantryService.addIngredientManually(Integer.parseInt(userId), request));
    }
    

    // user manually updates an existing pantry ingredient
    @PutMapping("/{id}")
    public ResponseEntity<PantryIngredientResponse> updatePantryIngredientManually(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody PantryIngredientRequest request) {
        return pantryService.updateIngredientManually(Integer.parseInt(userId), id, request).map(ResponseEntity::ok)
                                                                                            .orElse(ResponseEntity.noContent().build());
    }

    // user deletes an existing ingredient in their pantry
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> removePantryIngredientManually(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        pantryService.removePantryIngredient(Integer.parseInt(userId), id);
        return ResponseEntity.noContent().build();
    }
}