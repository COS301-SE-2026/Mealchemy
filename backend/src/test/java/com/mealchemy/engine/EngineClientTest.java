package com.mealchemy.engine;

// class under test
import com.mealchemy.engine.client.EngineClient;
import com.mealchemy.engine.client.EmptyPoolException;
import com.mealchemy.engine.client.InvalidSwipeException;
import com.mealchemy.engine.client.StaleStateException;

// dtos
import com.mealchemy.engine.dto.LearningUpdateRequest;
import com.mealchemy.engine.dto.PreferenceWeightsRequest;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.UserStateRequest;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withBadRequest;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;

class EngineClientTest {

    private static final String BASE_URL = "http://engine-test";

    private MockRestServiceServer mockServer;
    private EngineClient engineClient;

    @BeforeEach
    void setUp() {
        RestClient.Builder builder = RestClient.builder().baseUrl(BASE_URL);
        mockServer = MockRestServiceServer.bindTo(builder).build();
        engineClient = new EngineClient(builder.build());
    }

    private RecommendationRequest minimalRecommendationRequest() {
        PreferenceWeightsRequest weights = new PreferenceWeightsRequest(
            new BigDecimal("0.30"), new BigDecimal("0.20"), new BigDecimal("0.20"),
            new BigDecimal("0.15"), new BigDecimal("0.15")
        );
        UserStateRequest userState = new UserStateRequest(
            1, List.of(), List.of(), List.of(), List.of(), weights, Map.of(), List.of(), List.of()
        );
        return new RecommendationRequest(userState, List.of(), 10, List.of(), null);
    }

    private LearningUpdateRequest minimalLearningUpdateRequest() {
        PreferenceWeightsRequest weights = new PreferenceWeightsRequest(
            new BigDecimal("0.30"), new BigDecimal("0.20"), new BigDecimal("0.20"),
            new BigDecimal("0.15"), new BigDecimal("0.15")
        );
        return new LearningUpdateRequest(weights, Map.of(), List.of(), 1);
    }

    // ========== getRecommendations ==========

    @Test
    void getRecommendations_on422_throwsEmptyPoolException() {
        mockServer.expect(requestTo(BASE_URL + "/recommendations"))
            .andRespond(withStatus(HttpStatus.UNPROCESSABLE_ENTITY)
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error_code\":\"EMPTY_POOL\",\"message\":\"No candidates remain after hard filtering.\"}"));

        assertThrows(EmptyPoolException.class,
            () -> engineClient.getRecommendations(minimalRecommendationRequest()));
    }

    @Test
    void getRecommendations_on400_throwsIllegalStateExceptionContainingEngineBody() {
        String errorBody = "{\"error_code\":\"INVALID_CANDIDATE\",\"message\":\"ingredients: field required\"}";
        mockServer.expect(requestTo(BASE_URL + "/recommendations"))
            .andRespond(withBadRequest()
                .contentType(MediaType.APPLICATION_JSON)
                .body(errorBody));

        IllegalStateException ex = assertThrows(IllegalStateException.class,
            () -> engineClient.getRecommendations(minimalRecommendationRequest()));
        assertTrue(ex.getMessage().contains("ingredients"));
    }

    @Test
    void getRecommendations_on200_returnsParsedResponse() {
        String body = "{\"recommendations\":[],\"cuisine_allocation\":{},"
            + "\"total_candidates_after_filter\":0,\"total_recipes_considered\":0}";
        mockServer.expect(requestTo(BASE_URL + "/recommendations"))
            .andRespond(withStatus(HttpStatus.OK)
                .contentType(MediaType.APPLICATION_JSON)
                .body(body));

        RecommendationResponse response = engineClient.getRecommendations(minimalRecommendationRequest());

        assertTrue(response.recommendations().isEmpty());
    }

    // ========== updateLearning ==========

    @Test
    void updateLearning_on409_throwsStaleStateException() {
        mockServer.expect(requestTo(BASE_URL + "/learning/update"))
            .andRespond(withStatus(HttpStatus.CONFLICT)
                .contentType(MediaType.APPLICATION_JSON)
                .body("{}"));

        assertThrows(StaleStateException.class,
            () -> engineClient.updateLearning(minimalLearningUpdateRequest()));
    }

    @Test
    void updateLearning_on400_throwsInvalidSwipeException() {
        mockServer.expect(requestTo(BASE_URL + "/learning/update"))
            .andRespond(withBadRequest()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error_code\":\"INVALID_SWIPE\",\"message\":\"swipes.0.recipe_id: field required\"}"));

        assertThrows(InvalidSwipeException.class,
            () -> engineClient.updateLearning(minimalLearningUpdateRequest()));
    }
}