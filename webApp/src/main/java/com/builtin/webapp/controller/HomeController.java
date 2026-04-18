package com.builtin.webapp.controller;

import com.builtin.webapp.client.ItemClient;
import com.builtin.webapp.client.ProviderClient;
import com.builtin.webapp.dto.ItemDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class HomeController {

    private final ItemClient itemClient;
    private final ProviderClient providerClient;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("providers", providerClient.getAllProviders());
        model.addAttribute("featuredItems", itemClient.getAllItems().stream().limit(8).toList());
        return "index";
    }

    @GetMapping("/search")
    public String search(@RequestParam(defaultValue = "") String query, Model model) {
        List<ItemDto> results = query.isBlank()
                ? itemClient.getAllItems()
                : itemClient.searchItems(query);
        model.addAttribute("items", results);
        model.addAttribute("query", query);
        model.addAttribute("categories", results.stream()
                .map(ItemDto::getCategory)
                .filter(c -> c != null && !c.isBlank())
                .distinct().toList());
        return "search";
    }
}
