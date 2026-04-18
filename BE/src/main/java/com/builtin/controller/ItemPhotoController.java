package com.builtin.controller;

import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Item;
import com.builtin.model.ItemPhoto;
import com.builtin.repository.ItemPhotoRepository;
import com.builtin.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class ItemPhotoController {

    @Value("${app.upload-dir:./uploads}")
    private String uploadDir;

    private final ItemPhotoRepository photoRepository;
    private final ItemRepository itemRepository;

    @PostMapping("/api/items/{id}/photos")
    public ResponseEntity<List<ItemPhoto>> uploadPhotos(
            @PathVariable Long id,
            @RequestParam("files") List<MultipartFile> files) throws IOException {

        Item item = itemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Item", id));

        Path dir = Paths.get(uploadDir);
        Files.createDirectories(dir);

        List<ItemPhoto> saved = new ArrayList<>();
        for (MultipartFile file : files) {
            if (file.isEmpty()) continue;

            String original = file.getOriginalFilename();
            String ext = (original != null && original.contains("."))
                    ? original.substring(original.lastIndexOf('.'))
                    : "";
            String fileName = UUID.randomUUID() + ext;

            Files.write(dir.resolve(fileName), file.getBytes());

            ItemPhoto photo = ItemPhoto.builder()
                    .fileName(fileName)
                    .contentType(file.getContentType())
                    .item(item)
                    .build();
            saved.add(photoRepository.save(photo));
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/api/photos/{filename}")
    public ResponseEntity<byte[]> servePhoto(@PathVariable String filename) throws IOException {
        Path filePath = Paths.get(uploadDir).resolve(filename).normalize();
        // Prevent path traversal
        if (!filePath.startsWith(Paths.get(uploadDir).toAbsolutePath())) {
            return ResponseEntity.badRequest().build();
        }
        if (!Files.exists(filePath)) {
            return ResponseEntity.notFound().build();
        }
        String contentType = Files.probeContentType(filePath);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(
                        contentType != null ? contentType : "application/octet-stream"))
                .body(Files.readAllBytes(filePath));
    }

    @DeleteMapping("/api/items/{itemId}/photos/{photoId}")
    public ResponseEntity<Void> deletePhoto(
            @PathVariable Long itemId,
            @PathVariable Long photoId) throws IOException {

        ItemPhoto photo = photoRepository.findById(photoId)
                .orElseThrow(() -> new ResourceNotFoundException("Photo", photoId));

        Files.deleteIfExists(Paths.get(uploadDir).resolve(photo.getFileName()));
        photoRepository.delete(photo);
        return ResponseEntity.noContent().build();
    }
}
