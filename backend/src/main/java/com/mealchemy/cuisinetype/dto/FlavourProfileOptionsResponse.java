package com.mealchemy.cuisinetype.dto;

/* Import libraries */

/* Import classes */

import com.mealchemy.cuisinetype.model.FlavourProfileOptions;

public record FlavourProfileOptionsResponse(
    String value,
    String label
)
{
    public static FlavourProfileOptionsResponse from (FlavourProfileOptions flavourProfileOptions)
    {
        return new FlavourProfileOptionsResponse(
            flavourProfileOptions.getValue(),
            flavourProfileOptions.getLabel()
        );
    }
}
