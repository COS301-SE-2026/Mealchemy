package com.mealchemy.shoppinglist.dto;
package com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.OffsetDateTime;

public record UpdateShoppingListItemRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has

   //get specified shopping list from URL therefore not in request body
    @JsonProperty("ing_id") Integer ingId,
    String name,
    BigDecimal quantity,
    String unit,
    Boolean purchased
) {}