package com.mealchemy.shoppinglist.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record DeleteBatchItemsRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("item_ids") List<Integer> itemIds
    
) {}