package com.builtin.webapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class DeliveryAccountDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String deliveryAccountType;
    private String vehicleType;
    private List<DriverDto> drivers;
}
