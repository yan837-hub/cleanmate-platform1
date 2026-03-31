package com.cleanmate.common;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 分页响应体
 */
@Data
public class PageResult<T> implements Serializable {

    /** 当前页数据 */
    private List<T> records;
    /** 总记录数 */
    private Long total;
    /** 当前页码 */
    private Long current;
    /** 每页大小 */
    private Long size;
    /** 总页数 */
    private Long pages;

    public static <T> PageResult<T> of(Page<T> page) {
        PageResult<T> result = new PageResult<>();
        result.records = page.getRecords();
        result.total = page.getTotal();
        result.current = page.getCurrent();
        result.size = page.getSize();
        result.pages = page.getPages();
        return result;
    }

    public static <T> PageResult<T> of(List<T> records, Long total, Long current, Long size) {
        PageResult<T> result = new PageResult<>();
        result.records = records;
        result.total = total;
        result.current = current;
        result.size = size;
        result.pages = size > 0 ? (long) Math.ceil((double) total / size) : 0L;
        return result;
    }
}
