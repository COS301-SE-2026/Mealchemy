package com.mealchemy.ingredient.service;

public class CategoryRequiredException extends RuntimeException {
    private final String sourceId;
    private final String name;

    public CategoryRequiredException(String sourceId, String name) {
        super("USDA did not give a category for this ingredient - user must pick one manually");
        this.sourceId = sourceId;
        this.name = name;
    }

    public String getSourceId() {
        return sourceId;
    }

    public String getName() {
        return name;
    }
}