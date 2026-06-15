package com.builtin.webapp.controller;

import com.builtin.webapp.client.DealClient;
import com.builtin.webapp.dto.DealDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Comparator;
import java.util.List;

@Controller
@RequestMapping("/purchases")
@RequiredArgsConstructor
public class PurchasesController {

    private final DealClient dealClient;

    @GetMapping
    public String purchases(HttpSession session, Model model) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null) return "redirect:/auth/login";

        List<DealDto> deals = dealClient.getDealsByUser(user.getId());
        // Newest first.
        deals = deals.stream()
                .sorted(Comparator.comparing(DealDto::getDealDate,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();

        model.addAttribute("deals", deals);
        model.addAttribute("currentUser", user);
        return "purchases";
    }
}
