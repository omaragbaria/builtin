package com.builtin.service;

import com.builtin.model.Deal;
import com.builtin.model.User;

import java.util.List;
import java.util.Optional;

public interface UserService {
    List<User> getAllUsers();
    User getUserById(Long id);
    Optional<User> findByEmail(String email);
    User createUser(User user);
    User updateUser(Long id, User user);
    void deleteUser(Long id);
    List<Deal> getUserDeals(Long id);
}
