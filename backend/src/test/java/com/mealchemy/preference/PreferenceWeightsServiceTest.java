package com.mealchemy.preference;

import com.mealchemy.preference.dto.UserPreferenceWeightsRequest;
import com.mealchemy.preference.dto.UserPreferenceWeightsResponse;
import com.mealchemy.preference.model.UserPreferenceWeights;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.preference.service.PreferenceWeightsService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class)
public class PreferenceWeightsServiceTest {
    @Mock private UserPreferenceWeightsRepository userPreferenceWeightsRepository;

    @InjectMocks
    private PreferenceWeightsService preferenceWeightsService;

    private UserPreferenceWeights existingWeights;
    private UserPreferenceWeightsRequest validRequest;

    @BeforeEach
    void setUp() {
        existingWeights = new UserPreferenceWeights();
        existingWeights.setUserId(1);
        existingWeights.setPantryMatch(bd("0.4000"));
        existingWeights.setCuisine(bd("0.2500"));
        existingWeights.setNutrition(bd("0.1000"));
        existingWeights.setFreshness(bd("0.1500"));
        existingWeights.setNovelty(bd("0.1000"));
        existingWeights.setStateVersion(3);

        validRequest = new UserPreferenceWeightsRequest(bd("0.50"), bd("0.20"), bd("0.10"), bd("0.10"), bd("0.10"));
    }

    /* Helpers */

    private BigDecimal bd(String value) {
        return new BigDecimal(value);
    }

    private void assertWeight(String expected, BigDecimal actual) {
        assertNotNull(actual);
        assertEquals(0, bd(expected).compareTo(actual), "expected " + expected + " but was " + actual);
    }

    private UserPreferenceWeightsRequest requestOf(String pantry, String cuisine, String nutrition, String freshness, String novelty) {
        return new UserPreferenceWeightsRequest(
            pantry == null ? null : bd(pantry),
            cuisine == null ? null : bd(cuisine),
            nutrition == null ? null : bd(nutrition),
            freshness == null ? null : bd(freshness),
            novelty == null ? null : bd(novelty)
        );
    }

    // asserts the request is rejected with a 400 and that nothing touched the database
    private void assertRejected(UserPreferenceWeightsRequest request) {
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceWeightsService.updateWeights(1, request)
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        verifyNoInteractions(userPreferenceWeightsRepository);
    }

    // ========== Get Weights Testing ==========

    @Test
    void getWeights_whenRowExists_returnsWeightsWithoutSaving() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.getWeights(1);

        // Assert
        assertWeight("0.40", response.pantryMatch());
        assertWeight("0.25", response.cuisine());
        assertWeight("0.10", response.nutrition());
        assertWeight("0.15", response.freshness());
        assertWeight("0.10", response.novelty());

