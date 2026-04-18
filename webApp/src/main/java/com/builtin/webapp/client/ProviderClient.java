package com.builtin.webapp.client;

import com.builtin.webapp.dto.ProviderDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ProviderClient {

    private final WebClient webClient;

    public List<ProviderDto> getAllProviders() {
        return webClient.get()
                .uri("/providers")
                .retrieve()
                .bodyToFlux(ProviderDto.class)
                .collectList()
                .block();
    }

    public ProviderDto getProviderById(Long id) {
        return webClient.get()
                .uri("/providers/{id}", id)
                .retrieve()
                .bodyToMono(ProviderDto.class)
                .block();
    }
}
