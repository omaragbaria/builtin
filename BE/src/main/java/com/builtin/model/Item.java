package com.builtin.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "items")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false)
    private String name;

    @Column(name = "name_ar")
    private String nameAr;

    @Column(name = "name_he")
    private String nameHe;

    @Column(name = "name_ru")
    private String nameRu;

    @Column(name = "name_zh")
    private String nameZh;

    @Column(name = "item_type")
    private String type;

    @Enumerated(EnumType.STRING)
    @Column(name = "category")
    private ItemCategory category;

    @Enumerated(EnumType.STRING)
    @Column(name = "color")
    @Builder.Default
    private ItemColor color = ItemColor.NA;

    @Column(name = "serial_number", unique = true)
    private String serialNumber;

    @NotNull
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "customer_price", precision = 10, scale = 2)
    private BigDecimal customerPrice;

    @Column(name = "contractor_price", precision = 10, scale = 2)
    private BigDecimal contractorPrice;

    @Column(name = "qty_per_package")
    private Integer qtyPerPackage;

    @Column(nullable = false)
    private Integer quantity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ItemUnit unit;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id")
    private Deal deal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id")
    private Provider provider;

    @Column(name = "shipping_time")
    private String shippingTime;

    @OneToMany(mappedBy = "item", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private java.util.List<ItemPhoto> photos = new java.util.ArrayList<>();
}
