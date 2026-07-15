package com.mealchemy.cuisinetype.model;

/* Import libraries */

import jakarta.persistence.*;
import java.util.*;
import org.hibernate.annotations.*;

/* Import classes */

@Entity
@Table(name = "flavour_profile_options")
public class FlavourProfileOptions
{
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "value", nullable = false, unique = true)
    private String value;

    @Column(name = "label", nullable = false)
    private String label;

    /* Getters */

    public int getId()
    {
        return id;
    }

    public String getValue()
    {
        return value;
    }

    public String getLabel()
    {
        return label;
    }

    /* Setters */

    public void setValue(String valueIn)
    {
        value = valueIn;
    }

    public void setLabel(String labelIn)
    {
        label = labelIn;
    }
}