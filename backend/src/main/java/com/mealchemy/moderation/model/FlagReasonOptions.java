// FlagReasonOption model maps directly to the flag_reason_options table 

package com.mealchemy.moderation.model;

import jakarta.persistence.*;

@Entity 
@Table(name = "flag_reason_options")
public class FlagReasonOptions {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reason_id")
    private Integer reasonId;

    @Column(name = "value", nullable = false, unique = true)
    private String value;

    @Column(name = "label", nullable = false)
    private String label;

    @Column(name = "sort_order")
    private Integer sortOrder;


    // Getters
    public Integer getReasonId() {
        return reasonId;
    }

    public String getValue() {
        return value;
    }

    public String getLabel() {
        return label;
    }
    
    public Integer getSortOrder() {
        return sortOrder;
    }
    
    // Setters
    public void setValue(String valueIn) {
        value = valueIn;
    }

    public void setLabel(String labelIn) {
        label = labelIn;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
    
}
