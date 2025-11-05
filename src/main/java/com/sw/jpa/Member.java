package com.sw.jpa;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "member_info")
@Data
public class Member {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long srno; //pk

    private String name;
    private String gender;
    private String region;
    private String grade;
    private LocalDate birth;
    private LocalDate joinDate;

    @Column(length = 255)
    private String note;

    @Column(length = 255)
    private String photoPath;

    @Column(nullable = false, updatable = false, insertable = false,
            columnDefinition = "timestamp default current_timestamp")
    private java.sql.Timestamp regDate;
}
