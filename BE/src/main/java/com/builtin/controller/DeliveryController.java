package com.builtin.controller;

import com.builtin.dto.AcceptDeliveryRequest;
import com.builtin.dto.DeliveryResponseDto;
import com.builtin.dto.UpdateEtaRequest;
import com.builtin.dto.UpdateStageRequest;
import com.builtin.service.DeliveryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/deliveries")
@RequiredArgsConstructor
public class DeliveryController {

    private final DeliveryService deliveryService;

    @GetMapping
    public ResponseEntity<List<DeliveryResponseDto>> getAll() {
        return ResponseEntity.ok(deliveryService.getAll());
    }

    @GetMapping("/pending")
    public ResponseEntity<List<DeliveryResponseDto>> getPending() {
        return ResponseEntity.ok(deliveryService.getPending());
    }

    @GetMapping("/account/{accountId}")
    public ResponseEntity<List<DeliveryResponseDto>> getByAccount(@PathVariable Long accountId) {
        return ResponseEntity.ok(deliveryService.getByAccount(accountId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeliveryResponseDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(deliveryService.getById(id));
    }

    @GetMapping("/deal/{dealId}")
    public ResponseEntity<DeliveryResponseDto> getByDeal(@PathVariable Long dealId) {
        return deliveryService.findByDealId(dealId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<DeliveryResponseDto> accept(@PathVariable Long id,
                                                       @Valid @RequestBody AcceptDeliveryRequest request) {
        return ResponseEntity.ok(deliveryService.accept(id, request.getDeliveryAccountId()));
    }

    @PatchMapping("/{id}/stage")
    public ResponseEntity<DeliveryResponseDto> updateStage(@PathVariable Long id,
                                                            @Valid @RequestBody UpdateStageRequest request) {
        return ResponseEntity.ok(deliveryService.updateStage(id, request.getStage()));
    }

    @PatchMapping("/{id}/eta")
    public ResponseEntity<DeliveryResponseDto> updateEta(@PathVariable Long id,
                                                          @RequestBody UpdateEtaRequest request) {
        return ResponseEntity.ok(deliveryService.updateEta(id, request.getEta()));
    }
}
