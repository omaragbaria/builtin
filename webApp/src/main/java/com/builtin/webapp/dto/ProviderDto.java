package com.builtin.webapp.dto;

import lombok.Data;

import java.util.List;

@Data
public class ProviderDto {
    private Long id;
    private String name;
    private String location;
    private String phone;
    private String email;
    private List<ItemDto> items;
}
