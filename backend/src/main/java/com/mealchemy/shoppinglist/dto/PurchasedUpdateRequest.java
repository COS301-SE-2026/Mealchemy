package com.mealchemy.shoppinglist.dto;
package com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.OffsetDateTime;

public record PurchasedUpdateRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has

   //get specified shopping list and item from URL therefore not in request body
    Boolean purchased
) {}