package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ItemDto {
    private Long id;
    private String name;
    private String nameAr;
    private String nameHe;
    private String nameRu;
    private String nameZh;
    private String type;
    private String category;
    private String serialNumber;
    private BigDecimal price;
    private Integer quantity;
    private String unit;
    private ProviderDto provider;
    private List<PhotoDto> photos;
    private String shippingTime;

    public void localize(String lang) {
        String translated = switch (lang) {
            case "ar" -> nameAr;
            case "he" -> nameHe;
            case "ru" -> nameRu;
            case "zh" -> nameZh;
            default  -> null;
        };
        if (translated != null && !translated.isBlank()) {
            this.name = translated;
        }
    }
}
