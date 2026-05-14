package com.builtin.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UpdateEtaRequest {
    private LocalDateTime eta;
}
