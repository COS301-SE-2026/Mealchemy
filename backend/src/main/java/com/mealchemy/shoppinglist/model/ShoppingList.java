// ShoppingList model maps directly to shopping_list table - one field per column

package com.mealchemy.shoppinglist.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;

import com.mealchemy.shared.enums.ShoppingListStatus;


@Entity
@Table(name = "shopping_lists")
public class ShoppingList {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "shopping_list_id")
    private Integer shoppingListId;

    @Column(name = "user_id", nullable = false) //a user will appear more than once in the table (user1 has multiple shopping lists)
    private Integer userId;

    @Column(name = "name", nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "status", nullable = false, columnDefinition = "shopping_list_status_enum")
    private ShoppingListStatus status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;


    // Getters and Setters
    public Integer getShoppingListId() {
        return shoppingListId;
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

    public ShoppingListStatus getStatus() {
        return status; 
    }
    
    public void setStatus(ShoppingListStatus status) {
        this.status = status;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
}
