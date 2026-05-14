package com.builtin.dto;

import com.builtin.model.DeliveryStage;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateStageRequest {
    @NotNull
    private DeliveryStage stage;
}
