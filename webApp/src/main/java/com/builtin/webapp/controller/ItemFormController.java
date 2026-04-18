package com.builtin.webapp.controller;

import com.builtin.webapp.client.ItemClient;
import com.builtin.webapp.client.ProviderClient;
import com.builtin.webapp.dto.CreateItemRequest;
import com.builtin.webapp.dto.ItemDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/items")
@RequiredArgsConstructor
public class ItemFormController {

    private final ItemClient itemClient;
    private final ProviderClient providerClient;

    private static final List<String> UNITS = List.of(
            "UNIT", "KG", "GRAM", "LITER", "MILLILITER",
            "METER", "CENTIMETER", "MILLIMETER",
            "SQUARE_METER", "CUBIC_METER", "PACK", "BOX", "DOZEN"
    );

    @GetMapping("/new")
    public String newItemForm(HttpSession session, Model model) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || !user.canAddItems()) {
            return "redirect:/auth/login";
        }
        model.addAttribute("item", new CreateItemRequest());
        model.addAttribute("units", UNITS);
        boolean needsProviderPicker = "SUPER_ADMIN".equals(user.getUserType())
                || ("PROVIDER".equals(user.getUserType()) && user.getProviderId() == null);
        if (needsProviderPicker) {
            model.addAttribute("providers", providerClient.getAllProviders());
        }
        return "add-item";
    }

    @PostMapping("/new")
    public String createItem(@ModelAttribute CreateItemRequest item,
                             @RequestParam(value = "photos", required = false) List<MultipartFile> photos,
                             HttpSession session,
                             RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        if (user == null || !user.canAddItems()) {
            return "redirect:/auth/login";
        }

        if ("PROVIDER".equals(user.getUserType()) && user.getProviderId() != null) {
            item.setProvider(new CreateItemRequest.ProviderRef(user.getProviderId()));
        }

        try {
            ItemDto created = itemClient.createItem(item);
            if (photos != null && created != null && created.getId() != null) {
                List<MultipartFile> nonEmpty = photos.stream()
                        .filter(f -> !f.isEmpty()).toList();
                if (!nonEmpty.isEmpty()) {
                    itemClient.uploadPhotos(created.getId(), nonEmpty);
                }
            }
            ra.addFlashAttribute("success", "Item added successfully.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to add item: " + e.getMessage());
            return "redirect:/items/new";
        }
        return "redirect:/products";
    }

    @GetMapping("/{id}/edit")
    public String editItemForm(@PathVariable Long id, HttpSession session, Model model) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        ItemDto item = itemClient.getItemById(id);
        if (user == null || !user.canEdit(item)) {
            return "redirect:/auth/login";
        }
        CreateItemRequest req = new CreateItemRequest();
        req.setName(item.getName());
        req.setType(item.getType());
        req.setCategory(item.getCategory());
        req.setSerialNumber(item.getSerialNumber());
        req.setPrice(item.getPrice());
        req.setQuantity(item.getQuantity());
        req.setUnit(item.getUnit());
        if (item.getProvider() != null) {
            req.setProvider(new CreateItemRequest.ProviderRef(item.getProvider().getId()));
        }
        model.addAttribute("item", req);
        model.addAttribute("itemId", id);
        model.addAttribute("units", UNITS);
        if ("SUPER_ADMIN".equals(user.getUserType())) {
            model.addAttribute("providers", providerClient.getAllProviders());
        }
        return "edit-item";
    }

    @PostMapping("/{id}/edit")
    public String updateItem(@PathVariable Long id,
                             @ModelAttribute CreateItemRequest item,
                             @RequestParam(value = "photos", required = false) List<MultipartFile> photos,
                             HttpSession session,
                             RedirectAttributes ra) {
        UserDto user = (UserDto) session.getAttribute("currentUser");
        ItemDto existing = itemClient.getItemById(id);
        if (user == null || !user.canEdit(existing)) {
            return "redirect:/auth/login";
        }
        if ("PROVIDER".equals(user.getUserType()) && user.getProviderId() != null) {
            item.setProvider(new CreateItemRequest.ProviderRef(user.getProviderId()));
        }
        try {
            itemClient.updateItem(id, item);
            if (photos != null) {
                List<MultipartFile> nonEmpty = photos.stream().filter(f -> !f.isEmpty()).toList();
                if (!nonEmpty.isEmpty()) {
                    itemClient.uploadPhotos(id, nonEmpty);
                }
            }
            ra.addFlashAttribute("success", "Item updated successfully.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to update item: " + e.getMessage());
            return "redirect:/items/" + id + "/edit";
        }
        return "redirect:/products/" + id;
    }
}
