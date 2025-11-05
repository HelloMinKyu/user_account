package com.sw.repository;

import com.sw.jpa.Admin;
import org.springframework.data.repository.CrudRepository;

public interface AdminRepository extends CrudRepository<Admin, Long> {
    Admin findByIdAndPwd(String id, String pwd);
}
