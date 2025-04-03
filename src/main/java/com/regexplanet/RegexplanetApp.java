package com.regexplanet;

import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@ServletComponentScan
@SpringBootApplication
public class RegexplanetApp {

	@RequestMapping("/")
	String home(jakarta.servlet.http.HttpServletResponse resp) {
		resp.setContentType("text/plain");
		resp.setCharacterEncoding("UTF-8");
		return "Running Java " + System.getProperty("java.version");
	}

	public static void main(String[] args) {
		SpringApplication application = new SpringApplication(RegexplanetApp.class);
		application.setBannerMode(Banner.Mode.OFF);
		application.run(args);
	}


}
