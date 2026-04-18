package com.builtin.webapp.dto;

import lombok.Data;

@Data
public class UserDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String userType;
    private Long providerId;

    public boolean canAddItems() {
        return "PROVIDER".equals(userType) || "SUPER_ADMIN".equals(userType);
    }

    public boolean canEdit(com.builtin.webapp.dto.ItemDto item) {
        if ("SUPER_ADMIN".equals(userType)) return true;
        if ("PROVIDER".equals(userType) && providerId != null && item.getProvider() != null) {
            return providerId.equals(item.getProvider().getId());
        }
        return false;
    }

    public String getDisplayName() {
        return firstName + " " + lastName;
    }
}
