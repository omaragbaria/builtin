package com.builtin.service;

import com.builtin.dto.CalculatorRequest;
import com.builtin.dto.CalculatorResponse;

public interface CalculatorService {
    CalculatorResponse calculate(CalculatorRequest request);
}
