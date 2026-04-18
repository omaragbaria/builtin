package com.builtin.webapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CheckoutRequestDto {
    private Long userId;
    private String shippingMethod;
    private List<CheckoutItemDto> items;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CheckoutItemDto {
        private Long itemId;
        private Integer quantity;
    }
}
