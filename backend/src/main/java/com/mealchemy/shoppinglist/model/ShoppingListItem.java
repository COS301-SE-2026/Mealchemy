// ShoppingListItems model maps directly to shopping_list_items table - one field per column

package com.mealchemy.shoppinglist.model;

import jakarta.persistence.*;
import java.math.BigDecimal;


@Entity
@Table(name = "shopping_list_items")
public class ShoppingListItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "item_id")
    private Integer itemId;

    @Column(name = "shopping_list_id", nullable = false)
    private Integer shoppingListId;

    @Column(name = "ing_id") //references ingredient catalogue
    private Integer ingId;

    @Column(name = "name") // only used when ing_id is false - users own typed addition
    private String name;

    @Column(name = "quantity") 
    private BigDecimal quantity;

    @Column(name = "unit") //CHECK
    private String unit;

    @Column(name = "purchased", nullable = false)
    private Boolean purchased;


    // Getters and Setters
    public Integer getItemId() {
        return itemId;
    }

    public Integer getShoppingListId() {
        return shoppingListId;
    }

    public void setShoppingListId(Integer id) {
        this.shoppingListId = id;
    }

    public Integer getIngId() {
        return ingId;
    }

    public void setIngId(Integer id) {
        this.ingId = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quant) {
        this.quantity = quant;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unt) {
        this.unit = unt;
    }

    public Boolean getPurchased() {
        return purchased;
    }

    public void setPurchased(Boolean purchased) {
        this.purchased = purchased;
    }
}