package com.builtin.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AcceptDeliveryRequest {
    @NotNull
    private Long deliveryAccountId;
}
