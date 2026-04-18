package com.builtin.service;

import com.builtin.dto.CheckoutRequest;
import com.builtin.model.Deal;
import com.builtin.model.DealStatus;
import com.builtin.model.Item;

import java.util.List;

public interface DealService {
    List<Deal> getAllDeals();
    Deal getDealById(Long id);
    Deal createDeal(Deal deal);
    Deal updateDeal(Long id, Deal deal);
    Deal updateDealStatus(Long id, DealStatus status);
    void deleteDeal(Long id);
    List<Item> getDealItems(Long id);
    Deal checkout(CheckoutRequest request);
}
