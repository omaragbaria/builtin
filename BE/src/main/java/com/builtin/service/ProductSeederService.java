package com.builtin.service;

import com.builtin.model.*;
import com.builtin.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductSeederService {

    private final ItemRepository itemRepository;
    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public void seed() {
        log.info("Starting product seeding from products_en.xlsx...");
        clearDatabase();
        loadFromXlsx();
        log.info("Seeding complete. Total items: {}", itemRepository.count());
    }

    private void clearDatabase() {
        jdbcTemplate.update("UPDATE users SET provider_id = NULL WHERE provider_id IS NOT NULL");
        jdbcTemplate.update("DELETE FROM item_photos");
        jdbcTemplate.update("DELETE FROM items");
        jdbcTemplate.update("DELETE FROM providers");
        log.info("Database cleared.");
    }

    private void loadFromXlsx() {
        try (InputStream is = new ClassPathResource("products_en.xlsx").getInputStream();
             Workbook wb = new XSSFWorkbook(is)) {

            FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();

            for (Sheet sheet : wb) {
                ItemCategory category = sheetToCategory(sheet.getSheetName());
                if (category == null) {
                    log.warn("Skipping unknown sheet: {}", sheet.getSheetName());
                    continue;
                }
                processSheet(sheet, category, evaluator);
            }
        } catch (Exception e) {
            log.error("Failed to seed products", e);
            throw new RuntimeException("Product seeding failed", e);
        }
    }

    private void processSheet(Sheet sheet, ItemCategory category, FormulaEvaluator evaluator) {
        Row headerRow = sheet.getRow(1);
        if (headerRow == null) return;

        Map<String, Integer> cols = buildColIndex(headerRow, evaluator);

        int skuCol       = cols.getOrDefault("sku", 0);
        int nameCol      = cols.getOrDefault("product name", 1);
        int qtyCol       = findQtyCol(cols);
        int descCol      = findDescCol(cols);
        int gritCol      = cols.getOrDefault("grit", -1);
        int priceCol     = cols.getOrDefault("price", -1);
        int custCol      = cols.getOrDefault("customer price", -1);
        int contrCol     = cols.getOrDefault("contractor price", -1);

        int count = 0;
        for (int r = 2; r <= sheet.getLastRowNum(); r++) {
            Row row = sheet.getRow(r);
            if (row == null) continue;

            String name = getString(row, nameCol, evaluator);
            if (name == null || name.isBlank()) continue;

            BigDecimal price = getBigDecimal(row, priceCol, evaluator);
            if (price == null) price = BigDecimal.ZERO;

            String sku  = getString(row, skuCol, evaluator);
            String desc = descCol >= 0 ? getString(row, descCol, evaluator) : null;
            String grit = gritCol >= 0 ? getString(row, gritCol, evaluator) : null;

            Integer qty = getInt(row, qtyCol, evaluator);
            // Sealing sheet: qty is embedded in description ("12 | 290 ml | Clear")
            if (qty == null && desc != null && desc.contains("|")) {
                String[] parts = desc.split("\\|");
                try { qty = Integer.parseInt(parts[0].trim()); } catch (Exception ignored) {}
            }

            String fullDesc = grit != null ? grit + " | " + (desc != null ? desc : "") : desc;

            ItemColor color = extractColor(category, desc, name);
            ItemUnit unit   = extractUnit(fullDesc);

            Item item = Item.builder()
                    .name(name)
                    .nameAr(name)
                    .nameHe(name)
                    .nameRu(name)
                    .nameZh(name)
                    .serialNumber(sku)
                    .category(category)
                    .color(color)
                    .qtyPerPackage(qty != null ? qty : 0)
                    .price(price)
                    .customerPrice(getBigDecimal(row, custCol, evaluator))
                    .contractorPrice(getBigDecimal(row, contrCol, evaluator))
                    .unit(unit)
                    .quantity(0)
                    .type(category.name())
                    .shippingTime("STANDARD")
                    .build();

            itemRepository.save(item);
            count++;
        }
        log.info("  Sheet '{}': {} items seeded", sheet.getSheetName(), count);
    }

    // --- Column helpers ---

    private Map<String, Integer> buildColIndex(Row header, FormulaEvaluator evaluator) {
        Map<String, Integer> map = new HashMap<>();
        for (Cell cell : header) {
            String val = getString(cell, evaluator);
            if (val != null && !val.isBlank())
                map.put(val.trim().toLowerCase(), cell.getColumnIndex());
        }
        return map;
    }

    private int findQtyCol(Map<String, Integer> cols) {
        for (Map.Entry<String, Integer> e : cols.entrySet())
            if (e.getKey().startsWith("qty")) return e.getValue();
        return 2;
    }

    private int findDescCol(Map<String, Integer> cols) {
        if (cols.containsKey("color/weight"))       return cols.get("color/weight");
        if (cols.containsKey("description/weight")) return cols.get("description/weight");
        if (cols.containsKey("description/diameter")) return cols.get("description/diameter");
        return 3;
    }

    // --- Color extraction ---

    private ItemColor extractColor(ItemCategory category, String desc, String name) {
        return switch (category) {
            case SEALING_AND_ADHESIVES -> {
                // desc = "12 | 290 ml | Clear" → last segment
                if (desc != null && desc.contains("|")) {
                    String[] parts = desc.split("\\|");
                    yield parseColor(parts[parts.length - 1].trim());
                }
                yield ItemColor.NA;
            }
            case CERAMICS_AND_TILING -> {
                // desc = "5 kg | White | 100" → middle segment
                if (desc != null && desc.contains("|")) {
                    String[] parts = desc.split("\\|");
                    if (parts.length >= 2) yield parseColor(parts[1].trim());
                }
                yield ItemColor.NA;
            }
            case PLASTERBOARD -> {
                // name = "White Plasterboard" → first word
                if (name != null) {
                    ItemColor c = parseColor(name.split(" ")[0].trim());
                    yield c != ItemColor.NA ? c : ItemColor.NA;
                }
                yield ItemColor.NA;
            }
            default -> ItemColor.NA;
        };
    }

    private ItemColor parseColor(String raw) {
        if (raw == null) return ItemColor.NA;
        String key = raw.trim().toUpperCase().replace(" ", "_").replace("-", "_");
        return switch (key) {
            case "CLEAR"         -> ItemColor.CLEAR;
            case "WHITE"         -> ItemColor.WHITE;
            case "BLACK"         -> ItemColor.BLACK;
            case "GRAY"          -> ItemColor.GRAY;
            case "PERGAMON"      -> ItemColor.PERGAMON;
            case "JERICHO_WHITE" -> ItemColor.JERICHO_WHITE;
            case "MANHATTAN"     -> ItemColor.MANHATTAN;
            case "SILVER"        -> ItemColor.SILVER;
            case "MEDIUM_GRAY"   -> ItemColor.MEDIUM_GRAY;
            case "CONCRETE_GRAY" -> ItemColor.CONCRETE_GRAY;
            case "CHARCOAL"      -> ItemColor.CHARCOAL;
            case "JASMINE"       -> ItemColor.JASMINE;
            case "VANILLA"       -> ItemColor.VANILLA;
            case "BEIGE"         -> ItemColor.BEIGE;
            case "GREEN"         -> ItemColor.GREEN;
            case "BLUE"          -> ItemColor.BLUE;
            case "PINK"          -> ItemColor.PINK;
            default              -> ItemColor.NA;
        };
    }

    // --- Unit extraction ---

    private ItemUnit extractUnit(String desc) {
        if (desc == null) return ItemUnit.UNIT;
        String d = desc.toLowerCase();
        if (d.contains(" ml") || d.contains("ml |") || d.contains("ml-") || d.matches(".*\\d+ml.*"))
            return ItemUnit.MILLILITER;
        if (d.contains(" kg") || d.contains("kg ") || d.contains("kg|") || d.matches(".*\\d+kg.*"))
            return ItemUnit.KG;
        if (d.contains(" gr") || d.contains("gram"))
            return ItemUnit.GRAM;
        if (d.contains("m²") || d.contains("m2"))
            return ItemUnit.SQUARE_METER;
        return ItemUnit.UNIT;
    }

    // --- Sheet → Category mapping ---

    private ItemCategory sheetToCategory(String name) {
        return switch (name.trim()) {
            case "Sealing and Adhesives"    -> ItemCategory.SEALING_AND_ADHESIVES;
            case "Paints, Sprays, Cleaning" -> ItemCategory.PAINTS_SPRAYS_CLEANING;
            case "Cutting and Grinding"     -> ItemCategory.CUTTING_AND_GRINDING;
            case "Polishing and Sanding"    -> ItemCategory.POLISHING_AND_SANDING;
            case "Ceramics and Tiling"      -> ItemCategory.CERAMICS_AND_TILING;
            case "Plasterboard"             -> ItemCategory.PLASTERBOARD;
            case "Cement and Adhesives"     -> ItemCategory.CEMENT_AND_ADHESIVES;
            case "Iron Metal"               -> ItemCategory.IRON_AND_METAL;
            default                         -> null;
        };
    }

    // --- Cell value helpers ---

    private String getString(Row row, int col, FormulaEvaluator evaluator) {
        if (col < 0) return null;
        return getString(row.getCell(col), evaluator);
    }

    private String getString(Cell cell, FormulaEvaluator evaluator) {
        if (cell == null) return null;
        CellType type = cell.getCellType() == CellType.FORMULA
                ? evaluator.evaluate(cell).getCellType()
                : cell.getCellType();
        return switch (type) {
            case STRING -> {
                String v = cell.getStringCellValue().trim();
                yield v.isEmpty() ? null : v;
            }
            case NUMERIC -> {
                double d = cell.getCellType() == CellType.FORMULA
                        ? evaluator.evaluate(cell).getNumberValue()
                        : cell.getNumericCellValue();
                yield d == Math.floor(d) ? String.valueOf((long) d) : String.valueOf(d);
            }
            default -> null;
        };
    }

    private Integer getInt(Row row, int col, FormulaEvaluator evaluator) {
        if (col < 0) return null;
        Cell cell = row.getCell(col);
        if (cell == null) return null;
        CellType type = cell.getCellType() == CellType.FORMULA
                ? evaluator.evaluate(cell).getCellType()
                : cell.getCellType();
        if (type == CellType.NUMERIC) {
            double d = cell.getCellType() == CellType.FORMULA
                    ? evaluator.evaluate(cell).getNumberValue()
                    : cell.getNumericCellValue();
            return (int) d;
        }
        if (type == CellType.STRING) {
            String s = cell.getStringCellValue().replaceAll("[^0-9]", "");
            return s.isEmpty() ? null : Integer.parseInt(s);
        }
        return null;
    }

    private BigDecimal getBigDecimal(Row row, int col, FormulaEvaluator evaluator) {
        if (col < 0) return null;
        Cell cell = row.getCell(col);
        if (cell == null) return null;
        CellType type = cell.getCellType() == CellType.FORMULA
                ? evaluator.evaluate(cell).getCellType()
                : cell.getCellType();
        if (type == CellType.NUMERIC) {
            double d = cell.getCellType() == CellType.FORMULA
                    ? evaluator.evaluate(cell).getNumberValue()
                    : cell.getNumericCellValue();
            return BigDecimal.valueOf(d).setScale(2, RoundingMode.HALF_UP);
        }
        return null;
    }
}
