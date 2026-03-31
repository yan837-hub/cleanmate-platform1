package com.cleanmate.common;

import com.cleanmate.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.StringJoiner;

/**
 * 全局异常处理器
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** 业务异常 */
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusinessException(BusinessException e) {
        log.warn("业务异常: code={}, msg={}", e.getCode(), e.getMessage());
        return Result.error(e.getCode(), e.getMessage());
    }

    /** 参数校验异常（@RequestBody） */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleValidationException(MethodArgumentNotValidException e) {
        StringJoiner joiner = new StringJoiner("; ");
        for (FieldError fieldError : e.getBindingResult().getFieldErrors()) {
            joiner.add(fieldError.getField() + ": " + fieldError.getDefaultMessage());
        }
        return Result.error(400, joiner.toString());
    }

    /** 参数校验异常（@ModelAttribute） */
    @ExceptionHandler(BindException.class)
    public Result<Void> handleBindException(BindException e) {
        StringJoiner joiner = new StringJoiner("; ");
        for (FieldError fieldError : e.getBindingResult().getFieldErrors()) {
            joiner.add(fieldError.getField() + ": " + fieldError.getDefaultMessage());
        }
        return Result.error(400, joiner.toString());
    }

    /** 认证异常 */
    @ExceptionHandler(AuthenticationException.class)
    public Result<Void> handleAuthenticationException(AuthenticationException e) {
        return Result.unauthorized();
    }

    /** 权限不足 */
    @ExceptionHandler(AccessDeniedException.class)
    public Result<Void> handleAccessDeniedException(AccessDeniedException e) {
        return Result.forbidden();
    }

    /** 兜底异常 */
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error("服务器内部错误，请稍后重试");
    }
}
