package com.mealchemy.engine.config;

/* Import libraries */
import org.springframework.http.client.*;
import com.google.auth.oauth2.GoogleCredentials;
import java.io.IOException;
import org.springframework.http.HttpRequest;        
import com.google.auth.oauth2.IdTokenCredentials;
import com.google.auth.oauth2.IdTokenProvider;

/* Import classes */

public class EngineAuthInterceptor implements ClientHttpRequestInterceptor {
    private final String audience;
    private volatile IdTokenCredentials cachedCredentials;

    public EngineAuthInterceptor(String audience)
    {
        this.audience = audience;
    }

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution) throws IOException
    {
        request.getHeaders().setBearerAuth(getIdToken());
        return execution.execute(request, body);
    }

    private String getIdToken() throws IOException 
    {
        if (cachedCredentials == null)
        {
            synchronized (this) 
            {
                if (cachedCredentials == null)
                {
                    GoogleCredentials sourceCredentials = GoogleCredentials.getApplicationDefault();
                    cachedCredentials = IdTokenCredentials.newBuilder()
                        .setIdTokenProvider((IdTokenProvider) sourceCredentials)
                        .setTargetAudience(audience)
                        .build();
                }
            }
        }

        cachedCredentials.refreshIfExpired();
        return cachedCredentials.getIdToken().getTokenValue();
    }
}
