package com.builtin.service;

import com.builtin.model.Item;
import com.builtin.model.Provider;
import com.builtin.model.User;

import java.util.List;

public interface ProviderService {
    List<Provider> getAllProviders();
    Provider getProviderById(Long id);
    Provider createProvider(Provider provider);
    Provider updateProvider(Long id, Provider provider);
    void deleteProvider(Long id);
    List<Item> getProviderItems(Long id);
    List<User> getProviderUsers(Long id);
}
