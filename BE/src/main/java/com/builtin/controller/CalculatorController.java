package com.builtin.controller;

import com.builtin.dto.CalculatorRequest;
import com.builtin.dto.CalculatorResponse;
import com.builtin.service.CalculatorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/calculator")
@RequiredArgsConstructor
public class CalculatorController {

    private final CalculatorService calculatorService;

    @PostMapping("/calculate")
    public ResponseEntity<CalculatorResponse> calculate(@Valid @RequestBody CalculatorRequest request) {
        return ResponseEntity.ok(calculatorService.calculate(request));
    }
}
