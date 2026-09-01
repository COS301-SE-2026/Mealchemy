// ExternalLinks model maps directly to external_links table - one field per column

package com.mealchemy.externallinks.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "external_links")
public class ExternalLink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "link_id")
    private Integer linkId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "url", nullable = false)
    private String url;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    // constructors for testing
    public ExternalLink() {

    }

    public ExternalLink(Integer linkId, Integer userId, String name, String url) {
        this.linkId = linkId;
        this.userId = userId;
        this.name = name;
        this.url = url;
    }

    // Getters and setters
    public Integer getLinkId() { 
        return linkId; 
    }

    public Integer getUserId() { 
        return userId; 
    }

    public void setUserId(Integer id) { 
        this.userId = id; 
    }

    public String getName() { 
        return name; 
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public String getUrl() { 
        return url; 
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() { 
        return updatedAt; 
    }

    public void setUpdatedAt(OffsetDateTime time) { 
        this.updatedAt = time; 
    }
}