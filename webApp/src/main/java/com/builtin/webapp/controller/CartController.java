package com.builtin.webapp.controller;

import com.builtin.webapp.client.DealClient;
import com.builtin.webapp.client.ItemClient;
import com.builtin.webapp.dto.CartItemDto;
import com.builtin.webapp.dto.CheckoutRequestDto;
import com.builtin.webapp.dto.ItemDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final ItemClient itemClient;
    private final DealClient dealClient;

    @GetMapping
    public String viewCart(HttpSession session, Model model) {
        List<CartItemDto> cart = getCart(session);
        BigDecimal total = cart.stream()
                .map(CartItemDto::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, List<CartItemDto>> groupedByShipping = cart.stream()
                .collect(Collectors.groupingBy(
                        item -> item.getShippingTime() != null ? item.getShippingTime() : "Standard",
                        LinkedHashMap::new,
                        Collectors.toList()
                ));

        model.addAttribute("cart", cart);
        model.addAttribute("groupedCart", groupedByShipping);
        model.addAttribute("total", total);
        return "cart";
    }

    @PostMapping("/add/{itemId}")
    public String addToCart(@PathVariable Long itemId,
                            @RequestParam(defaultValue = "1") Integer quantity,
                            HttpSession session,
                            RedirectAttributes redirectAttributes) {
        ItemDto item = itemClient.getItemById(itemId);
        List<CartItemDto> cart = getCart(session);

        cart.stream()
                .filter(c -> c.getItemId().equals(itemId))
                .findFirst()
                .ifPresentOrElse(
                        existing -> existing.setQuantity(existing.getQuantity() + quantity),
                        () -> cart.add(new CartItemDto(
                                item.getId(),
                                item.getName(),
                                item.getPrice(),
                                item.getUnit(),
                                quantity,
                                item.getProvider() != null ? item.getProvider().getName() : "",
                                item.getShippingTime()
                        ))
                );

        session.setAttribute("cart", cart);
        redirectAttributes.addFlashAttribute("message", item.getName() + " added to cart.");
        return "redirect:/products/" + itemId;
    }

    @PostMapping("/update/{itemId}")
    public String updateQuantity(@PathVariable Long itemId,
                                 @RequestParam Integer quantity,
                                 HttpSession session) {
        List<CartItemDto> cart = getCart(session);
        if (quantity <= 0) {
            cart.removeIf(c -> c.getItemId().equals(itemId));
        } else {
            cart.stream()
                    .filter(c -> c.getItemId().equals(itemId))
                    .findFirst()
                    .ifPresent(c -> c.setQuantity(quantity));
        }
        session.setAttribute("cart", cart);
        return "redirect:/cart";
    }

    @PostMapping("/remove/{itemId}")
    public String removeFromCart(@PathVariable Long itemId, HttpSession session) {
        getCart(session).removeIf(c -> c.getItemId().equals(itemId));
        session.setAttribute("cart", getCart(session));
        return "redirect:/cart";
    }

    @GetMapping("/checkout")
    public String checkout(@RequestParam String shippingMethod,
                           HttpSession session,
                           RedirectAttributes redirectAttributes) {
        List<CartItemDto> cart = getCart(session);
        if (cart.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Your cart is empty.");
            return "redirect:/cart";
        }

        UserDto currentUser = (UserDto) session.getAttribute("currentUser");

        List<CheckoutRequestDto.CheckoutItemDto> items = cart.stream()
                .map(c -> new CheckoutRequestDto.CheckoutItemDto(c.getItemId(), c.getQuantity()))
                .toList();

        CheckoutRequestDto request = new CheckoutRequestDto(
                currentUser != null ? currentUser.getId() : null,
                shippingMethod,
                items
        );

        dealClient.checkout(request);
        session.removeAttribute("cart");
        redirectAttributes.addFlashAttribute("message", "Order placed successfully!");
        return "redirect:/products";
    }

    @SuppressWarnings("unchecked")
    private List<CartItemDto> getCart(HttpSession session) {
        List<CartItemDto> cart = (List<CartItemDto>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }
        return cart;
    }
}
