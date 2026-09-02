package com.mealchemy.engine.config;

/* Import classes */

/* Import libraries */
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;

@Configuration
public class EngineRestClientConfig {
    
    @Bean
    public RestClient engineRestClient(EngineProperties engineProperties, Environment environment)
    {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(engineProperties.getTimeoutMs());
        requestFactory.setReadTimeout(engineProperties.getTimeoutMs());

        RestClient.Builder builder = RestClient.builder()
            .baseUrl(engineProperties.getUrl())
            .requestFactory(requestFactory);
        
        if (!environment.acceptsProfiles(Profiles.of("local")))
        {
            builder.requestInterceptor(new EngineAuthInterceptor(engineProperties.getUrl()));
        }

        return builder.build(); 
    }
}
