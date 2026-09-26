package com.mealchemy.shared.enums;

/* Import libraries */
import java.time.LocalTime;

public enum MealSlot
{
    BREAKFAST(LocalTime.of(5, 0), LocalTime.of(11, 0)),
    LUNCH(LocalTime.of(11, 0), LocalTime.of(16, 0)),
    DINNER(LocalTime.of(16, 0), LocalTime.of(23, 0)),
    SNACK(null, null);

    private final LocalTime earliest;
    private final LocalTime latest;

    MealSlot(LocalTime earliest, LocalTime latest)
    {
        this.earliest = earliest;
        this.latest = latest;
    }

    boolean allows(LocalTime time)
    {
        if (earliest == null || latest == null)
        {
            return true;
        }

        return !time.isBefore(earliest) && !time.isAfter(latest);
    }
}