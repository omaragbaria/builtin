package com.builtin.service.impl;

import com.builtin.dto.CalculatorRequest;
import com.builtin.dto.CalculatorResponse;
import com.builtin.dto.CalculatorResponse.MaterialLine;
import com.builtin.dto.CalculatorResponse.MatchedItem;
import com.builtin.model.Item;
import com.builtin.repository.ItemRepository;
import com.builtin.service.CalculatorService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CalculatorServiceImpl implements CalculatorService {

    private final ItemRepository itemRepository;

    @Override
    public CalculatorResponse calculate(CalculatorRequest req) {
        String type = req.getStructureType().toUpperCase();
        List<MaterialLine> lines = switch (type) {
            case "ROOF_SLAB" -> calcRoofSlab(req);
            case "WALL"      -> calcWall(req);
            default          -> calcRoofSlab(req); // safe fallback
        };

        List<Item> allItems = itemRepository.findAll();
        lines = lines.stream()
                .map(line -> matchToStore(line, allItems))
                .collect(Collectors.toList());

        String summary = buildSummary(type, req);
        return CalculatorResponse.builder()
                .structureSummary(summary)
                .materials(lines)
                .build();
    }

    // -------------------------------------------------------------------------
    // Roof slab formulas
    // -------------------------------------------------------------------------

    private List<MaterialLine> calcRoofSlab(CalculatorRequest req) {
        double l = req.getLength();
        double w = req.getWidth();
        double t = req.getThickness() > 0 ? req.getThickness() : 0.20; // default 20 cm

        double volume    = l * w * t;                     // m³
        double rebarKg   = Math.ceil(volume * 110 * 1.05); // 110 kg/m³ + 5% waste
        double meshM2    = Math.ceil(l * w * 1.10);        // slab area + 10% overlap
        double concM3    = Math.ceil(volume * 1.05 * 10.0) / 10.0; // +5% waste

        List<MaterialLine> lines = new ArrayList<>();
        lines.add(line("Concrete (Ready-Mix)", concM3, "M3"));
        lines.add(line("Iron Rebar (Ø12mm)", rebarKg, "KG"));
        lines.add(line("Wire Mesh", meshM2, "M2"));
        return lines;
    }

    // -------------------------------------------------------------------------
    // Wall formulas
    // -------------------------------------------------------------------------

    private List<MaterialLine> calcWall(CalculatorRequest req) {
        double l = req.getLength();
        double h = req.getHeight() > 0 ? req.getHeight() : 3.0;
        double t = req.getThickness() > 0 ? req.getThickness() : 0.20;

        double volume    = l * h * t;
        double rebarKg   = Math.ceil(volume * 90 * 1.05);  // 90 kg/m³ for walls
        double blocks    = Math.ceil((l * h) / (0.40 * 0.20) * 1.05); // standard block 40×20cm
        double concM3    = Math.ceil(volume * 0.3 * 1.05 * 10.0) / 10.0; // 30% of volume is concrete

        List<MaterialLine> lines = new ArrayList<>();
        lines.add(line("Concrete (Ready-Mix)", concM3, "M3"));
        lines.add(line("Iron Rebar (Ø10mm)", rebarKg, "KG"));
        lines.add(line("Hollow Blocks (40×20cm)", blocks, "UNIT"));
        return lines;
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private MaterialLine line(String type, double qty, String unit) {
        return MaterialLine.builder()
                .materialType(type)
                .requiredQuantity(qty)
                .unit(unit)
                .matchedItems(new ArrayList<>())
                .build();
    }

    private String buildSummary(String type, CalculatorRequest req) {
        if ("WALL".equals(type)) {
            return String.format("Wall — %.1fm long × %.1fm high × %.0fcm thick",
                    req.getLength(), req.getHeight(), req.getThickness() * 100);
        }
        return String.format("Roof Slab — %.1fm × %.1fm × %.0fcm thick",
                req.getLength(), req.getWidth(), req.getThickness() * 100);
    }

    private MaterialLine matchToStore(MaterialLine line, List<Item> allItems) {
        String keyword = searchKeyword(line.getMaterialType());

        List<Item> candidates = allItems.stream()
                .filter(item -> matchesKeyword(item, keyword))
                .sorted(Comparator.comparing(Item::getPrice))
                .collect(Collectors.toList());

        if (candidates.isEmpty()) {
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
        String category = item.getCategory() != null ? item.getCategory().toLowerCase() : "";
        String type     = item.getType()     != null ? item.getType().toLowerCase()     : "";
        return name.contains(keyword) || category.contains(keyword) || type.contains(keyword);
    }

    private String searchKeyword(String materialType) {
        String lower = materialType.toLowerCase();
        if (lower.contains("concrete") || lower.contains("cement")) return "concrete";
        if (lower.contains("rebar") || lower.contains("iron"))      return "iron";
        if (lower.contains("mesh"))                                  return "mesh";
        if (lower.contains("block") || lower.contains("brick"))     return "block";
        return lower.split("[^a-z]")[0]; // first word
    }
}
