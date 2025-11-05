package com.sw.jpa;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDate;

@Entity
@Data
@Table(name = "tbl_fund")
public class Fund {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long srno;

    @Column(name = "fund_date", nullable = false)
    private LocalDate fundDate;

    @Column(name = "withdraw_amount", nullable = false)
    private Integer withdrawAmount = 0;

    @Column(name = "deposit_amount", nullable = false)
    private Integer depositAmount = 0;

    @Column(name = "balance_amount", nullable = false)
    private Integer balanceAmount = 0;
}
