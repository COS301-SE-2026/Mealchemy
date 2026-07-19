package com.mealchemy.pantry;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.http.MediaType;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class PantryControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PantryIngredientRepository pantryIngredientRepository;

    @Autowired
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @Autowired
    private ObjectMapper objectMapper;
    
    //stores seeded ingredient during testing
    private IngredientCatalogue testIngredient;

    @BeforeEach
    void setUp() {
        //clear pantry data
        pantryIngredientRepository.deleteAll();
        
        //retrieve ingredient
        testIngredient = ingredientCatalogueRepository.findAll()
                .stream()
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("No ingredients seeded in ingredient_catalogue"));

        //pantry entry
        PantryIngredient pantryIngredient = new PantryIngredient();
        pantryIngredient.setUserId(1);
        pantryIngredient.setIngredientId(testIngredient.getIngId());
        pantryIngredient.setQuantity(new BigDecimal("2.5"));
        pantryIngredient.setUnit("kg");

        pantryIngredientRepository.save(pantryIngredient);
    }

    @Test
    void getUsersPantry_returnsPantryItemsForAuthenticatedUser() throws Exception {
        //simulate request
        mockMvc.perform(get("/api/pantry")
                        .with(authentication(new UsernamePasswordAuthenticationToken(
                                "1",
                                null,
                                List.of()
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(greaterThan(0))))
                .andExpect(jsonPath("$[0].p_ingredient_id", notNullValue()))
                .andExpect(jsonPath("$[0].ing_id", is(testIngredient.getIngId())))
                .andExpect(jsonPath("$[0].name", is(testIngredient.getName())))
                .andExpect(jsonPath("$[0].category", notNullValue()))
                .andExpect(jsonPath("$[0].quantity", notNullValue()))
                .andExpect(jsonPath("$[0].unit", is("kg")))
                .andExpect(jsonPath("$[0].created_at", notNullValue()))
                .andExpect(jsonPath("$[0].updated_at", notNullValue()));
    }

    @Test
    void addPantryIngredientManually_createsPantryItemForAuthenticatedUser() throws Exception {
        pantryIngredientRepository.deleteAll();

        PantryIngredientRequest request = new PantryIngredientRequest(
                testIngredient.getIngId(),
                new BigDecimal("1.75"),
                "kg"
        );

        //bbackend fills in name/category from the ingredient catalogue.
        mockMvc.perform(post("/api/pantry")
                        .with(authentication(new UsernamePasswordAuthenticationToken(
                                "1",
                                null,
                                List.of()
                        )))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.p_ingredient_id", notNullValue()))
                .andExpect(jsonPath("$.ing_id", is(testIngredient.getIngId())))
                .andExpect(jsonPath("$.name", is(testIngredient.getName())))
                .andExpect(jsonPath("$.category", notNullValue()))
                .andExpect(jsonPath("$.quantity", is(1.75)))
                .andExpect(jsonPath("$.unit", is("kg")))
                .andExpect(jsonPath("$.created_at", notNullValue()))
                .andExpect(jsonPath("$.updated_at", notNullValue()));

        //row was saved -> check
        List<PantryIngredient> savedItems = pantryIngredientRepository.findByUserId(1);
        org.junit.jupiter.api.Assertions.assertEquals(1, savedItems.size());
        org.junit.jupiter.api.Assertions.assertEquals(testIngredient.getIngId(), savedItems.get(0).getIngredientId());
        //need to compare numbers not stcale
        org.junit.jupiter.api.Assertions.assertEquals(
                0,
                new BigDecimal("1.75").compareTo(savedItems.get(0).getQuantity())
        );
        org.junit.jupiter.api.Assertions.assertEquals("kg", savedItems.get(0).getUnit());
    }

    @Test
    void updatePantryIngredientManually_updatesQuantityAndUnit() throws Exception {
        PantryIngredient existingItem = pantryIngredientRepository.findByUserId(1)
                .stream()
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("No pantry item created in setup"));

        PantryIngredientRequest request = new PantryIngredientRequest(
                testIngredient.getIngId(),
                new BigDecimal("4.25"),
                "g"
        );

        //updating keeps the same pantry row, changes the amount/unit
        mockMvc.perform(put("/api/pantry/{id}", existingItem.getPIngredientId())
                        .with(authentication(new UsernamePasswordAuthenticationToken(
                                "1",
                                null,
                                List.of()
                        )))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.p_ingredient_id", is(existingItem.getPIngredientId())))
                .andExpect(jsonPath("$.ing_id", is(testIngredient.getIngId())))
                .andExpect(jsonPath("$.name", is(testIngredient.getName())))
                .andExpect(jsonPath("$.category", notNullValue()))
                .andExpect(jsonPath("$.quantity", is(4.25)))
                .andExpect(jsonPath("$.unit", is("g")))
                .andExpect(jsonPath("$.updated_at", notNullValue()));

        PantryIngredient updatedItem = pantryIngredientRepository.findById(existingItem.getPIngredientId())
                .orElseThrow(() -> new IllegalStateException("Updated pantry item was not found"));

        //compare number
        org.junit.jupiter.api.Assertions.assertEquals(
                0,
                new BigDecimal("4.25").compareTo(updatedItem.getQuantity())
        );
        org.junit.jupiter.api.Assertions.assertEquals("g", updatedItem.getUnit());
    }
}
