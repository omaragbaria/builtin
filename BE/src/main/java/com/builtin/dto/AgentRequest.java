package com.builtin.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AgentRequest {
    @NotBlank
    private String message;
}
