package com.example.worktrack.controller.util;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/util")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Utilities", description = "API các tiện ích format và validation")
public class UtilController {

    /**
     * Format số tiền thành định dạng tiền tệ VNĐ
     */
    @PostMapping("/format-currency")
    @Operation(summary = "Format số tiền thành định dạng tiền tệ VNĐ")
    public ResponseEntity<Map<String, Object>> formatCurrency(@RequestBody Map<String, Object> request) {
        try {
            Object amountObj = request.get("amount");
            BigDecimal amount;

            if (amountObj instanceof Number) {
                amount = BigDecimal.valueOf(((Number) amountObj).doubleValue());
            } else if (amountObj instanceof String) {
                amount = new BigDecimal((String) amountObj);
            } else {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Invalid amount format"));
            }

            String formatted = formatCurrency(amount);

            Map<String, Object> result = new HashMap<>();
            result.put("originalAmount", amount);
            result.put("formattedAmount", formatted);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error formatting currency: " + e.getMessage()));
        }
    }

    /**
     * Tính số ngày giữa hai ngày
     */
    @PostMapping("/calculate-days")
    @Operation(summary = "Tính số ngày giữa hai ngày")
    public ResponseEntity<Map<String, Object>> calculateDaysBetween(@RequestBody Map<String, Object> request) {
        try {
            String fromDateStr = (String) request.get("fromDate");
            String toDateStr = (String) request.get("toDate");

            LocalDate fromDate = LocalDate.parse(fromDateStr);
            LocalDate toDate = LocalDate.parse(toDateStr);

            long days = ChronoUnit.DAYS.between(fromDate, toDate) + 1; // Include both dates

            Map<String, Object> result = new HashMap<>();
            result.put("fromDate", fromDate);
            result.put("toDate", toDate);
            result.put("days", days);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error calculating days: " + e.getMessage()));
        }
    }

    /**
     * Format ngày giờ theo định dạng Việt Nam
     */
    @PostMapping("/format-datetime")
    @Operation(summary = "Format ngày giờ theo định dạng Việt Nam")
    public ResponseEntity<Map<String, Object>> formatDateTime(@RequestBody Map<String, Object> request) {
        try {
            String datetimeStr = (String) request.get("datetime");
            String pattern = (String) request.getOrDefault("pattern", "dd/MM/yyyy HH:mm");

            LocalDateTime dateTime = LocalDateTime.parse(datetimeStr);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(pattern);
            String formatted = dateTime.format(formatter);

            Map<String, Object> result = new HashMap<>();
            result.put("originalDateTime", dateTime);
            result.put("formattedDateTime", formatted);
            result.put("pattern", pattern);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error formatting datetime: " + e.getMessage()));
        }
    }

    /**
     * Validate và format số điện thoại Việt Nam
     */
    @PostMapping("/validate-phone")
    @Operation(summary = "Validate và format số điện thoại Việt Nam")
    public ResponseEntity<Map<String, Object>> validatePhone(@RequestBody Map<String, Object> request) {
        try {
            String phone = (String) request.get("phone");

            Map<String, Object> result = new HashMap<>();
            result.put("originalPhone", phone);

            if (phone == null || phone.trim().isEmpty()) {
                result.put("isValid", false);
                result.put("error", "Số điện thoại không được để trống");
                return ResponseEntity.ok(result);
            }

            // Remove spaces and special characters
            String cleanPhone = phone.replaceAll("[^0-9]", "");

            // Validate Vietnamese phone number
            boolean isValid = cleanPhone.matches("^(0[3-9][0-9]{8}|09[0-9]{8}|02[0-9]{9})$");

            result.put("cleanPhone", cleanPhone);
            result.put("isValid", isValid);

            if (!isValid) {
                result.put("error", "Số điện thoại không hợp lệ");
            } else {
                // Format phone number
                String formatted = formatPhoneNumber(cleanPhone);
                result.put("formattedPhone", formatted);
            }

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error validating phone: " + e.getMessage()));
        }
    }

    /**
     * Tính tỷ lệ phần trăm
     */
    @PostMapping("/calculate-percentage")
    @Operation(summary = "Tính tỷ lệ phần trăm")
    public ResponseEntity<Map<String, Object>> calculatePercentage(@RequestBody Map<String, Object> request) {
        try {
            Object partObj = request.get("part");
            Object totalObj = request.get("total");

            BigDecimal part = new BigDecimal(partObj.toString());
            BigDecimal total = new BigDecimal(totalObj.toString());

            if (total.compareTo(BigDecimal.ZERO) == 0) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Total cannot be zero"));
            }

            BigDecimal percentage = part.multiply(BigDecimal.valueOf(100))
                    .divide(total, 2, java.math.RoundingMode.HALF_UP);

            Map<String, Object> result = new HashMap<>();
            result.put("part", part);
            result.put("total", total);
            result.put("percentage", percentage);
            result.put("formattedPercentage", percentage + "%");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error calculating percentage: " + e.getMessage()));
        }
    }

    /**
     * Lấy thông tin thời gian hiện tại
     */
    @GetMapping("/current-time")
    @Operation(summary = "Lấy thông tin thời gian hiện tại")
    public ResponseEntity<Map<String, Object>> getCurrentTime() {
        LocalDateTime now = LocalDateTime.now();
        LocalDate today = LocalDate.now();

        Map<String, Object> result = new HashMap<>();
        result.put("currentDateTime", now);
        result.put("currentDate", today);
        result.put("timestamp", System.currentTimeMillis());
        result.put("dayOfWeek", today.getDayOfWeek().getValue());
        result.put("dayOfMonth", today.getDayOfMonth());
        result.put("month", today.getMonthValue());
        result.put("year", today.getYear());

        // Formatted versions
        result.put("formattedDateTime", now.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        result.put("formattedDate", today.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        result.put("formattedTime", now.format(DateTimeFormatter.ofPattern("HH:mm:ss")));

        return ResponseEntity.ok(result);
    }

    // Helper methods
    private String formatCurrency(BigDecimal amount) {
        NumberFormat numberFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
        return numberFormat.format(amount) + " ₫";
    }

    private String formatPhoneNumber(String phone) {
        if (phone.length() == 10) {
            return phone.substring(0, 4) + " " + phone.substring(4, 7) + " " + phone.substring(7);
        } else if (phone.length() == 11) {
            return phone.substring(0, 4) + " " + phone.substring(4, 7) + " " + phone.substring(7);
        }
        return phone;
    }
}