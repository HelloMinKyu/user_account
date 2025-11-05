package com.sw.service;

import com.sw.jpa.Fund;
import com.sw.repository.FundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class FundService {
    private final FundRepository fundRepository;

    public List<Fund> findByMonth(int year, int month) {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());
        return fundRepository.findByFundDateBetween(start, end);
    }

    public Fund saveOrUpdate(Fund f) {
        Optional<Fund> existing = fundRepository.findByFundDate(f.getFundDate());
        if(existing.isPresent()) {
            Fund old = existing.get();
            old.setDepositAmount(f.getDepositAmount());
            old.setWithdrawAmount(f.getWithdrawAmount());
            old.setBalanceAmount(f.getDepositAmount() - f.getWithdrawAmount());
            return fundRepository.save(old);
        } else {
            f.setBalanceAmount(f.getDepositAmount() - f.getWithdrawAmount());
            return fundRepository.save(f);
        }
    }

    public Map<String, Object> getFundSummary(Date fundDate) {
        Map<String, Object> result = new HashMap<>();

        // 전체 누적 합계
        Object[] totals = fundRepository.findGlobalTotals();
        int totalDeposit = ((Number) totals[0]).intValue();
        int totalWithdraw = ((Number) totals[1]).intValue();
        int totalBalance = ((Number) totals[2]).intValue();

        // 특정 날짜의 세부내역
        List<Fund> dailyList = fundRepository.findByFundDate(fundDate);

        result.put("fundList", dailyList);
        result.put("totalDeposit", totalDeposit);
        result.put("totalWithdraw", totalWithdraw);
        result.put("totalBalance", totalBalance);
        return result;
    }
}
