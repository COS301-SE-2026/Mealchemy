package com.mealchemy;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class MealchemyApplicationIntegrationTest {

    @Test
    void applicationContextLoads() {
        // Verifies the full Spring context starts without errors against a real database.
        // Requires SPRING_DATASOURCE_* env vars, set automatically by CI (ci.yml postgres service).
    }
}
