package com.builtin.dto;

import com.builtin.model.DeliveryAccountType;
import com.builtin.model.VehicleType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class CreateDeliveryAccountRequest {

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @Email
    @NotBlank
    private String email;

    private String phone;

    @NotNull
    private DeliveryAccountType deliveryAccountType;

    @NotNull
    private VehicleType vehicleType;

    private List<DriverRequest> drivers = new ArrayList<>();

    @Data
    public static class DriverRequest {
        @NotBlank
        private String name;
        @NotBlank
        private String phone;
    }
}
