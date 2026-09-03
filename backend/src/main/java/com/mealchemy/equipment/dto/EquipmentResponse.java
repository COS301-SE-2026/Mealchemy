package com.mealchemy.equipment.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EquipmentResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    @JsonProperty("id") Integer equipmentId,
    String value,
    String label
) {}