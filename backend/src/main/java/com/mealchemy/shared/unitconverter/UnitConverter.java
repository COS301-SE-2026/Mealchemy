package com.mealchemy.shared.unitconverter;

import com.mealchemy.shared.enums.PreferredUnit;

import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;


public class UnitConverter {
    
    // ========== Conversion Factors (Base unit - g or ml) ==========
    // How many base units is this unit

    // Weight units
    private static final BigDecimal G_TO_G = BigDecimal.ONE;
    private static final BigDecimal KG_TO_G = BigDecimal.valueOf(1000);
    private static final BigDecimal OZ_TO_G = BigDecimal.valueOf(28.3495);
    private static final BigDecimal LB_TO_G = BigDecimal.valueOf(453.592);

    // Volume units
    private static final BigDecimal ML_TO_ML = BigDecimal.ONE;
    private static final BigDecimal L_TO_ML = BigDecimal.valueOf(1000);
    private static final BigDecimal CUP_TO_ML = BigDecimal.valueOf(236.588);
    private static final BigDecimal FL_OZ_TO_ML = BigDecimal.valueOf(29.5735);

    private static final int SCALE = 3; //to round to decimal val for db

    // ========== For Normalisation ==========
    // quantity and format of a normalised ingredient and quantity
    public record NormalisedQuantity(BigDecimal quantity, String unit) {};

    private static final List<String> weightUnits = List.of("g", "kg", "lb", "oz");
    private static final List<String> volumeUnits = List.of("ml", "l", "cup", "fl_oz");

    // ========== Conversion Methods ==========

    // Convert an unit to system's base unit
    private static BigDecimal convertToBase(BigDecimal quantity, String unit) {
        return switch (unit.toLowerCase()) {
            case "g" -> quantity.multiply(G_TO_G);
            case "kg" -> quantity.multiply(KG_TO_G);
            case "oz" -> quantity.multiply(OZ_TO_G);  
            case "lb" -> quantity.multiply(LB_TO_G);
            case "ml" -> quantity.multiply(ML_TO_ML);  
            case "l" -> quantity.multiply(L_TO_ML);
            case "cup" -> quantity.multiply(CUP_TO_ML);
            case "fl_oz" -> quantity.multiply(FL_OZ_TO_ML);
            default -> throw new IllegalArgumentException("Unit not convertible:" + unit);
        };
    }


    // convert base unit (g or ml) to target unit
    private static BigDecimal convertToTarget(BigDecimal  baseQuantity, String unit) {
        return switch (unit.toLowerCase()) {
            case "g" -> baseQuantity.divide(G_TO_G, SCALE, RoundingMode.HALF_UP);
            case "kg" -> baseQuantity.divide(KG_TO_G, SCALE, RoundingMode.HALF_UP);
            case "oz" -> baseQuantity.divide(OZ_TO_G, SCALE, RoundingMode.HALF_UP);  
            case "lb" -> baseQuantity.divide(LB_TO_G, SCALE, RoundingMode.HALF_UP);
            case "ml" -> baseQuantity.divide(ML_TO_ML, SCALE, RoundingMode.HALF_UP);  
            case "l" -> baseQuantity.divide(L_TO_ML, SCALE, RoundingMode.HALF_UP);
            case "cup" -> baseQuantity.divide(CUP_TO_ML, SCALE, RoundingMode.HALF_UP);
            case "fl_oz" -> baseQuantity.divide(FL_OZ_TO_ML, SCALE, RoundingMode.HALF_UP);
            default -> throw new IllegalArgumentException("Unit not convertible:" + unit);
        };
    }


    private static String typeOfUnit(String unit) {
        String lowercaseUnit = unit.toLowerCase();
        if (weightUnits.contains(lowercaseUnit)) {
            return "WEIGHT";
        }
        else if (volumeUnits.contains(lowercaseUnit)) {
            return "VOLUME";
        }
        else {
            throw new IllegalArgumentException("Unit not convertible:" + unit);
        }
    }

    // public convert that is actually called
    public static BigDecimal convert(BigDecimal quantity, String fromUnit, String toUnit) {
        String typeFrom = typeOfUnit(fromUnit);
        String typeTo = typeOfUnit(toUnit);

        // can't convert weight to volume unit (vice versa)
        if (!typeFrom.equals(typeTo)) {
            throw new IllegalArgumentException("Unable to convert incompatible weight and volume types");
        }

        BigDecimal baseValue = convertToBase(quantity, fromUnit);
        return convertToTarget(baseValue, toUnit);
    }

    
    public static NormalisedQuantity normaliseIngredient(BigDecimal ogQuantity, String unit) {
        if (weightUnits.contains(unit.toLowerCase())) {
            return new NormalisedQuantity(convert(ogQuantity, unit, "g"), "g");
        }
        else if (volumeUnits.contains(unit.toLowerCase())) {
            return new NormalisedQuantity(convert(ogQuantity, unit, "ml"), "ml");
        }
        else { // is in general category - no conversion needed
            return new NormalisedQuantity(ogQuantity, unit);
        }
    }

    // for get requests - displays to quanity and unit in users preferred system
    public static NormalisedQuantity convertToUsersPreferredUnit(BigDecimal normalisedQuantity, String unit, PreferredUnit preferredMeasurementSystem) {
        if (preferredMeasurementSystem == PreferredUnit.METRIC) { 
            // will either be in grams or kg
            if (weightUnits.contains(unit.toLowerCase())) { 
                if (normalisedQuantity.compareTo(BigDecimal.valueOf(1000)) >= 0) { // quantity greater than 1000g - convert to kg
                    return new NormalisedQuantity(convert(normalisedQuantity, unit, "kg"), "kg");
                }
                // less than 1000 - keep in grams
                return new NormalisedQuantity(convert(normalisedQuantity, unit, "g"), "g");
            }
            // will be ml or l
            if (volumeUnits.contains(unit.toLowerCase())) {
                if (normalisedQuantity.compareTo(BigDecimal.valueOf(1000)) >= 0) { // quantity greater than 1000ml - convert to l
                    return new NormalisedQuantity(convert(normalisedQuantity, unit, "l"), "l");
                }
                // less than 1000 - keep in ml
                return new NormalisedQuantity(convert(normalisedQuantity, unit, "ml"), "ml");
            }
        }
        else if (preferredMeasurementSystem == PreferredUnit.IMPERIAL) { 
            // will either be in lb or oz
            if (weightUnits.contains(unit.toLowerCase())) { 
                BigDecimal ounces = convert(normalisedQuantity, unit, "oz");
                if (ounces.compareTo(BigDecimal.valueOf(16)) >= 0) { // quantity greater than 16oz - convert to lb
                    return new NormalisedQuantity(convert(normalisedQuantity, unit, "lb"), "lb");
                }
                // less than 16 - keep in oz
                return new NormalisedQuantity(ounces, "oz");
            }
            // will be cup or fl_oz
            if (volumeUnits.contains(unit.toLowerCase())) {
                BigDecimal flOz = convert(normalisedQuantity, unit, "fl_oz");
                if (flOz.compareTo(BigDecimal.valueOf(8)) >= 0) { // quantity greater than 8fl oz - convert to cup
                    return new NormalisedQuantity(convert(normalisedQuantity, unit, "cup"), "cup");
                }
                // less than 8 - keep in fl oz
                return new NormalisedQuantity(flOz, "fl_oz");
            }
        }
        // in general category
        return new NormalisedQuantity(normalisedQuantity, unit);
    }
}
