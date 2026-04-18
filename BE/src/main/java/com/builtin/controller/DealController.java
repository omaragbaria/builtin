package com.builtin.controller;

import com.builtin.dto.CheckoutRequest;
import com.builtin.model.Deal;
import com.builtin.model.DealStatus;
import com.builtin.model.Item;
import com.builtin.service.DealService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/deals")
@RequiredArgsConstructor
public class DealController {

    private final DealService dealService;

    @GetMapping
    public ResponseEntity<List<Deal>> getAllDeals() {
        return ResponseEntity.ok(dealService.getAllDeals());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Deal> getDealById(@PathVariable Long id) {
        return ResponseEntity.ok(dealService.getDealById(id));
    }

    @PostMapping
    public ResponseEntity<Deal> createDeal(@Valid @RequestBody Deal deal) {
        return ResponseEntity.status(HttpStatus.CREATED).body(dealService.createDeal(deal));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Deal> updateDeal(@PathVariable Long id, @Valid @RequestBody Deal deal) {
        return ResponseEntity.ok(dealService.updateDeal(id, deal));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Deal> updateDealStatus(@PathVariable Long id, @RequestParam DealStatus status) {
        return ResponseEntity.ok(dealService.updateDealStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDeal(@PathVariable Long id) {
        dealService.deleteDeal(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/items")
    public ResponseEntity<List<Item>> getDealItems(@PathVariable Long id) {
        return ResponseEntity.ok(dealService.getDealItems(id));
    }

    @PostMapping("/checkout")
    public ResponseEntity<Deal> checkout(@Valid @RequestBody CheckoutRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(dealService.checkout(request));
    }
}
