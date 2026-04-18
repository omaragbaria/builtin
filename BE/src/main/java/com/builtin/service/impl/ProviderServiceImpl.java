package com.builtin.service.impl;

import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Item;
import com.builtin.model.Provider;
import com.builtin.model.User;
import com.builtin.repository.ItemRepository;
import com.builtin.repository.ProviderRepository;
import com.builtin.repository.UserRepository;
import com.builtin.service.ProviderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProviderServiceImpl implements ProviderService {

    private final ProviderRepository providerRepository;
    private final ItemRepository itemRepository;
    private final UserRepository userRepository;

    @Override
    public List<Provider> getAllProviders() {
        return providerRepository.findAll();
    }

    @Override
    public Provider getProviderById(Long id) {
        return providerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider", id));
    }

    @Override
    public Provider createProvider(Provider provider) {
        return providerRepository.save(provider);
    }

    @Override
    public Provider updateProvider(Long id, Provider updated) {
        Provider existing = getProviderById(id);
        existing.setName(updated.getName());
        existing.setLocation(updated.getLocation());
        existing.setPhone(updated.getPhone());
        existing.setEmail(updated.getEmail());
        return providerRepository.save(existing);
    }

    @Override
    public void deleteProvider(Long id) {
        getProviderById(id);
        providerRepository.deleteById(id);
    }

    @Override
    public List<Item> getProviderItems(Long id) {
        getProviderById(id);
        return itemRepository.findByProviderId(id);
    }

    @Override
    public List<User> getProviderUsers(Long id) {
        getProviderById(id);
        return userRepository.findByProviderId(id);
    }
}
