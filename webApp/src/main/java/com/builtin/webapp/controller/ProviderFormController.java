package com.builtin.webapp.controller;

import com.builtin.webapp.client.ProviderClient;
import com.builtin.webapp.dto.ProviderLocationDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/providers")
@RequiredArgsConstructor
public class ProviderFormController {

    private final ProviderClient providerClient;

    @GetMapping("/locations")
    public String listLocations(HttpSession session, Model model) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || user.getProviderId() == null) {
            return "redirect:/auth/login";
        }
        List<ProviderLocationDto> locations = providerClient.getLocations(user.getProviderId());
        model.addAttribute("locations", locations);
        return "provider-locations";
    }

    @PostMapping("/locations")
    public String addLocation(@RequestParam String label,
                              @RequestParam(required = false) String country,
                              @RequestParam(required = false) String city,
                              @RequestParam(required = false) String zipCode,
                              @RequestParam(required = false) Double latitude,
                              @RequestParam(required = false) Double longitude,
                              HttpSession session,
                              RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || user.getProviderId() == null) {
            return "redirect:/auth/login";
        }
        Map<String, Object> body = new HashMap<>();
        body.put("label", label);
        body.put("country", country);
        body.put("city", city);
        body.put("zipCode", zipCode);
        body.put("latitude", latitude);
        body.put("longitude", longitude);
        try {
            providerClient.addLocation(user.getProviderId(), body);
            ra.addFlashAttribute("success", "Location added.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to add location: " + e.getMessage());
        }
        return "redirect:/providers/locations";
    }

    @PostMapping("/locations/{locationId}/delete")
    public String deleteLocation(@PathVariable Long locationId,
                                 HttpSession session,
                                 RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || user.getProviderId() == null) {
            return "redirect:/auth/login";
        }
        try {
            providerClient.deleteLocation(user.getProviderId(), locationId);
            ra.addFlashAttribute("success", "Location removed.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to remove location: " + e.getMessage());
        }
        return "redirect:/providers/locations";
    }
}
