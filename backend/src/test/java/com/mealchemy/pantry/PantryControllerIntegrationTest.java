package com.mealchemy.pantry;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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
}
