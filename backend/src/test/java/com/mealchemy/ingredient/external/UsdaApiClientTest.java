package com.mealchemy.ingredient.external;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import static org.hamcrest.Matchers.containsString;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

public class UsdaApiClientTest {
    
    private UsdaApiClient usdaApiClient;
    private MockRestServiceServer mockServer;

    @BeforeEach
    void setUp() {
        // Setting up mock server
        RestClient.Builder builder = RestClient.builder();
        mockServer = MockRestServiceServer.bindTo(builder).build();
        usdaApiClient = new UsdaApiClient(builder, "https://api.nal.usda.gov/fdc/v1", "test_api_key");
    }

    @Test 
    void searchFoods_RealJsonResponse() {
        // Arrange
        String jsonResponse = """
                {
                    "foods": [
                        {
                            "fdcId": 2710077,
                            "description": "Kimchi",
                            "dataType": "Branded",
                            "foodNutrients": [
                                { "number": 1008, "name": "Energy", "amount": 15.0, "unitName": "KCAL" }
                            ]
                        }
                    ]
                }
                """;

        mockServer.expect(requestTo(containsString("foods/search"))).andRespond(withSuccess(jsonResponse, MediaType.APPLICATION_JSON));

        // Act 
        UsdaSearchResponse response = usdaApiClient.searchFoods("Kimchi");

        // Assert
        assertEquals(1, response.foods().size());
        assertEquals("Kimchi", response.foods().get(0).description());
        assertEquals(1008, response.foods().get(0).foodNutrients().get(0).number());
        mockServer.verify();       
    }

    @Test 
    void getFoodDetails_RealJsonResponseCategoryAndNutrients() {
        // Arrange
        String jsonResponse = """
                {
                    "fdcId": 2710077,
                    "description": "Kimchi",
                    "dataType": "Foundation",
                    "foodCategory": { "id": 11, "code": "1100", "description": "Vegetables and Vegetable Products" },
                    "foodNutrients": [
                        { "amount": 15.0, "nutrient": { "number": "1008", "name": "Energy", "unitName": "KCAL" } }
                    ]
                }
                """;

        mockServer.expect(requestTo(containsString("food/2710077"))).andRespond(withSuccess(jsonResponse, MediaType.APPLICATION_JSON));

        // Act 
        UsdaFoodDetail foodDetails = usdaApiClient.getFoodDetails("2710077");

        // Assert
        assertEquals("Kimchi", foodDetails.description());
        assertEquals("Vegetables and Vegetable Products", foodDetails.foodCategory().description());
        mockServer.verify();       
    }


    @Test 
    void searchFoods_usdaServerError_throwNutritionalProviderException() {
        // Arrange
        mockServer.expect(requestTo(containsString("foods/search"))).andRespond(withServerError());

        //Assert
        asserThrows(NutritionalProviderException.class, () -> usdaApiClient.searchFoods("Kimchi"));      
    }

}


