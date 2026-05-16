package com.builtin.webapp.client;

import com.builtin.webapp.dto.ProviderDto;
import com.builtin.webapp.dto.ProviderLocationDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

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

    public List<ProviderLocationDto> getLocations(Long providerId) {
        return webClient.get()
                .uri("/providers/{id}/locations", providerId)
                .retrieve()
                .bodyToFlux(ProviderLocationDto.class)
                .collectList()
                .block();
    }

    public ProviderLocationDto addLocation(Long providerId, Map<String, Object> location) {
        return webClient.post()
                .uri("/providers/{id}/locations", providerId)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(location)
                .retrieve()
                .bodyToMono(ProviderLocationDto.class)
                .block();
    }

    public void deleteLocation(Long providerId, Long locationId) {
        webClient.delete()
                .uri("/providers/{id}/locations/{locId}", providerId, locationId)
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }
}
