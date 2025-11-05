package com.sw.jpa;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "schedule_info")
public class Schedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long srno;

    @Column(name = "schedule_date", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date scheduleDate;

    @Column(length = 50, nullable = false)
    private String leader;

    @Column(name = "fund_members", length = 255)
    private String fundMembers;

    @Column(name = "nonfund_members", length = 255)
    private String nonFundMembers;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Date createdAt;

    // Getter/Setter
    public Long getSrno() { return srno; }
    public void setSrno(Long srno) { this.srno = srno; }

    public Date getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(Date scheduleDate) { this.scheduleDate = scheduleDate; }

    public String getLeader() { return leader; }
    public void setLeader(String leader) { this.leader = leader; }

    public String getFundMembers() { return fundMembers; }
    public void setFundMembers(String fundMembers) { this.fundMembers = fundMembers; }

    public String getNonFundMembers() { return nonFundMembers; }
    public void setNonFundMembers(String nonFundMembers) { this.nonFundMembers = nonFundMembers; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
