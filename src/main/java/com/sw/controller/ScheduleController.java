package com.sw.controller;

import com.sw.DTO.MonthlyStatDto;
import com.sw.DTO.ScheduleDto;
import com.sw.jpa.Schedule;
import com.sw.service.ScheduleService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @GetMapping("/user/month")
    public ResponseEntity<List<MonthlyStatDto>> getStats(
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(scheduleService.getMonthlyStats(year, month));
    }
}
