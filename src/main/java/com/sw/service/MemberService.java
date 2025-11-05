package com.sw.service;

import com.sw.jpa.Member;
import com.sw.repository.MemberRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Sort;
import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MemberService {
    private final MemberRepository memberRepository;

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    // 저장
    @Transactional
    public Member saveMember(Member member) {
        return memberRepository.save(member);
    }
    
    // 첨부 저장
    @Transactional
    public void savePhoto(Long srno, String fileName, byte[] fileData) throws Exception {
        String baseDir = "C:\\user_account\\" + srno;
        File dir = new File(baseDir);
        if (!dir.exists()) dir.mkdirs();

        File photoFile = new File(dir, fileName);
        java.nio.file.Files.write(photoFile.toPath(), fileData);
    }

    @Transactional
    public void updatePhotoPath(Long srno, String photoPath) {
        Member member = memberRepository.findById(srno).orElse(null);

        if (member != null) {
            member.setPhotoPath(photoPath);
            memberRepository.save(member);
        } else {
            throw new RuntimeException("해당 SRNO의 회원을 찾을 수 없습니다: " + srno);
        }
    }

    @Transactional(readOnly = true)
    public List<Member> findAll() {
        List<Member> list = (List<Member>) memberRepository.findAll();
        list.sort((a, b) -> Long.compare(b.getSrno(), a.getSrno())); // 내림차순 정렬
        return list;
    }

    @Transactional(readOnly = true)
    public Member findById(Long srno) {
        return memberRepository.findById(srno).orElse(null);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> findPagedMembers(int page, int size) {
        int offset = page * size;

        long totalElements = memberRepository.countAll();
        int totalPages = (int) Math.ceil((double) totalElements / size);

        List<Member> content = memberRepository.findPage(offset, size);

        Map<String, Object> result = new HashMap<>();
        result.put("content", content);
        result.put("totalPages", totalPages);
        result.put("totalElements", totalElements);
        result.put("currentPage", page);

        return result;
    }
}
