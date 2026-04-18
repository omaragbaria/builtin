package com.builtin.webapp.client;

import com.builtin.webapp.dto.CalculatorRequestDto;
import com.builtin.webapp.dto.CalculatorResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
@RequiredArgsConstructor
public class CalculatorClient {

    private final WebClient webClient;

    public CalculatorResponseDto calculate(CalculatorRequestDto request) {
        return webClient.post()
                .uri("/calculator/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(CalculatorResponseDto.class)
                .block();
    }
}
