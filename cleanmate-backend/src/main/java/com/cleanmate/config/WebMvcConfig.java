package com.cleanmate.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/**
 * 静态资源映射：/files/** -> 本地 uploads 目录
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${upload.path}")
    private String uploadPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absPath = Paths.get(uploadPath).toAbsolutePath().normalize().toString();
        if (!absPath.endsWith("/") && !absPath.endsWith("\\")) {
            absPath += "/";
        }
        registry.addResourceHandler("/files/**").addResourceLocations("file:" + absPath);
    }
}
