package com.builtin.webapp.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

@RestController
@RequiredArgsConstructor
public class PhotoProxyController {

    private final WebClient webClient;

    @GetMapping("/photos/{filename}")
    public ResponseEntity<byte[]> proxyPhoto(@PathVariable String filename) {
        return webClient.get()
                .uri("/photos/{filename}", filename)
                .retrieve()
                .toEntity(byte[].class)
                .map(response -> {
                    MediaType ct = response.getHeaders().getContentType();
                    return ResponseEntity.status(response.getStatusCode())
                            .contentType(ct != null ? ct : MediaType.APPLICATION_OCTET_STREAM)
                            .body(response.getBody());
                })
                .block();
    }
}
