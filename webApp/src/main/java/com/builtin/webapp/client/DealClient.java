package com.builtin.webapp.client;

import com.builtin.webapp.dto.CheckoutRequestDto;
import com.builtin.webapp.dto.DealDto;
import com.builtin.webapp.dto.ItemDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;

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

    public List<ItemDto> getDealItems(Long dealId) {
        try {
            return webClient.get()
                    .uri("/deals/{id}/items", dealId)
                    .retrieve()
                    .bodyToFlux(ItemDto.class)
                    .collectList()
                    .block();
        } catch (Exception e) {
            return List.of();
        }
    }
}
