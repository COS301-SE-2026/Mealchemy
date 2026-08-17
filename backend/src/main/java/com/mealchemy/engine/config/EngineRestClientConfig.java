package com.mealchemy.engine.config;

/* Import classes */

/* Import libraries */
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;
import org.springframework.http.client.SimpleClientHttpRequestFactory;

@Configuration
public class EngineRestClientConfig {
    
    @Bean
    public RestClient engineRestClient(EngineProperties engineProperties)
    {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(engineProperties.getTimeoutMs());
        requestFactory.setReadTimeout(engineProperties.getTimeoutMs());

        return RestClient.builder()
            .baseUrl(engineProperties.getUrl())
            .requestFactory(requestFactory)
            .build();
    }
}
