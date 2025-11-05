package com.sw.repository;

import com.sw.jpa.Fund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.Optional;

public interface FundRepository extends JpaRepository<Fund, Long> {
    List<Fund> findByFundDateBetween(LocalDate start, LocalDate end);
    Optional<Fund> findByFundDate(LocalDate date);

    // 전체 입출금 합계
    @Query("SELECT COALESCE(SUM(f.depositAmount),0), COALESCE(SUM(f.withdrawAmount),0), " +
            "COALESCE(SUM(f.depositAmount) - SUM(f.withdrawAmount),0) " +
            "FROM Fund f")
    Object[] findGlobalTotals();

    // 특정 날짜별 데이터 (달력 클릭 시 표시용)
    List<Fund> findByFundDate(Date fundDate);

}
