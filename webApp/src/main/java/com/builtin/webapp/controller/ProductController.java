package com.builtin.webapp.controller;

import com.builtin.webapp.client.ItemClient;
import com.builtin.webapp.client.ProviderClient;
import com.builtin.webapp.dto.ItemDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductController {

    private final ItemClient itemClient;
    private final ProviderClient providerClient;

    @GetMapping
    public String allProducts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false, defaultValue = "card") String view,
            Model model) {

        List<ItemDto> allItems = itemClient.getAllItems();
        List<ItemDto> items = allItems.stream()
                .filter(i -> category == null || category.isBlank() || category.equalsIgnoreCase(i.getCategory()))
                .filter(i -> minPrice == null || (i.getPrice() != null && i.getPrice().compareTo(minPrice) >= 0))
                .filter(i -> maxPrice == null || (i.getPrice() != null && i.getPrice().compareTo(maxPrice) <= 0))
                .toList();

        BigDecimal globalMax = allItems.stream()
                .map(ItemDto::getPrice)
                .filter(p -> p != null)
                .max(BigDecimal::compareTo)
                .orElse(BigDecimal.valueOf(10000));

        model.addAttribute("items", items);
        model.addAttribute("selectedCategory", category);
        model.addAttribute("minPrice", minPrice);
        model.addAttribute("maxPrice", maxPrice);
        model.addAttribute("globalMax", globalMax);
        model.addAttribute("view", view);
        model.addAttribute("categories", allItems.stream()
                .map(ItemDto::getCategory)
                .filter(c -> c != null && !c.isBlank())
                .distinct().sorted().toList());
        return "products";
    }

    @GetMapping("/{id}")
    public String productDetail(@PathVariable Long id, Model model, RedirectAttributes ra) {
        try {
            var item = itemClient.getItemById(id);
            model.addAttribute("item", item);
            if (item.getProvider() != null) {
                model.addAttribute("providerItems",
                        itemClient.getItemsByProvider(item.getProvider().getId()).stream()
                                .filter(i -> !i.getId().equals(id))
                                .limit(4).toList());
            }
            return "product-detail";
        } catch (WebClientResponseException.NotFound e) {
            ra.addFlashAttribute("error", "Product not found — it may have been removed.");
            return "redirect:/products";
        }
    }

    @GetMapping("/provider/{providerId}")
    public String providerProducts(@PathVariable Long providerId, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("provider", providerClient.getProviderById(providerId));
            model.addAttribute("items", itemClient.getItemsByProvider(providerId));
            return "provider-products";
        } catch (WebClientResponseException.NotFound e) {
            ra.addFlashAttribute("error", "Provider not found.");
            return "redirect:/products";
        }
    }
}
