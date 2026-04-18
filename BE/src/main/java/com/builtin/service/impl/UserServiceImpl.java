package com.builtin.service.impl;

import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.Deal;
import com.builtin.model.User;
import com.builtin.repository.DealRepository;
import com.builtin.repository.UserRepository;
import com.builtin.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final DealRepository dealRepository;

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }

    @Override
    public User createUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public User updateUser(Long id, User updated) {
        User existing = getUserById(id);
        existing.setFirstName(updated.getFirstName());
        existing.setLastName(updated.getLastName());
        existing.setEmail(updated.getEmail());
        existing.setPhone(updated.getPhone());
        existing.setUserType(updated.getUserType());
        return userRepository.save(existing);
    }

    @Override
    public void deleteUser(Long id) {
        getUserById(id);
        userRepository.deleteById(id);
    }

    @Override
    public List<Deal> getUserDeals(Long id) {
        getUserById(id);
        return dealRepository.findByUserId(id);
    }
}
