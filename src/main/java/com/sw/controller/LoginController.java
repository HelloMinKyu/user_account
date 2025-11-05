package com.sw.controller;

import com.sw.jpa.Admin;
import com.sw.repository.AdminRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {
    private final AdminRepository adminRepository;

    public LoginController(AdminRepository adminRepository) {
        this.adminRepository = adminRepository;
    }

    @PostMapping("/login")
    public String login(@RequestParam String id, @RequestParam String pwd, Model model) {
        Admin admin = adminRepository.findByIdAndPwd(id, pwd);
        if (admin != null) {
            return "redirect:/user";
        } else {
            model.addAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "login";
        }
    }
}
