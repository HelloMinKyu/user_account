package com.sw.controller;

import com.sw.DTO.MonthlyStatsDto;
import com.sw.DTO.ScheduleDto;
import com.sw.jpa.Schedule;
import com.sw.service.ScheduleService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/schedule")
public class ScheduleController {
    private final ScheduleService scheduleService;

    public ScheduleController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @PostMapping("/save")
    public ResponseEntity<String> saveSchedule(@RequestBody ScheduleDto dto) {
        scheduleService.save(dto);
        return ResponseEntity.ok("일정이 저장되었습니다.");
    }

    @GetMapping("/month")
    public ResponseEntity<List<Schedule>> getSchedulesByMonth(
            @RequestParam int year,
            @RequestParam int month) {

        List<Schedule> list = scheduleService.findByMonth(year, month);
        return ResponseEntity.ok(list);
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateSchedule(@RequestBody Schedule updated) {
        if (updated.getSrno() == null)
            return ResponseEntity.badRequest().body("SRNO가 없습니다.");

        Schedule existing = scheduleService.findById(updated.getSrno());
        if (existing == null)
            return ResponseEntity.badRequest().body("해당 일정이 존재하지 않습니다.");

        existing.setScheduleDate(updated.getScheduleDate());
        existing.setLeader(updated.getLeader());
        existing.setFundMembers(updated.getFundMembers());
        existing.setNonFundMembers(updated.getNonFundMembers());

        scheduleService.save(existing);
        return ResponseEntity.ok("일정이 수정되었습니다.");
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable Long id) {
        scheduleService.delete(id);
        return ResponseEntity.ok("일정이 삭제되었습니다.");
    }

    @GetMapping(value = "/user/month", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<MonthlyStatsDto>> getStats(
            @RequestParam int year,
            @RequestParam int month) {

        List<MonthlyStatsDto> result = scheduleService.getMonthlyStats(year, month);

        if (result == null || result.isEmpty()) {
            // Java 8 호환 빈 리스트 생성
            return ResponseEntity.ok(new ArrayList<>());
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping(value = "/user/top3", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, List<MonthlyStatsDto>>> getTop3(
            @RequestParam int year,
            @RequestParam int month) {

        Map<String, List<MonthlyStatsDto>> result = scheduleService.getMonthlyTop3(year, month);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/check")
    public ResponseEntity<?> checkSchedule(@RequestParam String date) {
        Map<String, Object> result = new HashMap<>();
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate parsedDate = LocalDate.parse(date, formatter);

            Schedule schedule = scheduleService.getScheduleByDate(parsedDate);
            if (schedule != null) {
                result.put("exists", true);
                result.put("schedule", schedule);
            } else {
                result.put("exists", false);
            }
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            result.put("exists", false);
            result.put("error", "날짜 파싱 오류 또는 서버 오류: " + e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
    }

}
