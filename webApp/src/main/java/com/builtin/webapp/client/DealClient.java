package com.builtin.webapp.client;

import com.builtin.webapp.dto.CheckoutRequestDto;
import com.builtin.webapp.dto.DealDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
@RequiredArgsConstructor
public class DealClient {

    private final WebClient webClient;

    public DealDto checkout(CheckoutRequestDto request) {
        return webClient.post()
                .uri("/deals/checkout")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(DealDto.class)
                .block();
    }
}
