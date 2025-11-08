package com.sw.service;

import com.sw.DTO.MonthlyStatsDto;
import com.sw.DTO.ScheduleDto;
import com.sw.jpa.Member;
import com.sw.jpa.Schedule;
import com.sw.repository.MemberRepository;
import com.sw.repository.ScheduleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ScheduleService {
    private final ScheduleRepository scheduleRepository;
    private final MemberRepository memberRepository;

    public ScheduleService(ScheduleRepository scheduleRepository, MemberRepository memberRepository) {
        this.scheduleRepository = scheduleRepository;
        this.memberRepository = memberRepository;
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

    @Transactional(readOnly = true)
    public List<MonthlyStatsDto> getMonthlyStats(int year, int month) {
        // 1한 달치 일정 원본 데이터
        List<Object[]> schedules = scheduleRepository.getMonthlyRaw(year, month);

        // 2모든 회원 목록 (정렬된 순서로 가져오기)
        List<Member> members = memberRepository.findAllByOrderByNameAsc();

        Map<String, MonthlyStatsDto> map = new LinkedHashMap<>();

        // 3전체 멤버를 먼저 DTO로 초기화 (LEFT JOIN 역할)
        for (Member m : members) {
            MonthlyStatsDto dto = new MonthlyStatsDto();
            dto.setMemberName(m.getName());
            dto.setGender(m.getGender());
            dto.setRegion(m.getRegion());
            dto.setLeaderCount(0);
            dto.setFundCount(0);
            dto.setNonFundCount(0);
            dto.setDailyLog(new StringBuilder());
            map.put(m.getName(), dto);
        }

        // 4일정별 순회하며 누적 카운트
        for (Object[] row : schedules) {
            LocalDate date = ((Date) row[0]).toLocalDate();
            String day = String.valueOf(date.getDayOfMonth());
            String leader = (String) row[1];
            String fund = (String) row[2];
            String nonfund = (String) row[3];

            for (MonthlyStatsDto dto : map.values()) {
                String name = dto.getMemberName();

                if (leader != null && matchMember(leader, name)) dto.addLeader(day);
                if (fund != null && matchMember(fund, name)) dto.addFund(day);
                if (nonfund != null && matchMember(nonfund, name)) dto.addNonFund(day);
            }
        }

        // 5정렬 유지된 리스트 반환
        return new ArrayList<>(map.values());
    }


    /**  “84 상철, 91 승현” 같은 문자열에서도 이름만으로 매칭 */
    private boolean matchMember(String field, String name) {
        if (field == null || name == null) return false;

        // 1 쉼표 기준 분리
        String[] tokens = field.split(",");

        for (String token : tokens) {
            String clean = token.trim();

            // (1) 이름만 추출 시도 — 첫 공백 뒤 문자열
            String afterSpace = clean;
            int spaceIdx = clean.indexOf(' ');
            if (spaceIdx >= 0 && spaceIdx < clean.length() - 1) {
                afterSpace = clean.substring(spaceIdx + 1).trim();
            }

            // (2) 매칭 조건 (양방향 모두 확인)
            if (clean.equals(name)         // 완전히 동일
                    || afterSpace.equals(name)  // 번호 제거 후 이름만 동일
                    || name.equals(afterSpace)  // member.name 쪽이 번호포함 형태일 때
                    || clean.endsWith(name)     // 혹시 붙어있을 경우 (96김형민)
            ) {
                return true;
            }
        }
        return false;
    }

    public Map<String, List<MonthlyStatsDto>> getMonthlyTop3(int year, int month) {
        List<MonthlyStatsDto> allStats = getMonthlyStats(year, month);
        Map<String, List<MonthlyStatsDto>> topMap = new LinkedHashMap<>();

        topMap.put("leaderTop", extractTopWithTies(allStats, "leader"));
        topMap.put("fundTop", extractTopWithTies(allStats, "fund"));
        topMap.put("nonFundTop", extractTopWithTies(allStats, "nonfund"));

        return topMap;
    }

    /** ✅ 공동 순위 처리 (TOP3 동점자 포함) */
    private List<MonthlyStatsDto> extractTopWithTies(List<MonthlyStatsDto> list, String type) {
        if (list == null || list.isEmpty()) return Collections.emptyList();

        Comparator<MonthlyStatsDto> comp;
        switch (type) {
            case "leader": comp = Comparator.comparingInt(MonthlyStatsDto::getLeaderCount).reversed(); break;
            case "fund": comp = Comparator.comparingInt(MonthlyStatsDto::getFundCount).reversed(); break;
            case "nonfund": comp = Comparator.comparingInt(MonthlyStatsDto::getNonFundCount).reversed(); break;
            default: throw new IllegalArgumentException("Unknown type: " + type);
        }

        List<MonthlyStatsDto> sorted = list.stream()
                .filter(dto -> {
                    int v = (type.equals("leader") ? dto.getLeaderCount()
                            : type.equals("fund") ? dto.getFundCount() : dto.getNonFundCount());
                    return v > 0; // 참여한 사람만
                })
                .sorted(comp)
                .collect(java.util.stream.Collectors.toList());

        if (sorted.isEmpty()) return Collections.emptyList();

        // TOP3 “공동 순위” 기준점
        List<MonthlyStatsDto> result = new ArrayList<>();
        int rankCount = 0;
        int prevValue = -1;

        for (MonthlyStatsDto dto : sorted) {
            int currentValue = (type.equals("leader") ? dto.getLeaderCount()
                    : type.equals("fund") ? dto.getFundCount() : dto.getNonFundCount());

            if (prevValue == -1) prevValue = currentValue;
            if (currentValue < prevValue && ++rankCount >= 3) break; // TOP3 안에서만 보여주기
            result.add(dto);
            prevValue = currentValue;
        }

        return result;
    }

    public Schedule getScheduleByDate(LocalDate date) {
        return scheduleRepository.findByScheduleDate(date.toString());
    }
}
