package com.mealchemy.unit.dto;

import com.mealchemy.shared.enums.MeasurementSystem;

import com.fasterxml.jackson.annotation.JsonProperty;

public record UnitOfMeasurementResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    @JsonProperty("unit_id") Integer unitId,
    String name,
    MeasurementSystem system
) {}