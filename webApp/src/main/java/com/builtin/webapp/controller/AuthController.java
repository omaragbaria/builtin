package com.builtin.webapp.controller;

import com.builtin.webapp.client.ProviderClient;
import com.builtin.webapp.dto.ProviderDto;
import com.builtin.webapp.dto.UserDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private static final String PASSWORD = "1234";

    // static role mappings (username → userType)
    private static final Map<String, String> ROLE_MAP = Map.of(
            "user",     "CUSTOMER",
            "provider", "PROVIDER",
            "admin",    "SUPER_ADMIN",
            "patara",   "PROVIDER"
    );

    private final ProviderClient providerClient;

    @GetMapping("/login")
    public String loginForm() {
        return "login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session,
                        RedirectAttributes ra) {

        String key  = username.toLowerCase().trim();
        String type = ROLE_MAP.get(key);
        if (type == null || !PASSWORD.equals(password)) {
            ra.addFlashAttribute("error", "Invalid username or password.");
            return "redirect:/auth/login";
        }

        UserDto user = new UserDto();
        user.setFirstName(capitalize(key));
        user.setLastName("Account");
        user.setEmail(key + "@builtin.com");
        user.setUserType(type);

        // For named provider logins, resolve the provider ID from the DB
        if ("patara".equals(key)) {
            try {
                List<ProviderDto> providers = providerClient.getAllProviders();
                providers.stream()
                        .filter(p -> "Patara".equalsIgnoreCase(p.getName()))
                        .findFirst()
                        .ifPresent(p -> user.setProviderId(p.getId()));
            } catch (Exception ignored) {}
        }

        session.setAttribute("currentUser", user);
        return "redirect:/";
    }

    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/auth/login";
    }

    private String capitalize(String s) {
        return s.isEmpty() ? s : Character.toUpperCase(s.charAt(0)) + s.substring(1).toLowerCase();
    }
}
