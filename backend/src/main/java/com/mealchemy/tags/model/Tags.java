package com.mealchemy.tags.model;

/* Import classes */

/* Import libraries */
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;

@Entity
@Table(name = "tags")
public class Tags {
    /* Declaring fields */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tag_id")
    private Integer tagId;

    @Column(name = "tag_name")
    private String tagName;

    @Column(name = "is_active")
    private Boolean isActive;

    @Column(name = "is_dietary")
    private Boolean isDietary;

    /* Getters */

    public Integer getTagId()
    {
        return tagId;
    }

    public String getTagName()
    {
        return tagName;
    }

    public Boolean getIsActive()
    {
        return isActive;
    }

    public Boolean getIsDietary()
    {
        return isDietary;
    }

    /* Setters */

    public void setTagName(String tagNameIn)
    {
        this.tagName = tagNameIn;
    }

    public void setIsActive(Boolean isActiveIn)
    {
        this.isActive = isActiveIn;
    }

    public void setIsDietary(Boolean isDietaryIn)
    {
        this.isDietary = isDietaryIn;
    }
}
