package com.builtin.service;

import com.builtin.model.Deal;
import com.builtin.model.User;

import java.util.List;

public interface UserService {
    List<User> getAllUsers();
    User getUserById(Long id);
    User createUser(User user);
    User updateUser(Long id, User user);
    void deleteUser(Long id);
    List<Deal> getUserDeals(Long id);
}
