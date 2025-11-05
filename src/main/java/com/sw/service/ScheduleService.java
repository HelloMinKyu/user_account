package com.sw.service;

import com.sw.DTO.MonthlyStatDto;
import com.sw.DTO.ScheduleDto;
import com.sw.jpa.Schedule;
import com.sw.repository.ScheduleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@Service
public class ScheduleService {
    private final ScheduleRepository scheduleRepository;

    public ScheduleService(ScheduleRepository scheduleRepository) {
        this.scheduleRepository = scheduleRepository;
    }

    @Transactional(readOnly = true)
    public List<Schedule> findByMonth(int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        LocalDate start = ym.atDay(1);
        LocalDate end = ym.atEndOfMonth();
        return scheduleRepository.findByMonth(Date.valueOf(start), Date.valueOf(end));
    }

    @Transactional
    public void save(ScheduleDto dto) {
        if (dto.getScheduleDate() == null) {
            throw new IllegalArgumentException("날짜 형식이 잘못되었습니다: null");
        }

        Schedule entity = new Schedule();
        if (dto.getSrno() != null) { // 수정
            entity = scheduleRepository.findById(dto.getSrno())
                    .orElseThrow(() -> new IllegalArgumentException("해당 일정이 존재하지 않습니다: " + dto.getSrno()));
        }

        entity.setScheduleDate(dto.getScheduleDate());   //
        entity.setLeader(dto.getLeader());
        entity.setFundMembers(dto.getFundMembers());
        entity.setNonFundMembers(dto.getNonFundMembers());

        scheduleRepository.save(entity);
    }

    @Transactional
    public Schedule save(Schedule schedule) {
        return scheduleRepository.save(schedule);
    }

    @Transactional(readOnly = true)
    public Schedule findById(Long srno) {
        Optional<Schedule> opt = scheduleRepository.findById(srno);
        return opt.orElse(null);
    }

    // 일정 삭제
    @Transactional
    public void delete(Long id) {
        if (scheduleRepository.existsById(id)) {
            scheduleRepository.deleteById(id);
        } else {
            throw new RuntimeException("해당 일정(ID: " + id + ")을 찾을 수 없습니다.");
        }
    }

    public List<MonthlyStatDto> getMonthlyStats(int year, int month) {
        List<Object[]> rows = scheduleRepository.getMonthlyStats(year, month);

        Map<Long, MonthlyStatDto> map = new LinkedHashMap<>();

        for (Object[] r : rows) {
            Long srno = ((Number) r[0]).longValue();
            String name = (String) r[1];
            String gender = (String) r[2];
            String region = (String) r[3];
            int leader = ((Number) r[4]).intValue();
            int fund = ((Number) r[5]).intValue();
            int nonfund = ((Number) r[6]).intValue();
            String dailyLog = (String) r[7];

            MonthlyStatDto dto = map.get(srno);
            if (dto == null) {
                dto = new MonthlyStatDto();
                dto.setSrno(srno);
                dto.setMemberName(name);
                dto.setGender(gender);
                dto.setRegion(region);
                dto.setLeaderCount(leader);
                dto.setFundCount(fund);
                dto.setNonFundCount(nonfund);
                dto.setDailyLog(dailyLog != null ? dailyLog : "");
                map.put(srno, dto);
            } else {
                dto.setLeaderCount(dto.getLeaderCount() + leader);
                dto.setFundCount(dto.getFundCount() + fund);
                dto.setNonFundCount(dto.getNonFundCount() + nonfund);
                if (dailyLog != null && !dailyLog.isEmpty()) {
                    String combined = dto.getDailyLog().isEmpty()
                            ? dailyLog
                            : dto.getDailyLog() + "," + dailyLog;
                    dto.setDailyLog(combined);
                }
            }
        }
        return new ArrayList<>(map.values());
    }
}
