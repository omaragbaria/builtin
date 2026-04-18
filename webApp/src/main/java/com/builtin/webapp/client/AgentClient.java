package com.builtin.webapp.client;

import com.builtin.webapp.dto.AgentRequestDto;
import com.builtin.webapp.dto.AgentResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
@RequiredArgsConstructor
public class AgentClient {

    private final WebClient webClient;

    public AgentResponseDto calculate(String message) {
        return webClient.post()
                .uri("/agent/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(new AgentRequestDto(message))
                .retrieve()
                .bodyToMono(AgentResponseDto.class)
                .block();
    }
}
