package com.builtin.webapp.client;

import com.builtin.webapp.dto.UserDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class UserClient {

    private final WebClient webClient;

    public Optional<UserDto> findByEmail(String email) {
        List<UserDto> users = webClient.get()
                .uri("/users")
                .retrieve()
                .bodyToFlux(UserDto.class)
                .collectList()
                .block();
        return users == null ? Optional.empty()
                : users.stream().filter(u -> email.equalsIgnoreCase(u.getEmail())).findFirst();
    }
}
