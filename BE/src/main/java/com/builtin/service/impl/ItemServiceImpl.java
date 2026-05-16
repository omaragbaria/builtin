package com.builtin.service.impl;

import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Item;
import com.builtin.model.ProviderLocation;
import com.builtin.repository.ItemRepository;
import com.builtin.repository.ProviderLocationRepository;
import com.builtin.repository.ProviderRepository;
import com.builtin.service.ItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ItemServiceImpl implements ItemService {

    private final ItemRepository itemRepository;
    private final ProviderRepository providerRepository;
    private final ProviderLocationRepository providerLocationRepository;

    @Override
    public List<Item> getAllItems() {
        return itemRepository.findAll();
    }

    @Override
    public Item getItemById(Long id) {
        return itemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Item", id));
    }

    @Override
    public List<Item> getItemsByProvider(Long providerId) {
        return itemRepository.findByProviderId(providerId);
    }

    @Override
    @Transactional
    public Item createItem(Item item) {
        resolveProvider(item);
        Long providerId = item.getProvider() != null ? item.getProvider().getId() : null;
        Item saved = itemRepository.save(item);
        // 8.3: default item location to the provider's first (primary) location
        if (providerId != null) {
            List<ProviderLocation> providerLocs = providerLocationRepository.findByProviderId(providerId);
            if (!providerLocs.isEmpty()) {
                saved.getLocations().add(providerLocs.get(0));
                itemRepository.save(saved);
            }
        }
        return saved;
    }

    @Override
    public Item updateItem(Long id, Item updated) {
        Item existing = getItemById(id);
        existing.setName(updated.getName());
        existing.setType(updated.getType());
        existing.setCategory(updated.getCategory());
        existing.setSerialNumber(updated.getSerialNumber());
        existing.setPrice(updated.getPrice());
        existing.setQuantity(updated.getQuantity());
        existing.setUnit(updated.getUnit());
        resolveProvider(updated);
        existing.setProvider(updated.getProvider());
        return itemRepository.save(existing);
    }

    private void resolveProvider(Item item) {
        if (item.getProvider() != null && item.getProvider().getId() != null) {
            item.setProvider(providerRepository.getReferenceById(item.getProvider().getId()));
        }
    }

    @Override
    public void deleteItem(Long id) {
        getItemById(id);
        itemRepository.deleteById(id);
    }

    @Override
    @Transactional
    public void setLocations(Long itemId, List<Long> providerLocationIds) {
        Item item = getItemById(itemId);
        List<ProviderLocation> locations = providerLocationIds == null || providerLocationIds.isEmpty()
                ? new ArrayList<>()
                : providerLocationRepository.findAllById(providerLocationIds);
        item.setLocations(new ArrayList<>(locations));
        itemRepository.save(item);
    }
}
