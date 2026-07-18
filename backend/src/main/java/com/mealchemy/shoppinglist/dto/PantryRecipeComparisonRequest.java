package com.mealchemy.shoppinglist.dto;
package com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record PantryRecipeComparisonRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    String name,
    Boolean include_available_pantry_items 
) {}