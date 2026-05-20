// Preference response that is sent to flutter

package com.mealchemy.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record PreferenceResponse( //records are immutable and auto generate constructors
    @JsonProperty("dietary_restrictions") List<String> dietaryRestrictions,
    List<String> allergies,
    @JsonProperty("disliked_ingredients") List<String> dislikedIngredients,
    @JsonProperty("flavour_profile") List<String> flavourProfile    
) {}
