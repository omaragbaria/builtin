package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreateItemRequest {
    private String name;
    private String type;
    private String category;
    private String serialNumber;
    private BigDecimal price;
    private Integer quantity;
    private String unit;
    private ProviderRef provider;

    @Data
    public static class ProviderRef {
        private Long id;

        public ProviderRef() {}

        public ProviderRef(Long id) {
            this.id = id;
        }
    }
}
