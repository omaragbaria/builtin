package com.builtin.webapp.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
public class CartItemDto {
    private Long itemId;
    private String name;
    private BigDecimal price;
    private String unit;
    private Integer quantity;
    private String providerName;
    private String shippingTime;
    private List<ItemPriceDto> prices;

    public CartItemDto(Long itemId, String name, BigDecimal price, String unit,
                       Integer quantity, String providerName, String shippingTime,
                       List<ItemPriceDto> prices) {
        this.itemId = itemId;
        this.name = name;
        this.price = price;
        this.unit = unit;
        this.quantity = quantity;
        this.providerName = providerName;
        this.shippingTime = shippingTime;
        this.prices = prices;
    }

    public BigDecimal getSubtotal() {
        return price.multiply(BigDecimal.valueOf(quantity));
    }
}
