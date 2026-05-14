package com.builtin.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "delivery_accounts")
@DiscriminatorValue("DELIVERY")
@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryAccount extends User {

    @Enumerated(EnumType.STRING)
    @Column(name = "delivery_account_type")
    private DeliveryAccountType deliveryAccountType;

    @Enumerated(EnumType.STRING)
    @Column(name = "vehicle_type")
    private VehicleType vehicleType;

    @OneToMany(mappedBy = "deliveryAccount", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Driver> drivers = new ArrayList<>();

    @PrePersist
    private void setDeliveryUserType() {
        setUserType(UserType.DELIVERY);
    }
}
