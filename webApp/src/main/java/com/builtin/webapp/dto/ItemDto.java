package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ItemDto {
    private Long id;
    private String name;
    private String type;
    private String category;
    private String serialNumber;
    private BigDecimal price;
    private Integer quantity;
    private String unit;
    private ProviderDto provider;
    private List<PhotoDto> photos;
    private String shippingTime;
}
