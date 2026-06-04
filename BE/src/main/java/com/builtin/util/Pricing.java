package com.builtin.util;

import com.builtin.model.Item;
import com.builtin.model.ItemPrice;
import com.builtin.model.ShippingMethod;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;

public final class Pricing {

    private Pricing() {}

    public static BigDecimal effectivePrice(Item item, ShippingMethod method) {
        List<ItemPrice> prices = item.getPrices();
        if (prices == null || prices.isEmpty()) {
            return item.getPrice();
        }
        return prices.stream()
                .filter(p -> p.getShippingMethod() == method && p.getAmount() != null)
                .map(ItemPrice::getAmount)
                .min(Comparator.naturalOrder())
                .orElse(item.getPrice());
    }

    public static BigDecimal minEffectivePrice(Item item) {
        List<ItemPrice> prices = item.getPrices();
        if (prices == null || prices.isEmpty()) {
            return item.getPrice();
        }
        return prices.stream()
                .map(ItemPrice::getAmount)
                .filter(amount -> amount != null)
                .min(Comparator.naturalOrder())
                .orElse(item.getPrice());
    }
}
