package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CalculatorResponseDto {

    private String structureSummary;
    private List<MaterialLine> materials;

    @Data
    public static class MaterialLine {
        private String materialType;
        private double requiredQuantity;
        private String unit;
        private List<MatchedItem> matchedItems;
    }

    @Data
    public static class MatchedItem {
        private Long itemId;
        private String name;
        private BigDecimal price;
        private String unit;
        private Integer availableQuantity;
        private String providerName;
        private boolean lowestPrice;
    }
}
