package com.mealchemy.engine.config;

/* Import classes */

/* Import libraries */

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "engine")
public class EngineProperties {
    /* Declaring variables */

    private String url;
    private int timeoutMs = 5000;

    /* Getters */

    public String getUrl()
    {
        return url;
    }

    public int getTimeoutMs()
    {
        return timeoutMs;
    }

    /* Setters */

    public void setUrl(String urlIn)
    {
        this.url = urlIn;
    }

    public void setTimeoutMs(int timeoutMsIn)
    {
        this.timeoutMs = timeoutMsIn;
    }
}
