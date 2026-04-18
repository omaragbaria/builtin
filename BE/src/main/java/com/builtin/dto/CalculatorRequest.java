package com.builtin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

@Data
public class CalculatorRequest {

    @NotBlank
    private String structureType; // ROOF_SLAB, WALL

    @Positive
    private double length;        // metres (always required)

    @PositiveOrZero
    private double width;         // metres (roof slab; 0 when not applicable)

    @PositiveOrZero
    private double height;        // metres (wall; 0 when not applicable)

    @PositiveOrZero
    private double thickness;     // metres (defaults applied in service if 0)
}
