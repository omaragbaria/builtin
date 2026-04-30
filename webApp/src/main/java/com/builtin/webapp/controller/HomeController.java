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
import java.util.Locale;

@Controller
@RequiredArgsConstructor
public class HomeController {

    private final ItemClient itemClient;
    private final ProviderClient providerClient;

    @GetMapping("/")
    public String home(Model model, Locale locale) {
        String lang = locale.getLanguage();
        List<ItemDto> featured = itemClient.getAllItems().stream().limit(8).toList();
        featured.forEach(i -> i.localize(lang));
        model.addAttribute("providers", providerClient.getAllProviders());
        model.addAttribute("featuredItems", featured);
        return "index";
    }

    @GetMapping("/search")
    public String search(@RequestParam(defaultValue = "") String query, Model model, Locale locale) {
        String lang = locale.getLanguage();
        List<ItemDto> results = query.isBlank()
                ? itemClient.getAllItems()
                : itemClient.searchItems(query);
        results.forEach(i -> i.localize(lang));
        model.addAttribute("items", results);
        model.addAttribute("query", query);
        model.addAttribute("categories", results.stream()
                .map(ItemDto::getCategory)
                .filter(c -> c != null && !c.isBlank())
                .distinct().toList());
        return "search";
    }
}
