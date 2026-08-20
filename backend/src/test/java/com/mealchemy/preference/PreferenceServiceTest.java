// unit testing for user preferences

package com.mealchemy.preference;

import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.preference.service.PreferenceService;

import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;
import com.mealchemy.allergens.service.AllergenOptionsService;
import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;
import com.mealchemy.ingredient.service.IngredientCatalogueService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class) //tells JUnit to use Mockito to create mocks
public class PreferenceServiceTest {
    // @Mock - create fake version of dependency
    @Mock private UserPreferencesRepository userPreferencesRepository;
    @Mock private DietaryRestrictionOptionsService dietaryRestrictionOptionsService;
    @Mock private AllergenOptionsService allergenOptionsService;
    @Mock private NutritionalGoalOptionsService nutritionalGoalOptionsService;
    @Mock private FlavourProfileOptionsService flavourProfileOptionsService;
    @Mock private IngredientCatalogueService ingredientCatalogueService;

    // @InjectMocks creates the real PreferenceService and injects the mocks above into it - actually testing PreferenceSer
    @InjectMocks
    private PreferenceService preferenceService;

    private UserPreferences existingPreferences;
    private PreferenceRequest updateRequest;

    @BeforeEach
    void setUp() {
        // simulates what db returns for existing user
        existingPreferences = new UserPreferences();
        existingPreferences.setUserId(1);
        existingPreferences.setDietaryRestrictions(List.of("VEGETARIAN"));
        existingPreferences.setAllergies(List.of("PEANUTS"));
        existingPreferences.setDislikedIngredients(List.of("coriander"));
        existingPreferences.setFlavourProfile(List.of("MEDITERRANEAN"));
        existingPreferences.setNutritionalGoals(List.of("LOW_CARB"));

        // simulates what flutter puts in PUT req
        updateRequest = new PreferenceRequest(
            List.of("VEGAN"),
            List.of("GLUTEN"),
            List.of("anchovies"),
            List.of("JAPANESE"),
            List.of("HIGH_PROTEIN")
        );
    }

    // ========== Get Preferences Testing ==========

    // Negative path
    @Test
    void preferences_whenUserNotFound_throwsNotFound() {
        // Arrange - no preferences exist for this user
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.empty());

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.preferences(1)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    // Happy path
    @Test
    void preferences_whenUserExists_returnsPreferences() {
        // Arrange
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));

        // Act
        PreferenceResponse response = preferenceService.preferences(1);

        // Assert
        assertNotNull(response);
        assertEquals(List.of("VEGETARIAN"), response.dietaryRestrictions());
        assertEquals(List.of("PEANUTS"), response.allergies());
        assertEquals(List.of("coriander"), response.dislikedIngredients());
        assertEquals(List.of("MEDITERRANEAN"), response.flavourProfile());
        assertEquals(List.of("LOW_CARB"), response.nutritionalGoals());
    }

    // ========== Update Preferences Testing ==========

    @Test
    void updatePreferences_whenUserNotFound_throwsNotFound() {
        // Arrange
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.empty());

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.updatePreferences(1, updateRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());

        // Verify save was never called
        verify(userPreferencesRepository, never()).save(any());
    }

    @Test
    void updatePreferences_withValidRequest_updatesAndReturnsPreferences() {
        // Arrange
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));
        when(dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions()).thenReturn(List.of("VEGAN", "VEGETARIAN"));
        when(allergenOptionsService.getValidAllergenOptions()).thenReturn(List.of("GLUTEN", "PEANUTS"));
        when(flavourProfileOptionsService.getValidCuisineTypes()).thenReturn(List.of("JAPANESE", "MEDITERRANEAN"));
        when(nutritionalGoalOptionsService.getValidNutritionalGoalOptions()).thenReturn(List.of("HIGH_PROTEIN", "LOW_CARB"));
        when(ingredientCatalogueService.findExistingIngredientNames(List.of("anchovies"))).thenReturn(List.of("anchovies"));
        when(userPreferencesRepository.save(any(UserPreferences.class))).thenReturn(existingPreferences);

        // Act
        PreferenceResponse response = preferenceService.updatePreferences(1, updateRequest);

        // Assert - show updated values
        assertNotNull(response);
        assertEquals(List.of("VEGAN"), response.dietaryRestrictions());
        assertEquals(List.of("GLUTEN"), response.allergies());
        assertEquals(List.of("anchovies"), response.dislikedIngredients());
        assertEquals(List.of("JAPANESE"), response.flavourProfile());
        assertEquals(List.of("HIGH_PROTEIN"), response.nutritionalGoals());

        // Verify save was called once
        verify(userPreferencesRepository).save(any(UserPreferences.class));
    }

    @Test
    void updatePreferences_invalidDietaryRestriction_throwsBadRequest() {
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));
        when(dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions()).thenReturn(List.of("VEGETARIAN"));

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.updatePreferences(1, updateRequest) // requests "VEGAN"
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verify(userPreferencesRepository, never()).save(any());
    }

    @Test
    void updatePreferences_withInvalidAllergen_throwsBadRequest() {
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));
        when(dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions()).thenReturn(List.of("VEGAN"));
        when(allergenOptionsService.getValidAllergenOptions()).thenReturn(List.of("PEANUTS"));

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.updatePreferences(1, updateRequest) // requests "GLUTEN"
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verify(userPreferencesRepository, never()).save(any());
    }

    @Test
    void updatePreferences_withInvalidFlavourProfile_throwsBadRequest() {
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));
        when(dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions()).thenReturn(List.of("VEGAN"));
        when(allergenOptionsService.getValidAllergenOptions()).thenReturn(List.of("GLUTEN"));
        when(flavourProfileOptionsService.getValidCuisineTypes()).thenReturn(List.of("MEDITERRANEAN"));

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.updatePreferences(1, updateRequest) // requests "JAPANESE"
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verify(userPreferencesRepository, never()).save(any());
    }

    @Test
    void updatePreferences_withInvalidDislikedIngredients_throwsBadRequest() {
        when(userPreferencesRepository.findByUserId(1)).thenReturn(Optional.of(existingPreferences));
        when(dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions()).thenReturn(List.of("VEGAN"));
        when(allergenOptionsService.getValidAllergenOptions()).thenReturn(List.of("GLUTEN"));
        when(flavourProfileOptionsService.getValidCuisineTypes()).thenReturn(List.of("JAPANESE"));
        when(nutritionalGoalOptionsService.getValidNutritionalGoalOptions()).thenReturn(List.of("HIGH_PROTEIN"));
        when(ingredientCatalogueService.findExistingIngredientNames(List.of("anchovies"))).thenReturn(List.of());

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceService.updatePreferences(1, updateRequest) // requests "anchovies"
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verify(userPreferencesRepository, never()).save(any());
    }
}
