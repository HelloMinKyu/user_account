package com.sw.controller;

import com.sw.jpa.Fund;
import com.sw.repository.FundRepository;
import com.sw.service.FundService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/fund")
@RequiredArgsConstructor
public class FundController {
    private final FundService fundService;
    private final FundRepository fundRepository;

    @GetMapping("/month")
    public List<Fund> getMonthly(@RequestParam int year, @RequestParam int month) {
        return fundService.findByMonth(year, month);
    }

    @PostMapping("/save")
    public ResponseEntity<?> save(@RequestBody Fund f) {
        try {
            fundService.saveOrUpdate(f);
            return ResponseEntity.ok("공금정보 저장완료");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("저장 실패: " + e.getMessage());
        }
    }

    @GetMapping("/daily")
    public ResponseEntity<?> getFundData(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date date) {

        Map<String, Object> data = fundService.getFundSummary(date);
        return ResponseEntity.ok(data);
    }

    @GetMapping("/all")
    public ResponseEntity<List<Fund>> getAllFunds() {
        List<Fund> funds = fundRepository.findAll(Sort.by("fundDate"));
        return ResponseEntity.ok(funds);
    }
}
