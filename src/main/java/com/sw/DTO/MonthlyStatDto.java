package com.sw.DTO;

import lombok.Data;

@Data
public class MonthlyStatDto {
    private Long srno;
    private String memberName;
    private String gender;
    private String region;
    private int leaderCount;
    private int fundCount;
    private int nonFundCount;
    private String dailyLog; // 예: "1:벙주,3:공금,4:비공금"
}
