package com.sw.controller;

import com.sw.DTO.MemberDto;
import com.sw.jpa.Member;
import com.sw.service.MemberService;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.time.LocalDate;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/member")
public class MemberController {

    private final MemberService memberService;
    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @GetMapping("/list")
    public ResponseEntity<?> getMemberList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Map<String, Object> paged = memberService.findPagedMembers(page, size);

        List<Member> members = (List<Member>) paged.get("content");
        List<MemberDto> dtoList = members.stream().map(MemberDto::from).collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("content", dtoList);
        result.put("totalPages", paged.get("totalPages"));
        result.put("totalElements", paged.get("totalElements"));
        result.put("currentPage", paged.get("currentPage"));

        return ResponseEntity.ok(result);
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveMember(
            @RequestParam(value = "srno", required = false) Long srno,
            @RequestParam("name") String name,
            @RequestParam("gender") String gender,
            @RequestParam("region") String region,
            @RequestParam("grade") String grade,
            @RequestParam("birth") String birth,
            @RequestParam("join_date") String joinDate,
            @RequestParam("note") String note,
            @RequestParam(value = "photo", required = false) MultipartFile photo
    ) {
        try {
            Member member = (srno != null)
                    ? memberService.findById(srno) // 기존 회원 조회
                    : new Member();

            member.setName(name);
            member.setGender(gender);
            member.setRegion(region);
            member.setGrade(grade);
            member.setBirth(LocalDate.parse(birth));
            member.setJoinDate(LocalDate.parse(joinDate));
            member.setNote(note);

            member = memberService.saveMember(member);
            Long newSrno = member.getSrno();

            // 사진 업로드 처리
            if (photo != null && !photo.isEmpty()) {
                String fileName = photo.getOriginalFilename();
                memberService.savePhoto(newSrno, fileName, photo.getBytes());

                String savePath = "C:\\user_account\\" + newSrno + "\\" + fileName;
                memberService.updatePhotoPath(newSrno, savePath);
            }

            return ResponseEntity.ok("회원정보가 저장되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("회원 저장 중 오류: " + e.getMessage());
        }
    }

    @GetMapping("/photo")
    public ResponseEntity<Resource> getPhoto(@RequestParam("path") String encodedPath) throws IOException {
        String path = new String(Base64.getDecoder().decode(encodedPath), StandardCharsets.UTF_8);
        File file = new File(path);
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }
        Resource resource = new FileSystemResource(file);
        String contentType = Files.probeContentType(file.toPath());
        if (contentType == null) contentType = "image/jpeg";
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(contentType)).body(resource);
    }
}
