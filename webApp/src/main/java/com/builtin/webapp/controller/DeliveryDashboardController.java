package com.builtin.webapp.controller;

import com.builtin.webapp.client.DeliveryClient;
import com.builtin.webapp.dto.DeliveryDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/deliveries")
@RequiredArgsConstructor
public class DeliveryDashboardController {

    private final DeliveryClient deliveryClient;

    @GetMapping
    public String dashboard(HttpSession session, Model model) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null) return "redirect:/auth/login";

        String role = user.getUserType();

        if ("DELIVERY".equals(role)) {
            Long accountId = user.getDeliveryAccountId();
            List<DeliveryDto> pending = deliveryClient.getPending();
            List<DeliveryDto> mine = accountId != null ? deliveryClient.getByAccount(accountId) : List.of();
            model.addAttribute("pendingDeliveries", pending);
            model.addAttribute("myDeliveries", mine);
        } else if ("SUPER_ADMIN".equals(role)) {
            model.addAttribute("allDeliveries", deliveryClient.getAll());
        } else {
            return "redirect:/";
        }

        model.addAttribute("currentUser", user);
        return "delivery-dashboard";
    }

    @PostMapping("/{id}/accept")
    public String accept(@PathVariable Long id,
                         HttpSession session,
                         RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || !"DELIVERY".equals(user.getUserType())) return "redirect:/auth/login";

        Long accountId = user.getDeliveryAccountId();
        if (accountId == null) {
            ra.addFlashAttribute("error", "Your delivery account ID could not be resolved.");
            return "redirect:/deliveries";
        }

        try {
            deliveryClient.accept(id, accountId);
            ra.addFlashAttribute("message", "Package accepted successfully.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Could not accept package: " + e.getMessage());
        }
        return "redirect:/deliveries";
    }

    @PostMapping("/{id}/stage")
    public String updateStage(@PathVariable Long id,
                              @RequestParam String stage,
                              HttpSession session,
                              RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || !"DELIVERY".equals(user.getUserType())) return "redirect:/auth/login";

        try {
            deliveryClient.updateStage(id, stage);
            ra.addFlashAttribute("message", "Stage updated to " + stage.replace("_", " ").toLowerCase() + ".");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Could not update stage: " + e.getMessage());
        }
        return "redirect:/deliveries";
    }

    @PostMapping("/{id}/eta")
    public String updateEta(@PathVariable Long id,
                            @RequestParam String eta,
                            HttpSession session,
                            RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || !"DELIVERY".equals(user.getUserType())) return "redirect:/auth/login";

        try {
            deliveryClient.updateEta(id, eta);
            ra.addFlashAttribute("message", "ETA updated.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Could not update ETA: " + e.getMessage());
        }
        return "redirect:/deliveries";
    }
}
