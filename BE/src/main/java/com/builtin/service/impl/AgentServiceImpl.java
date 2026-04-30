package com.builtin.service.impl;

import com.builtin.dto.AgentRequest;
import com.builtin.dto.AgentResponse;
import com.builtin.dto.AgentResponse.MaterialLine;
import com.builtin.dto.AgentResponse.MatchedItem;
import com.builtin.model.Item;
import com.builtin.repository.ItemRepository;
import com.builtin.service.AgentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Mock AI agent service.
 * Parses the user message for project type, wood type, and dimensions,
 * then calculates required materials and maps them to store items.
 *
 * Replace the parseDimensions / buildMaterialList logic with a real
 * ChatGPT/Claude API call when the integration key is available.
 */
@Service
@RequiredArgsConstructor
public class AgentServiceImpl implements AgentService {

    private final ItemRepository itemRepository;

    @Override
    public AgentResponse calculate(AgentRequest request) {
        String msg = request.getMessage().toLowerCase();

        // --- 1. Extract dimensions (width, depth, height in metres) ---
        double width  = extractDimension(msg, "width",  "wide",  "w");
        double depth  = extractDimension(msg, "depth",  "deep",  "d");
        double height = extractDimension(msg, "height", "high",  "h");

        // Default sensible sizes if not found
        if (width  <= 0) width  = 1.0;
        if (depth  <= 0) depth  = 0.6;
        if (height <= 0) height = 2.0;

        // --- 2. Detect material keyword ---
        String woodType = detectWoodType(msg);

        // --- 3. Detect project type ---
        String projectType = detectProjectType(msg);

        // --- 4. Calculate required materials ---
        List<MaterialLine> lines = buildMaterialList(projectType, woodType, width, depth, height);

        // --- 5. Match to store items ---
        List<Item> allItems = itemRepository.findAll();
        lines = lines.stream()
                .map(line -> matchToStore(line, allItems))
                .collect(Collectors.toList());

        String summary = String.format(
                "Project: %s | Material: %s | %.1fm wide × %.1fm deep × %.1fm high",
                capitalize(projectType), capitalize(woodType), width, depth, height);

        return AgentResponse.builder()
                .projectSummary(summary)
                .materials(lines)
                .build();
    }

    // -------------------------------------------------------------------------
    // Dimension extraction
    // -------------------------------------------------------------------------

    private double extractDimension(String msg, String... keywords) {
        for (String kw : keywords) {
            // e.g. "4m width" or "width 4m" or "width: 4m" or "4 meters wide"
            Pattern p = Pattern.compile(kw + "[:\\s]+([0-9.]+)\\s*(?:m|meter|metre|cm|mm)?");
            Matcher m = p.matcher(msg);
            if (m.find()) return toMetres(m.group(1), msg, m.start());

            p = Pattern.compile("([0-9.]+)\\s*(?:m|meter|metre|cm|mm)?\\s*" + kw);
            m = p.matcher(msg);
            if (m.find()) return toMetres(m.group(1), msg, m.start());
        }
        return 0;
    }

    private double toMetres(String value, String context, int pos) {
        double v = Double.parseDouble(value);
        // check unit in nearby text
        String nearby = context.substring(Math.max(0, pos - 3), Math.min(context.length(), pos + value.length() + 5));
        if (nearby.contains("cm")) return v / 100.0;
        if (nearby.contains("mm")) return v / 1000.0;
        return v; // assume metres
    }

    // -------------------------------------------------------------------------
    // Type detection
    // -------------------------------------------------------------------------

    private String detectWoodType(String msg) {
        if (msg.contains("oak"))        return "oak";
        if (msg.contains("pine"))       return "pine";
        if (msg.contains("walnut"))     return "walnut";
        if (msg.contains("plywood"))    return "plywood";
        if (msg.contains("mdf"))        return "mdf";
        if (msg.contains("birch"))      return "birch";
        if (msg.contains("mahogany"))   return "mahogany";
        return "wood";
    }

    private String detectProjectType(String msg) {
        if (msg.contains("closet") || msg.contains("wardrobe")) return "wall closet";
        if (msg.contains("shelf") || msg.contains("shelving"))  return "shelving unit";
        if (msg.contains("table"))                               return "table";
        if (msg.contains("cabinet"))                             return "cabinet";
        if (msg.contains("desk"))                                return "desk";
        if (msg.contains("bed"))                                 return "bed frame";
        if (msg.contains("fence"))                               return "fence";
        if (msg.contains("deck"))                                return "deck";
        return "woodwork project";
    }

    // -------------------------------------------------------------------------
    // Material calculation
    // -------------------------------------------------------------------------

