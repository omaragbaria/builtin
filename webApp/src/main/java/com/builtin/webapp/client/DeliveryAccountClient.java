package com.builtin.webapp.client;

import com.builtin.webapp.dto.DeliveryAccountDto;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class DeliveryAccountClient {

    private final WebClient webClient;

    public Optional<DeliveryAccountDto> findByEmail(String email) {
        try {
            DeliveryAccountDto account = webClient.get()
                    .uri("/delivery-accounts/by-email/{email}", email)
                    .retrieve()
                    .bodyToMono(DeliveryAccountDto.class)
                    .block();
            return Optional.ofNullable(account);
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    public DeliveryAccountDto create(Map<String, Object> request) {
        return webClient.post()
                .uri("/delivery-accounts")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(DeliveryAccountDto.class)
                .block();
    }

    public List<DeliveryAccountDto> getAll() {
        return webClient.get()
                .uri("/delivery-accounts")
                .retrieve()
                .bodyToFlux(DeliveryAccountDto.class)
                .collectList()
                .block();
    }

    public DeliveryAccountDto getById(Long id) {
        return webClient.get()
                .uri("/delivery-accounts/{id}", id)
                .retrieve()
                .bodyToMono(DeliveryAccountDto.class)
                .block();
    }
}
