package com.cleanmate;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisReactiveAutoConfiguration;
import org.springframework.scheduling.annotation.EnableScheduling;

// 暂时排除 Redis 自动配置，如需使用 Redis 再删除 exclude
@SpringBootApplication(exclude = {
        RedisAutoConfiguration.class,
        RedisReactiveAutoConfiguration.class
})
@MapperScan("com.cleanmate.mapper")
@EnableScheduling
public class CleanmateApplication {

    public static void main(String[] args) {
        SpringApplication.run(CleanmateApplication.class, args);
    }
}
