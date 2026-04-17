package com.cleanmate.controller;

import com.cleanmate.common.Result;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * 通用文件上传（评价图片、投诉凭证等）
 * POST /common/upload → 返回可访问的图片 URL
 */
@RestController
@RequestMapping("/common")
@RequiredArgsConstructor
public class CommonUploadController {

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    @PostMapping("/upload")
    public Result<String> upload(@RequestParam("file") MultipartFile file) {
        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
            throw new BusinessException(ErrorCode.FILE_TYPE_NOT_SUPPORT);
        }
        String ext = originalName.substring(originalName.lastIndexOf("."));
        String filename = "img_" + UUID.randomUUID().toString().replace("-", "") + ext;

        Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
        try {
            if (!Files.exists(dir)) Files.createDirectories(dir);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, dir.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR);
        }

        return Result.success(urlPrefix + filename);
    }
}
