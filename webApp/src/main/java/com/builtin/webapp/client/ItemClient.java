package com.builtin.webapp.client;

import com.builtin.webapp.dto.CreateItemRequest;
import com.builtin.webapp.dto.ItemDto;
import com.builtin.webapp.dto.PhotoDto;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class ItemClient {

    private final WebClient webClient;

    public List<ItemDto> getAllItems() {
        return webClient.get()
                .uri("/items")
                .retrieve()
                .bodyToFlux(ItemDto.class)
                .collectList()
                .block();
    }

    public ItemDto getItemById(Long id) {
        return webClient.get()
                .uri("/items/{id}", id)
                .retrieve()
                .bodyToMono(ItemDto.class)
                .block();
    }

    public List<ItemDto> getItemsByProvider(Long providerId) {
        return webClient.get()
                .uri("/items/provider/{providerId}", providerId)
                .retrieve()
                .bodyToFlux(ItemDto.class)
                .collectList()
                .block();
    }

    public ItemDto updateItem(Long id, CreateItemRequest request) {
        return webClient.put()
                .uri("/items/{id}", id)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ItemDto.class)
                .block();
    }

    public ItemDto createItem(CreateItemRequest request) {
        return webClient.post()
                .uri("/items")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ItemDto.class)
                .block();
    }

    public List<PhotoDto> uploadPhotos(Long itemId, List<MultipartFile> files) throws IOException {
        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        for (MultipartFile file : files) {
            if (file.isEmpty()) continue;
            final String filename = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
            byte[] bytes = file.getBytes();
            builder.part("files", new ByteArrayResource(bytes) {
                @Override
                public String getFilename() { return filename; }
            }).contentType(MediaType.parseMediaType(
                    file.getContentType() != null ? file.getContentType() : MediaType.APPLICATION_OCTET_STREAM_VALUE));
        }
        return webClient.post()
                .uri("/items/{id}/photos", itemId)
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .body(BodyInserters.fromMultipartData(builder.build()))
                .retrieve()
                .bodyToFlux(PhotoDto.class)
                .collectList()
                .block();
    }

    public List<ItemDto> searchItems(String query) {
        return getAllItems().stream()
                .filter(item -> item.getName().toLowerCase().contains(query.toLowerCase())
                        || (item.getCategory() != null && item.getCategory().toLowerCase().contains(query.toLowerCase()))
                        || (item.getType() != null && item.getType().toLowerCase().contains(query.toLowerCase())))
                .toList();
    }
}
