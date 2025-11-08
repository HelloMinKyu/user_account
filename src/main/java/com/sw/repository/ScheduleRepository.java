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

    @Query(value = "SELECT s.schedule_date, s.leader, s.fund_members, s.nonfund_members " +
            "FROM schedule_info s " +
            "WHERE YEAR(s.schedule_date) = :year AND MONTH(s.schedule_date) = :month",
            nativeQuery = true)
    List<Object[]> getMonthlyRaw(@Param("year") int year, @Param("month") int month);


    @Query(value = "SELECT * FROM schedule_info WHERE DATE(schedule_date) = :date", nativeQuery = true)
    Schedule findByScheduleDate(@Param("date") String date);

}
