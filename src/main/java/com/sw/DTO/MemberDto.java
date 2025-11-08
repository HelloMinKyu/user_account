package com.sw.DTO;

import com.sw.jpa.Member;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberDto {

    private Long srno;
    private String name;
    private String gender;
    private String region;
    private String grade;
    private String birth;
    private String joinDate;
    private String note;
    private String photoPath; //
    private String photoPath2; //
    private String photoPath3; //

    public static MemberDto from(Member m) {
        MemberDto dto = new MemberDto();
        dto.setSrno(m.getSrno());
        dto.setName(m.getName());
        dto.setGender(m.getGender());
        dto.setRegion(m.getRegion());
        dto.setGrade(m.getGrade());
        dto.setBirth(m.getBirth() != null ? m.getBirth().toString() : "");
        dto.setJoinDate(m.getJoinDate() != null ? m.getJoinDate().toString() : "");
        dto.setNote(m.getNote());
        dto.setPhotoPath(m.getPhotoPath());
        dto.setPhotoPath2(m.getPhotoPath2());
        dto.setPhotoPath3(m.getPhotoPath3());
        return dto;
    }
}
