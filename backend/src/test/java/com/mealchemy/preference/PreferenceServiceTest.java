// unit testing for user preferences

package com.mealchemy.preference;

import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.preference.service.PreferenceService;

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
        existingPreferences.setDietaryRestrictions(List.of("vegetarian"));
        existingPreferences.setAllergies(List.of("peanuts"));
        existingPreferences.setDislikedIngredients(List.of("coriander"));
        existingPreferences.setFlavourProfile(List.of("mediterranean"));
        existingPreferences.setNutritionalGoals(List.of("low_carb"));

        // simulates what flutter puts in PUT req
        updateRequest = new PreferenceRequest(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese"),
            List.of("high_fibre")
        );
    }

    // ========== Get Preferences Testing ==========

    // Negative path
    @Test
    void preferences_whenUserNotFound_throwsNotFound() {
        // Arrange - no preferences exist for this user
        when(userPreferencesRepository.findByUserId(1))
            .thenReturn(Optional.empty());

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
        when(userPreferencesRepository.findByUserId(1))
            .thenReturn(Optional.of(existingPreferences));

        // Act
        PreferenceResponse response = preferenceService.preferences(1);

        // Assert
        assertNotNull(response);
        assertEquals(List.of("vegetarian"), response.dietaryRestrictions());
        assertEquals(List.of("peanuts"), response.allergies());
        assertEquals(List.of("coriander"), response.dislikedIngredients());
        assertEquals(List.of("mediterranean"), response.flavourProfile());
        assertEquals(List.of("low_carb"), response.nutritionalGoals());
    }

    // ========== Update Preferences Testing ==========

    @Test
    void updatePreferences_whenUserNotFound_throwsNotFound() {
        // Arrange
        when(userPreferencesRepository.findByUserId(1))
            .thenReturn(Optional.empty());

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
        when(userPreferencesRepository.findByUserId(1))
            .thenReturn(Optional.of(existingPreferences));
        when(userPreferencesRepository.save(any(UserPreferences.class)))
            .thenReturn(existingPreferences);

        // Act
        PreferenceResponse response = preferenceService.updatePreferences(1, updateRequest);

        // Assert - show updated values
        assertNotNull(response);
        assertEquals(List.of("vegan"), response.dietaryRestrictions());
        assertEquals(List.of("gluten"), response.allergies());
        assertEquals(List.of("anchovies"), response.dislikedIngredients());
        assertEquals(List.of("japanese"), response.flavourProfile());
        assertEquals(List.of("high_fibre"), response.nutritionalGoals());

        // Verify save was called once
        verify(userPreferencesRepository).save(any(UserPreferences.class));
    }
}
