package com.sw.DTO;

import lombok.Data;

@Data
public class MonthlyStatsDto {
    private String memberName;
    private String gender;
    private String region;
    private int leaderCount;
    private int fundCount;
    private int nonFundCount;
    private StringBuilder dailyLog = new StringBuilder();

    public void addLeader(String day) {
        leaderCount++;
        if (dailyLog.length() > 0) dailyLog.append(",");
        dailyLog.append(day).append(":벙주");
    }

    public void addFund(String day) {
        fundCount++;
        if (dailyLog.length() > 0) dailyLog.append(",");
        dailyLog.append(day).append(":공금");
    }

    public void addNonFund(String day) {
        nonFundCount++;
        if (dailyLog.length() > 0) dailyLog.append(",");
        dailyLog.append(day).append(":비공금");
    }

    // getter/setter 생략
}