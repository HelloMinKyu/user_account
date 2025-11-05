package com.sw.jpa;

import lombok.Data;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Data
@Entity
@Table(name = "admin")
public class Admin {
    @Id
    private String id;
    private String pwd;
}
