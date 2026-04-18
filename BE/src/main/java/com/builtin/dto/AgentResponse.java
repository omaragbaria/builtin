package com.builtin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentResponse {

    private String projectSummary;
    private List<MaterialLine> materials;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MaterialLine {
        private String materialType;      // e.g. "Oak Wood Panel"
        private double requiredQuantity;
        private String unit;              // e.g. "M2", "UNIT", "KG"
        private List<MatchedItem> matchedItems;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
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
