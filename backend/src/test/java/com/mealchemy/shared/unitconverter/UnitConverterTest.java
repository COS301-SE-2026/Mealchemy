package com.mealchemy.shared.unitconverter;

import com.mealchemy.shared.enums.PreferredUnit;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import java.math.BigDecimal;

class UnitConverterTest {

    @Test
    void convert_grams_to_kilograms() {
        BigDecimal result = UnitConverter.convert(BigDecimal.valueOf(1000), "g", "kg");
        assertEquals(0, result.compareTo(BigDecimal.valueOf(1.000)));
    }

    @Test
    void convert_grams_to_oz() {
        BigDecimal result = UnitConverter.convert(BigDecimal.valueOf(28.3495), "g", "oz");
        assertEquals(0, result.compareTo(BigDecimal.valueOf(1.000)));
    }

    @Test 
    void convert_ThrowsIncompatibleTypes() {
        assertThrows(IllegalArgumentException.class, () -> UnitConverter.convert(BigDecimal.valueOf(1000), "g", "cup"));
    }

    @Test
    void convert_ThrowsUnknownUnit() {
        assertThrows(IllegalArgumentException.class, () -> UnitConverter.convert(BigDecimal.valueOf(1000), "g", "unknown"));
    }

    @Test
    void normaliseImperialWeightToGrams() {
        UnitConverter.NormalisedQuantity result = UnitConverter.normaliseIngredient(BigDecimal.ONE, "lb");
        assertEquals("g", result.unit());
        assertEquals(0, result.quantity().compareTo(BigDecimal.valueOf(453.592)));
    }

    @Test
    void normaliseGeneralUnit() {
        UnitConverter.NormalisedQuantity result = UnitConverter.normaliseIngredient(BigDecimal.ONE, "clove");
        assertEquals("clove", result.unit());
        assertEquals(0, result.quantity().compareTo(BigDecimal.valueOf(1)));
    }

    @Test
    void convertToPreferred_gramsStaysGrams() {
        UnitConverter.NormalisedQuantity result = UnitConverter.convertToUsersPreferredUnit(BigDecimal.valueOf(500), "g", PreferredUnit.METRIC);
        assertEquals("g", result.unit());
        assertEquals(0, result.quantity().compareTo(BigDecimal.valueOf(500)));
    }

    @Test
    void convertToPreferred_gramsToKgs() {
        UnitConverter.NormalisedQuantity result = UnitConverter.convertToUsersPreferredUnit(BigDecimal.valueOf(1500), "g", PreferredUnit.METRIC);
        assertEquals("kg", result.unit());
        assertEquals(0, result.quantity().compareTo(BigDecimal.valueOf(1.5)));
    }

    @Test
    void convertToPreferred_gramsToOunces() {
        UnitConverter.NormalisedQuantity result = UnitConverter.convertToUsersPreferredUnit(BigDecimal.valueOf(100), "g", PreferredUnit.IMPERIAL);
        assertEquals("oz", result.unit());
    }

    @Test
    void convertToPreferred_gramsToLbs() {
        UnitConverter.NormalisedQuantity result = UnitConverter.convertToUsersPreferredUnit(BigDecimal.valueOf(500), "g", PreferredUnit.IMPERIAL);
        assertEquals("lb", result.unit());
    }

    @Test
    void convertToPreferred_generalRegardlessOfPreferrence() {
        UnitConverter.NormalisedQuantity result = UnitConverter.convertToUsersPreferredUnit(BigDecimal.valueOf(3), "clove", PreferredUnit.IMPERIAL);
        assertEquals("clove", result.unit());
        assertEquals(0, result.quantity().compareTo(BigDecimal.valueOf(3)));
    }

}