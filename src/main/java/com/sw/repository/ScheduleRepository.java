package com.sw.repository;

import com.sw.jpa.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    @Query("SELECT s FROM Schedule s WHERE s.scheduleDate BETWEEN :startDate AND :endDate ORDER BY s.scheduleDate ASC")
    List<Schedule> findByMonth(@Param("startDate") Date startDate, @Param("endDate") Date endDate);

    @Query(value =
            "(SELECT " +
                    " m.srno AS srno, " +
                    " m.name AS member_name, " +
                    " m.gender AS gender, " +
                    " m.region AS region, " +
                    " COUNT(s.schedule_date) AS leader_count, " +
                    " 0 AS fund_count, " +
                    " 0 AS nonfund_count, " +
                    " GROUP_CONCAT(CONCAT(DAY(s.schedule_date), ':벙주') ORDER BY s.schedule_date SEPARATOR ',') AS daily_log " +
                    " FROM member_info m " +
                    " LEFT JOIN schedule_info s ON s.leader = m.name " +
                    "  AND MONTH(s.schedule_date) = :month AND YEAR(s.schedule_date) = :year " +
                    " GROUP BY m.srno, m.name, m.gender, m.region) " +

                    "UNION ALL " +

                    "(SELECT " +
                    " m.srno, m.name, m.gender, m.region, " +
                    " 0 AS leader_count, " +
                    " COUNT(s.schedule_date) AS fund_count, " +
                    " 0 AS nonfund_count, " +
                    " GROUP_CONCAT(CONCAT(DAY(s.schedule_date), ':공금') ORDER BY s.schedule_date SEPARATOR ',') AS daily_log " +
                    " FROM member_info m " +
                    " LEFT JOIN schedule_info s ON FIND_IN_SET(m.name, s.fund_members) > 0 " +
                    "  AND MONTH(s.schedule_date) = :month AND YEAR(s.schedule_date) = :year " +
                    " GROUP BY m.srno, m.name, m.gender, m.region) " +

                    "UNION ALL " +

                    "(SELECT " +
                    " m.srno, m.name, m.gender, m.region, " +
                    " 0 AS leader_count, " +
                    " 0 AS fund_count, " +
                    " COUNT(s.schedule_date) AS nonfund_count, " +
                    " GROUP_CONCAT(CONCAT(DAY(s.schedule_date), ':비공금') ORDER BY s.schedule_date SEPARATOR ',') AS daily_log " +
                    " FROM member_info m " +
                    " LEFT JOIN schedule_info s ON FIND_IN_SET(m.name, s.nonfund_members) > 0 " +
                    "  AND MONTH(s.schedule_date) = :month AND YEAR(s.schedule_date) = :year " +
                    " GROUP BY m.srno, m.name, m.gender, m.region) ",
            nativeQuery = true)
    List<Object[]> getMonthlyStats(@Param("year") int year, @Param("month") int month);



}
