package com.builtin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CalculatorRequest {

    @NotBlank
    private String structureType; // ROOF_SLAB, WALL

    @Positive
    private double length;        // metres

    @Positive
    private double width;         // metres (roof slab)

    @Positive
    private double height;        // metres (wall)

    @Positive
    private double thickness;     // metres
}