        verify(userPreferenceWeightsRepository, never()).save(any());
    }

    @Test
    void getWeights_whenNoRow_createsDefaultsAndReturnsThem() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.empty());
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.getWeights(1);

        // Assert
        assertWeight("0.40", response.pantryMatch());
        assertWeight("0.25", response.cuisine());
        assertWeight("0.10", response.nutrition());
        assertWeight("0.15", response.freshness());
        assertWeight("0.10", response.novelty());

        ArgumentCaptor<UserPreferenceWeights> captor = ArgumentCaptor.forClass(UserPreferenceWeights.class);
        verify(userPreferenceWeightsRepository).save(captor.capture());

        UserPreferenceWeights saved = captor.getValue();
        assertEquals(1, saved.getUserId());
        assertEquals(0, saved.getStateVersion());
        assertWeight("0.40", saved.getPantryMatch());
        assertWeight("0.25", saved.getCuisine());
        assertWeight("0.10", saved.getNutrition());
        assertWeight("0.15", saved.getFreshness());
        assertWeight("0.10", saved.getNovelty());
    }

    @Test
    void getWeights_whenDefaultInsertLosesRace_returnsTheExistingRow() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.empty(), Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class)))
            .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.getWeights(1);

        // Assert
        assertWeight("0.40", response.pantryMatch());
        assertWeight("0.25", response.cuisine());
        verify(userPreferenceWeightsRepository, times(2)).findByUserId(1);
    }

    @Test
    void getWeights_whenInsertFailsAndRowStillMissing_throwsInternalServerError() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.empty(), Optional.empty());
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class)))
            .thenThrow(new DataIntegrityViolationException("some other constraint failed"));

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceWeightsService.getWeights(1)
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, ex.getStatusCode());
    }

    // ========== Update Weights Testing ==========

    @Test
    void updateWeights_whenRowExists_updatesValuesAndBumpsStateVersion() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.updateWeights(1, validRequest);

        // Assert
        assertWeight("0.50", response.pantryMatch());
        assertWeight("0.20", response.cuisine());
        assertWeight("0.10", response.nutrition());
        assertWeight("0.10", response.freshness());
        assertWeight("0.10", response.novelty());

        ArgumentCaptor<UserPreferenceWeights> captor = ArgumentCaptor.forClass(UserPreferenceWeights.class);
        verify(userPreferenceWeightsRepository).save(captor.capture());

        UserPreferenceWeights saved = captor.getValue();
        assertEquals(1, saved.getUserId());
        assertEquals(4, saved.getStateVersion());
        assertWeight("0.50", saved.getPantryMatch());
        assertWeight("0.20", saved.getCuisine());
    }

    @Test
    void updateWeights_whenNoRow_createsRowWithStateVersionZero() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.empty());
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.updateWeights(1, validRequest);

        // Assert
        assertWeight("0.50", response.pantryMatch());

        ArgumentCaptor<UserPreferenceWeights> captor = ArgumentCaptor.forClass(UserPreferenceWeights.class);
        verify(userPreferenceWeightsRepository).save(captor.capture());

        UserPreferenceWeights saved = captor.getValue();
        assertEquals(1, saved.getUserId());
        assertEquals(0, saved.getStateVersion());
        assertWeight("0.50", saved.getPantryMatch());
        assertWeight("0.20", saved.getCuisine());
        assertWeight("0.10", saved.getNutrition());
        assertWeight("0.10", saved.getFreshness());
        assertWeight("0.10", saved.getNovelty());
    }

    @Test
    void updateWeights_whenExistingStateVersionIsNull_treatsItAsZeroAndBumpsToOne() {
        // Arrange
        existingWeights.setStateVersion(null);
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        preferenceWeightsService.updateWeights(1, validRequest);

        // Assert 
        ArgumentCaptor<UserPreferenceWeights> captor = ArgumentCaptor.forClass(UserPreferenceWeights.class);
        verify(userPreferenceWeightsRepository).save(captor.capture());
        assertEquals(1, captor.getValue().getStateVersion());
    }

    @Test
    void updateWeights_roundsValuesToFourDecimalPlaces() {
        // Arrange
        UserPreferenceWeightsRequest request = requestOf("0.33333", "0.33333", "0.33334", "0", "0");
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        preferenceWeightsService.updateWeights(1, request);

        // Assert
        ArgumentCaptor<UserPreferenceWeights> captor = ArgumentCaptor.forClass(UserPreferenceWeights.class);
        verify(userPreferenceWeightsRepository).save(captor.capture());

        UserPreferenceWeights saved = captor.getValue();
        assertEquals(bd("0.3333"), saved.getPantryMatch());
        assertEquals(bd("0.3333"), saved.getCuisine());
        assertEquals(bd("0.3333"), saved.getNutrition());
        assertEquals(bd("0.0000"), saved.getFreshness());
        assertEquals(bd("0.0000"), saved.getNovelty());
    }

    // ========== Validation: accepted edge cases ==========

    @Test
    void updateWeights_withSingleWeightOfOneAndRestZero_isAccepted() {
        // Arrange
        UserPreferenceWeightsRequest request = requestOf("1", "0", "0", "0", "0");
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserPreferenceWeightsResponse response = preferenceWeightsService.updateWeights(1, request);

        // Assert
        assertWeight("1", response.pantryMatch());
        assertWeight("0", response.cuisine());
    }

    @Test
    void updateWeights_withSumExactlyAtUpperTolerance_isAccepted() {
        // Arrange
        UserPreferenceWeightsRequest request = requestOf("0.401", "0.25", "0.10", "0.15", "0.10");
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act and Assert
        assertDoesNotThrow(() -> preferenceWeightsService.updateWeights(1, request));
    }

    @Test
    void updateWeights_withSumExactlyAtLowerTolerance_isAccepted() {
        // Arrange
        UserPreferenceWeightsRequest request = requestOf("0.399", "0.25", "0.10", "0.15", "0.10");
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.of(existingWeights));
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act and Assert
        assertDoesNotThrow(() -> preferenceWeightsService.updateWeights(1, request));
    }

    // ========== Validation: rejected ==========

    @Test
    void updateWeights_withMissingWeight_throwsBadRequest() {
        // a missing key in the JSON body arrives as null
        assertRejected(requestOf("0.50", "0.20", "0.10", "0.20", null));
    }

    @Test
    void updateWeights_withMissingPantryMatch_throwsBadRequest() {
        assertRejected(requestOf(null, "0.20", "0.10", "0.10", "0.10"));
    }

    @Test
    void updateWeights_withNegativeWeight_throwsBadRequest() {
        assertRejected(requestOf("0.60", "0.30", "0.20", "0.10", "-0.20"));
    }

    @Test
    void updateWeights_withWeightAboveOne_throwsBadRequest() {
        assertRejected(requestOf("1.20", "-0.10", "-0.10", "0", "0"));
    }

    @Test
    void updateWeights_withSumTooHigh_throwsBadRequest() {
        assertRejected(requestOf("0.60", "0.30", "0.10", "0.10", "0.10"));
    }

    @Test
    void updateWeights_withSumTooLow_throwsBadRequest() {
        assertRejected(requestOf("0.40", "0.20", "0.10", "0.05", "0.05"));
    }

    @Test
    void updateWeights_withSumJustOutsideTolerance_throwsBadRequest() {
        assertRejected(requestOf("0.4011", "0.25", "0.10", "0.15", "0.10"));
    }

    // ========== Failure path ==========

    @Test
    void updateWeights_whenInsertLosesRace_throwsInternalServerError() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(1)).thenReturn(Optional.empty());
        when(userPreferenceWeightsRepository.save(any(UserPreferenceWeights.class)))
            .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> preferenceWeightsService.updateWeights(1, validRequest)
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, ex.getStatusCode());
    }
}