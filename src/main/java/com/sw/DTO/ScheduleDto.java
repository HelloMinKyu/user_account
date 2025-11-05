package com.sw.DTO;

import java.util.Date;

public class ScheduleDto {
    private Long srno;
    private String date;
    private String leader;
    private Date scheduleDate;
    private String fundMembers;
    private String nonFundMembers;

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getLeader() { return leader; }
    public void setLeader(String leader) { this.leader = leader; }

    public String getFundMembers() { return fundMembers; }
    public void setFundMembers(String fundMembers) { this.fundMembers = fundMembers; }

    public String getNonFundMembers() { return nonFundMembers; }
    public void setNonFundMembers(String nonFundMembers) { this.nonFundMembers = nonFundMembers; }

    public Date getScheduleDate() { return scheduleDate; }

    public void setScheduleDate(Date scheduleDate) { this.scheduleDate = scheduleDate; }

    public Long getSrno() { return srno; }

    public void setSrno(Long srno) { this.srno = srno; }
}
