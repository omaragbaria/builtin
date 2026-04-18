package com.builtin.service.impl;

import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Item;
import com.builtin.repository.ItemRepository;
import com.builtin.repository.ProviderRepository;
import com.builtin.service.ItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ItemServiceImpl implements ItemService {

    private final ItemRepository itemRepository;
    private final ProviderRepository providerRepository;

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
    public Item createItem(Item item) {
        resolveProvider(item);
        return itemRepository.save(item);
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
}
