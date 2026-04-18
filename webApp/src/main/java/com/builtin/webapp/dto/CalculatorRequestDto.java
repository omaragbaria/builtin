package com.builtin.webapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CalculatorRequestDto {
    private String structureType;
    private double length;
    private double width;
    private double height;
    private double thickness;
}
