package com.builtin.service.impl;

import com.builtin.dto.CheckoutRequest;
import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Deal;
import com.builtin.model.DealStatus;
import com.builtin.model.Item;
import com.builtin.model.ShippingMethod;
import com.builtin.repository.DealRepository;
import com.builtin.repository.ItemRepository;
import com.builtin.repository.UserRepository;
import com.builtin.service.DealService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DealServiceImpl implements DealService {

    private final DealRepository dealRepository;
    private final ItemRepository itemRepository;
    private final UserRepository userRepository;

    @Override
    public List<Deal> getAllDeals() {
        return dealRepository.findAll();
    }

    @Override
    public Deal getDealById(Long id) {
        return dealRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Deal", id));
    }

    @Override
    public Deal createDeal(Deal deal) {
        return dealRepository.save(deal);
    }

    @Override
    public Deal updateDeal(Long id, Deal updated) {
        Deal existing = getDealById(id);
        existing.setTotalPrice(updated.getTotalPrice());
        existing.setStatus(updated.getStatus());
        existing.setDealDate(updated.getDealDate());
        return dealRepository.save(existing);
    }

    @Override
    public Deal updateDealStatus(Long id, DealStatus status) {
        Deal existing = getDealById(id);
        existing.setStatus(status);
        return dealRepository.save(existing);
    }

    @Override
    public void deleteDeal(Long id) {
        getDealById(id);
        dealRepository.deleteById(id);
    }

    @Override
    public List<Item> getDealItems(Long id) {
        getDealById(id);
        return itemRepository.findByDealId(id);
    }

    @Override
    public Deal checkout(CheckoutRequest request) {
        List<Item> items = request.getItems().stream()
                .map(ci -> itemRepository.findById(ci.getItemId())
                        .orElseThrow(() -> new ResourceNotFoundException("Item", ci.getItemId())))
                .toList();

        BigDecimal itemsTotal = items.stream()
                .map(Item::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal shippingCost = shippingCostFor(request.getShippingMethod());
        BigDecimal total = itemsTotal.add(shippingCost);

        Deal.DealBuilder builder = Deal.builder()
                .status(DealStatus.PENDING_APPROVAL)
                .shippingMethod(request.getShippingMethod())
                .shippingCost(shippingCost)
                .totalPrice(total);
        if (request.getUserId() != null) {
            builder.user(userRepository.getReferenceById(request.getUserId()));
        }
        Deal deal = builder.build();

        Deal saved = dealRepository.save(deal);
        items.forEach(item -> item.setDeal(saved));
        itemRepository.saveAll(items);
        return saved;
    }

    private BigDecimal shippingCostFor(ShippingMethod method) {
        return switch (method) {
            case SELF_PICKUP -> BigDecimal.ZERO;
            case IMMEDIATE   -> new BigDecimal("49.90");
            case FAST        -> new BigDecimal("29.90");
            case STANDARD    -> new BigDecimal("9.90");
        };
    }
}
