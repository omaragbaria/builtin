package com.builtin.webapp.controller;

import com.builtin.webapp.client.DeliveryAccountClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/delivery")
@RequiredArgsConstructor
public class DeliveryController {

    private final DeliveryAccountClient deliveryAccountClient;

    @GetMapping("/register")
    public String registerForm(Model model) {
        model.addAttribute("vehicleTypes", List.of(
                "BIKE", "MOTORBIKE", "CAR", "TRUCK", "LARGE_TRUCK",
                "TRAILER_TRUCK", "FRIDGE_TRUCK", "MIXED_TRUCK", "TRUCK_WITH_WINCH"
        ));
        return "register-delivery";
    }

    @PostMapping("/register")
    public String register(
            @RequestParam String firstName,
            @RequestParam String lastName,
            @RequestParam String email,
            @RequestParam(required = false) String phone,
            @RequestParam String deliveryAccountType,
            @RequestParam String vehicleType,
            @RequestParam(required = false) List<String> driverNames,
            @RequestParam(required = false) List<String> driverPhones,
            RedirectAttributes ra) {

        List<Map<String, String>> drivers = new ArrayList<>();
        if ("COMPANY".equals(deliveryAccountType) && driverNames != null) {
            for (int i = 0; i < driverNames.size(); i++) {
                String name = driverNames.get(i);
                String phone2 = (driverPhones != null && i < driverPhones.size()) ? driverPhones.get(i) : "";
                if (name != null && !name.isBlank()) {
                    drivers.add(Map.of("name", name, "phone", phone2));
                }
            }
        }

        Map<String, Object> request = new HashMap<>();
        request.put("firstName", firstName);
        request.put("lastName", lastName);
        request.put("email", email);
        request.put("phone", phone != null ? phone : "");
        request.put("deliveryAccountType", deliveryAccountType);
        request.put("vehicleType", vehicleType);
        request.put("drivers", drivers);

        try {
            deliveryAccountClient.create(request);
            ra.addFlashAttribute("message", "Delivery account registered successfully! You can now log in.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Registration failed: " + e.getMessage());
            return "redirect:/delivery/register";
        }

        return "redirect:/auth/login";
    }
}
