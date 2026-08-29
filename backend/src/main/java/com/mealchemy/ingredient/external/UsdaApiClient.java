package com.mealchemy.ingredient.external;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component // no business logic
public class UsdaApiClient {
    private final RestClient restClient;
    private final String apiKey;

    public UsdaApiClient(RestClient.Builder restClientBuilder, @Value("${usda.api.base-url}") String baseUrl, @Value("${usda.api.key}") String apiKey) {
        this.restClient = RestClient.builder().baseUrl(baseUrl).build();
        this.restClient = restClient;
        this.apiKey = apiKey;
    }

    public UsdaSearchResponse searchFoods(String query) {
        try {
            UsdaSearchResponse response = restClient.get().uri(uriBuilder -> uriBuilder.path("/foods/search")
                                                                                        .queryParam("query", query)
                                                                                        .queryParam("api_key", apiKey)
                                                                                        .build())
                                                            .retrieve()
                                                            .body(UsdaSearchResponse.class);

            if (response == null) {
                throw new NutritionProviderException("USDA search returned an empty response body");
            }
            return response;
        }
        catch (RestClientException e) {
            throw new NutritionProviderException("USDA search request failed for query: " + query, e);
        }
    }

    public UsdaFoodDetail getFoodDetails(String fdcId) {
        try {
            UsdaFoodDetail foodDetail = restClient.get().uri(uriBuilder -> uriBuilder.path("/food/{fdcId}")
                                                                                        .queryParam("api_key", apiKey)
                                                                                        .build(fdcId))
                                                            .retrieve()
                                                            .body(UsdaFoodDetail.class);
        
            if (foodDetail == null) {
                throw new NutritionProviderException("USDA detail lookup returned an empty response body");
            }
            return foodDetail;
        }
        catch (RestClientException e) {
            throw new NutritionProviderException("USDA detail request failed for fdcId: " + fdcId, e);
        }
    }
}