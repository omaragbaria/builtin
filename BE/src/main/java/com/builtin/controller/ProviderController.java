package com.builtin.controller;

import com.builtin.model.Item;
import com.builtin.model.Provider;
import com.builtin.model.ProviderLocation;
import com.builtin.model.User;
import com.builtin.service.ProviderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
public class ProviderController {

    private final ProviderService providerService;

    @GetMapping
    public ResponseEntity<List<Provider>> getAllProviders() {
        return ResponseEntity.ok(providerService.getAllProviders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Provider> getProviderById(@PathVariable Long id) {
        return ResponseEntity.ok(providerService.getProviderById(id));
    }

    @PostMapping
    public ResponseEntity<Provider> createProvider(@Valid @RequestBody Provider provider) {
        return ResponseEntity.status(HttpStatus.CREATED).body(providerService.createProvider(provider));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Provider> updateProvider(@PathVariable Long id, @Valid @RequestBody Provider provider) {
        return ResponseEntity.ok(providerService.updateProvider(id, provider));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProvider(@PathVariable Long id) {
        providerService.deleteProvider(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/items")
    public ResponseEntity<List<Item>> getProviderItems(@PathVariable Long id) {
        return ResponseEntity.ok(providerService.getProviderItems(id));
    }

    @GetMapping("/{id}/users")
    public ResponseEntity<List<User>> getProviderUsers(@PathVariable Long id) {
        return ResponseEntity.ok(providerService.getProviderUsers(id));
    }

    @GetMapping("/{id}/locations")
    public ResponseEntity<List<ProviderLocation>> getLocations(@PathVariable Long id) {
        return ResponseEntity.ok(providerService.getLocations(id));
    }

    @PostMapping("/{id}/locations")
    public ResponseEntity<ProviderLocation> addLocation(@PathVariable Long id,
                                                        @RequestBody ProviderLocation location) {
        return ResponseEntity.status(HttpStatus.CREATED).body(providerService.addLocation(id, location));
    }

    @DeleteMapping("/{id}/locations/{locationId}")
    public ResponseEntity<Void> deleteLocation(@PathVariable Long id, @PathVariable Long locationId) {
        providerService.deleteLocation(id, locationId);
        return ResponseEntity.noContent().build();
    }
}
