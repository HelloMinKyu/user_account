package com.sw.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

    @GetMapping("/")
    public String index() {
        return "main";
    }

    @RequestMapping(value = "/header")
    public String header()  {
        return "template/header";
    }

    @RequestMapping(value = "/head")
    public String head()  {
        return "template/head";
    }

    @GetMapping("/user")
    public String user() {
        return "user";
    }

    @GetMapping("/schedule/add")
    public String schedule_add() {
        return "schedule_add";
    }

    @GetMapping("/schedule")
    public String schedule_status() {
        return "schedule_status";
    }

    @GetMapping("/fund")
    public String fund() {
        return "fund";
    }

    @GetMapping("/monthlystats")
    public String monthlystats() {
        return "monthlystats";
    }
}
