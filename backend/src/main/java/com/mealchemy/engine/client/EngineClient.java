package com.mealchemy.engine.client;

/* Import classes */
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.RecommendationRequest;

/* Import libraries */
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

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
            .body(request)
            .retrieve()
            .onStatus(status -> status.value() == 422, (req, res) -> {
                throw new EmptyPoolException("No recipes remain in the pool after hard-filtering.");
            })
            .onStatus(status -> status.value() == 400, (req, res) -> {
                throw new IllegalStateException("Engine rejected candidate pool (problematic DTO assembly).");
            })
            .body(RecommendationResponse.class);
    }
}
