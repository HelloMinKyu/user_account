package com.sw.repository;

import com.sw.jpa.Member;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MemberRepository extends CrudRepository<Member, Long> {
    @Query(value = "SELECT * FROM member_info ORDER BY name asc LIMIT :offset, :size", nativeQuery = true)
    List<Member> findPage(@Param("offset") int offset, @Param("size") int size);

    @Query(value = "SELECT COUNT(*) FROM member_info", nativeQuery = true)
    long countAll();

    List<Member> findAllByOrderByNameAsc();
}