    private List<MaterialLine> buildMaterialList(String project, String woodType,
                                                  double width, double depth, double height) {
        List<MaterialLine> lines = new ArrayList<>();

        double panelArea;
        int screwCount;
        double glueKg;
        double sandpaperM2;

        switch (project) {
            case "wall closet", "cabinet", "wardrobe" -> {
                // Back panel + 2 sides + top + bottom + shelves (assume 3 shelves)
                panelArea   = (width * height)          // back
                        + 2 * (depth * height)          // sides
                        + 2 * (width * depth)           // top + bottom
                        + 3 * (width * depth);          // 3 shelves
                screwCount  = (int) Math.ceil(panelArea * 12);
                glueKg      = Math.ceil(panelArea * 0.15);
                sandpaperM2 = Math.ceil(panelArea * 1.2);
            }
            case "table", "desk" -> {
                panelArea   = width * depth + 4 * (0.05 * height); // top + 4 legs (5cm thick)
                screwCount  = 32;
                glueKg      = 0.5;
                sandpaperM2 = Math.ceil((width * depth) * 1.2);
            }
            case "shelving unit" -> {
                int shelves = (int) Math.ceil(height / 0.35);
                panelArea   = shelves * (width * depth) + 2 * (height * depth);
                screwCount  = shelves * 8;
                glueKg      = 0.3 * shelves;
                sandpaperM2 = Math.ceil(panelArea);
            }
            default -> {
                panelArea   = width * height;
                screwCount  = (int) Math.ceil(panelArea * 10);
                glueKg      = 1.0;
                sandpaperM2 = Math.ceil(panelArea);
            }
        }

        // Round up with 10% waste factor
        double woodM2 = Math.ceil(panelArea * 1.1 * 10) / 10.0;

        lines.add(MaterialLine.builder()
                .materialType(capitalize(woodType) + " Board / Panel")
                .requiredQuantity(woodM2)
                .unit("M2")
                .matchedItems(new ArrayList<>())
                .build());

        lines.add(MaterialLine.builder()
                .materialType("Wood Screws")
                .requiredQuantity(screwCount)
                .unit("UNIT")
                .matchedItems(new ArrayList<>())
                .build());

        lines.add(MaterialLine.builder()
                .materialType("Wood Glue")
                .requiredQuantity(glueKg)
                .unit("KG")
                .matchedItems(new ArrayList<>())
                .build());

        lines.add(MaterialLine.builder()
                .materialType("Sandpaper")
                .requiredQuantity(sandpaperM2)
                .unit("M2")
                .matchedItems(new ArrayList<>())
                .build());

        return lines;
    }

    // -------------------------------------------------------------------------
    // Store matching
    // -------------------------------------------------------------------------

    private MaterialLine matchToStore(MaterialLine line, List<Item> allItems) {
        String keyword = extractSearchKeyword(line.getMaterialType());

        List<Item> candidates = allItems.stream()
                .filter(item -> matchesKeyword(item, keyword))
                .sorted(Comparator.comparing(Item::getPrice))
                .collect(Collectors.toList());

        if (candidates.isEmpty()) {
            // Broader fallback — match by unit
            candidates = allItems.stream()
                    .filter(item -> item.getUnit() != null
                            && item.getUnit().name().equalsIgnoreCase(line.getUnit()))
                    .sorted(Comparator.comparing(Item::getPrice))
                    .collect(Collectors.toList());
        }

        List<MatchedItem> matched = new ArrayList<>();
        for (int i = 0; i < Math.min(candidates.size(), 3); i++) {
            Item item = candidates.get(i);
            matched.add(MatchedItem.builder()
                    .itemId(item.getId())
                    .name(item.getName())
                    .price(item.getPrice())
                    .unit(item.getUnit() != null ? item.getUnit().name() : "")
                    .availableQuantity(item.getQuantity())
                    .providerName(item.getProvider() != null ? item.getProvider().getName() : "")
                    .lowestPrice(i == 0)
                    .build());
        }

        return MaterialLine.builder()
                .materialType(line.getMaterialType())
                .requiredQuantity(line.getRequiredQuantity())
                .unit(line.getUnit())
                .matchedItems(matched)
                .build();
    }

    private boolean matchesKeyword(Item item, String keyword) {
        String name     = item.getName()     != null ? item.getName().toLowerCase()     : "";
        String category = item.getCategory() != null ? item.getCategory().name().toLowerCase() : "";
        String type     = item.getType()     != null ? item.getType().toLowerCase()     : "";
        return name.contains(keyword) || category.contains(keyword) || type.contains(keyword);
    }

    private String extractSearchKeyword(String materialType) {
        String lower = materialType.toLowerCase();
        if (lower.contains("screw"))      return "screw";
        if (lower.contains("glue"))       return "glue";
        if (lower.contains("sandpaper"))  return "sandpaper";
        if (lower.contains("oak"))        return "oak";
        if (lower.contains("pine"))       return "pine";
        if (lower.contains("plywood"))    return "plywood";
        if (lower.contains("mdf"))        return "mdf";
        if (lower.contains("walnut"))     return "walnut";
        if (lower.contains("birch"))      return "birch";
        if (lower.contains("board") || lower.contains("panel")) return "wood";
        return lower.split(" ")[0];
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}
