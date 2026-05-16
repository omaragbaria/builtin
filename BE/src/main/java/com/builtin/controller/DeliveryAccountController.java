package com.builtin.controller;

import com.builtin.dto.CreateDeliveryAccountRequest;
import com.builtin.dto.UpdateLocationRequest;
import com.builtin.model.DeliveryAccount;
import com.builtin.model.Driver;
import com.builtin.service.DeliveryAccountService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/delivery-accounts")
@RequiredArgsConstructor
public class DeliveryAccountController {

    private final DeliveryAccountService deliveryAccountService;

    @PostMapping
    public ResponseEntity<DeliveryAccount> create(@Valid @RequestBody CreateDeliveryAccountRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(deliveryAccountService.create(request));
    }

    @GetMapping
    public ResponseEntity<List<DeliveryAccount>> getAll() {
        return ResponseEntity.ok(deliveryAccountService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeliveryAccount> getById(@PathVariable Long id) {
        return ResponseEntity.ok(deliveryAccountService.getById(id));
    }

    @GetMapping("/by-email/{email}")
    public ResponseEntity<DeliveryAccount> getByEmail(@PathVariable String email) {
        return deliveryAccountService.findByEmail(email)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DeliveryAccount> update(@PathVariable Long id,
                                                   @Valid @RequestBody CreateDeliveryAccountRequest request) {
        return ResponseEntity.ok(deliveryAccountService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        deliveryAccountService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/drivers")
    public ResponseEntity<Driver> addDriver(@PathVariable Long id,
                                             @Valid @RequestBody CreateDeliveryAccountRequest.DriverRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(deliveryAccountService.addDriver(id, request));
    }

    @DeleteMapping("/{id}/drivers/{driverId}")
    public ResponseEntity<Void> removeDriver(@PathVariable Long id, @PathVariable Long driverId) {
        deliveryAccountService.removeDriver(id, driverId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/location")
    public ResponseEntity<Void> updateLocation(@PathVariable Long id,
                                               @RequestBody UpdateLocationRequest request) {
        deliveryAccountService.updateLocation(id, request.getLatitude(), request.getLongitude());
        return ResponseEntity.noContent().build();
    }
}
