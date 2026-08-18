// IngredientCatalogue model maps directly to the ingredient_catalogue table 

package com.mealchemy.ingredient.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;


@Entity 
@Table(name = "ingredient_catalogue")
public class IngredientCatalogue {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ing_id")
    private Integer ingId;

    @Column(name = "category_id", nullable = false)
    private Integer categoryId;

    @Column(name = "name", nullable = false, unique = true, length = 200)
    private String name;

    @Column(name = "calories_kcal")
    private Integer caloriesKCal;

    @Column(name = "protein_g")
    private BigDecimal proteinG;

    @Column(name = "carbs_g")
    private BigDecimal carbsG;

    @Column(name = "fat_g")
    private BigDecimal fatG;

    @Column(name = "fibre_g")
    private BigDecimal fibreG;

    @Column(name = "sodium_mg")
    private BigDecimal sodiumMg;

    @Column(name = "source_api", length = 40)
    private String sourceApi;

    @Column(name = "source_id")
    private String sourceId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    // Getters and Setters
    public Integer getIngId() {
        return ingId;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer id) {
        this.categoryId = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getCalories() {
        return caloriesKCal;
    }

    public void setCalories(Integer cals) {
        this.caloriesKCal= cals;
    }

    public BigDecimal getProtein() {
        return proteinG;
    }

    public void setProtein(BigDecimal protein) {
        this.proteinG = protein;
    }

    public BigDecimal getCarbs() {
        return carbsG;
    }

    public void setCarbs(BigDecimal carbs) {
        this.carbsG = carbs;
    }

    public BigDecimal getFat() {
        return fatG;
    }

    public void setFat(BigDecimal fat) {
        this.fatG = fat;
    }

    public BigDecimal getFibre() {
        return fibreG;
    }

    public void setFibre(BigDecimal fibre) {
        this.fibreG = fibre;
    }

    public BigDecimal getSodium() {
        return sodiumMg;
    }

    public void setSodium(BigDecimal sodium) {
        this.sodiumMg = sodium;
    }

    public String getSourceApi() {
        return sourceApi;
    }

    public void setSourceApi(String source) {
        this.sourceApi = source;
    }

    public String getSourceId() {
        return sourceId;
    }

    public void setSourceId(String source) {
        this.sourceId = source;
    }
    
    public OffsetDateTime getCreatedAt() { 
        return createdAt; 
    }
    
}
