package com.builtin.webapp.client;

import com.builtin.webapp.dto.DeliveryDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class DeliveryClient {

    private final WebClient webClient;

    public List<DeliveryDto> getPending() {
        return webClient.get()
                .uri("/deliveries/pending")
                .retrieve()
                .bodyToFlux(DeliveryDto.class)
                .collectList()
                .block();
    }

    public List<DeliveryDto> getByAccount(Long accountId) {
        return webClient.get()
                .uri("/deliveries/account/{id}", accountId)
                .retrieve()
                .bodyToFlux(DeliveryDto.class)
                .collectList()
                .block();
    }

    public List<DeliveryDto> getAll() {
        return webClient.get()
                .uri("/deliveries")
                .retrieve()
                .bodyToFlux(DeliveryDto.class)
                .collectList()
                .block();
    }

    public DeliveryDto accept(Long deliveryId, Long deliveryAccountId) {
        return webClient.post()
                .uri("/deliveries/{id}/accept", deliveryId)
                .bodyValue(Map.of("deliveryAccountId", deliveryAccountId))
                .retrieve()
                .bodyToMono(DeliveryDto.class)
                .block();
    }

    public DeliveryDto updateStage(Long deliveryId, String stage) {
        return webClient.patch()
                .uri("/deliveries/{id}/stage", deliveryId)
                .bodyValue(Map.of("stage", stage))
                .retrieve()
                .bodyToMono(DeliveryDto.class)
                .block();
    }

    public DeliveryDto updateEta(Long deliveryId, String eta) {
        return webClient.patch()
                .uri("/deliveries/{id}/eta", deliveryId)
                .bodyValue(Map.of("eta", eta))
                .retrieve()
                .bodyToMono(DeliveryDto.class)
                .block();
    }

    public DeliveryDto getByDeal(Long dealId) {
        try {
            return webClient.get()
                    .uri("/deliveries/deal/{dealId}", dealId)
                    .retrieve()
                    .bodyToMono(DeliveryDto.class)
                    .block();
        } catch (Exception e) {
            return null;
        }
    }
}
