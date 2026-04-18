package com.builtin.repository;

import com.builtin.model.Deal;
import com.builtin.model.DealStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DealRepository extends JpaRepository<Deal, Long> {
    List<Deal> findByUserId(Long userId);
    List<Deal> findByStatus(DealStatus status);
}
