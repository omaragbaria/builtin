package com.builtin.repository;

import com.builtin.model.ProviderLocation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProviderLocationRepository extends JpaRepository<ProviderLocation, Long> {
    List<ProviderLocation> findByProviderId(Long providerId);
}
