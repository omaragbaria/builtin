package com.builtin.webapp.controller;

import com.builtin.webapp.client.AgentClient;
import com.builtin.webapp.client.ItemClient;
import com.builtin.webapp.dto.AgentResponseDto;
import com.builtin.webapp.dto.CartItemDto;
import com.builtin.webapp.dto.ItemDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/agent")
@RequiredArgsConstructor
public class AgentWebController {

    private final AgentClient agentClient;
    private final ItemClient itemClient;

    @GetMapping
    public String agentPage() {
        return "agent";
    }

    @PostMapping
    public String calculate(@RequestParam String message, Model model) {
        AgentResponseDto response = agentClient.calculate(message);
        model.addAttribute("message", message);
        model.addAttribute("response", response);
        return "agent";
    }

    @PostMapping("/add-all")
    public String addAll(@RequestParam List<Long> itemIds,
                         HttpSession session,
                         RedirectAttributes redirectAttributes) {
        @SuppressWarnings("unchecked")
        List<CartItemDto> cart = (List<CartItemDto>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
        }

        for (Long itemId : itemIds) {
            ItemDto item = itemClient.getItemById(itemId);
            final List<CartItemDto> finalCart = cart;
            finalCart.stream()
                    .filter(c -> c.getItemId().equals(itemId))
                    .findFirst()
                    .ifPresentOrElse(
                            existing -> existing.setQuantity(existing.getQuantity() + 1),
                            () -> finalCart.add(new CartItemDto(
                                    item.getId(),
                                    item.getName(),
                                    item.getPrice(),
                                    item.getUnit(),
                                    1,
                                    item.getProvider() != null ? item.getProvider().getName() : "",
                                    item.getShippingTime()
                            ))
                    );
        }

        session.setAttribute("cart", cart);
        redirectAttributes.addFlashAttribute("message", itemIds.size() + " items added to cart.");
        return "redirect:/cart";
    }
}
