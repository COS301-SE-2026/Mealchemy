package com.mealchemy.shared.unitconverter;

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
        return switch (unit.toLowerCase()) {
            case "g", "kg", "lb", "oz" -> "WEIGHT";
            case "ml", "l", "cup", "fl_oz" -> "VOLUME";
            default -> throw new IllegalArgumentException("Unit not convertible:" + unit);
        };
    }

    // public convert that is actually called
    public static BigDecimal convert(BigDecimal quantity, String fromUnit, String toUnit) {
        String typeFrom = typeOfUnit(fromUnit);
        String typeTo = typeOfUnit(toUnit);

        if (!typeFrom.equals(typeTo)) {
            throw new IllegalArgumentException("Unable to convert incompatible weight and volume types");
        }

        BigDecimal baseValue = convertToBase(quantity, fromUnit);
        return convertToTarget(baseValue, toUnit);
    }
}
