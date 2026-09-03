package com.mealchemy.engine.client;

/* Import classes */
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.LearningUpdateResponse;
import com.mealchemy.engine.dto.LearningUpdateRequest;

/* Import libraries */
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.http.MediaType;

@Component
public class EngineClient {
    private final RestClient engineRestClient;

    public EngineClient(RestClient engineRestClientIn)
    {
        this.engineRestClient = engineRestClientIn;
    }

    public RecommendationResponse getRecommendations(RecommendationRequest request)
    {
        return engineRestClient.post()
            .uri("/recommendations")
            .contentType(MediaType.APPLICATION_JSON)
            .accept(MediaType.APPLICATION_JSON)
            .body(request)
            .retrieve()
            .onStatus(status -> status.value() == 400, (req, res) -> {
            String body = new String(res.getBody().readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
            throw new IllegalStateException("Engine rejected candidate pool: " + body);
            })
            .body(RecommendationResponse.class);
    }

    public LearningUpdateResponse updateLearning(LearningUpdateRequest request)
    {
        return engineRestClient.post()
            .uri("/learning/update")
            .contentType(MediaType.APPLICATION_JSON)
            .accept(MediaType.APPLICATION_JSON)
            .body(request)
            .retrieve()
            .onStatus(status -> status.value() == 409, (req, res) -> {
                throw new StaleStateException("state_version mismatch on learning update.");
            })
            .onStatus(status -> status.value() == 400, (req, res) -> {
                throw new InvalidSwipeException("Engine rejected one or more swipes in the batch.");
            })
            .body(LearningUpdateResponse.class);
    }
}
