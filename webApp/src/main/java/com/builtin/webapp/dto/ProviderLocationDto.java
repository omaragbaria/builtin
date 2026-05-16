package com.builtin.webapp.dto;

import lombok.Data;

@Data
public class ProviderLocationDto {
    private Long id;
    private String label;
    private String country;
    private String city;
    private String zipCode;
    private Double latitude;
    private Double longitude;
}
