package com.mealchemy.shoppinglist.dto;
package com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.OffsetDateTime;
import java.math.BigDecimal;

public record ShoppingListResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    @JsonProperty("shopping_list_id") Integer shoppingListId,
    @JsonProperty("user_id") Integer userId,
    String name,
    ShoppingListStatus status,
    @JsonProperty("created_at") OffsetDateTime createdAt,
    List<ShoppingListItemResponse> items
) {}