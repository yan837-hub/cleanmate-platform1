package com.cleanmate.config;

import com.cleanmate.entity.ServiceType;
import com.cleanmate.entity.User;
import com.cleanmate.service.IServiceTypeService;
import com.cleanmate.service.IUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * 开发环境测试数据初始化
 * 启动时检查，若不存在则自动创建
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

    private final IUserService userService;
    private final IServiceTypeService serviceTypeService;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(ApplicationArguments args) {
        initUser("13800000001", "测试顾客",    1);
        initUser("13800000002", "测试保洁员",  2);
        initUser("13800000004", "测试保洁员2", 2);
        initUser("13800000003", "平台管理员",  3);
        initServiceTypes();
    }

    private void initUser(String phone, String nickname, Integer role) {
        boolean exists = userService.lambdaQuery().eq(User::getPhone, phone).exists();
        if (!exists) {
            User user = new User();
            user.setPhone(phone);
            user.setPassword(passwordEncoder.encode("123456"));
            user.setNickname(nickname);
            user.setRole(role);
            user.setStatus(1);
            userService.save(user);
            log.info("初始化测试账号：{} ({})", phone, nickname);
        }
    }

    private void initServiceTypes() {
        if (serviceTypeService.count() > 0) return;

        Object[][] types = {
            {"日常保洁", "定期家居清洁，保持居家环境整洁", 1, "35.00", 120, 1, 4},
            {"深度清洁", "全屋深度清洁，清除顽固污渍", 1, "55.00", 240, 2, 3},
            {"开荒保洁", "新房/装修后全面清洁",         2, "8.00",  null, 2, 2},
            {"油烟机清洗", "专业油烟机拆洗，彻底去除油污",  3, "199.00", null, 1, 1},
        };

        for (Object[] t : types) {
            ServiceType st = new ServiceType();
            st.setName((String) t[0]);
            st.setDescription((String) t[1]);
            st.setPriceMode((Integer) t[2]);
            st.setBasePrice(new BigDecimal((String) t[3]));
            st.setMinDuration((Integer) t[4]);
            st.setSuggestWorkers((Integer) t[5]);
            st.setSortOrder((Integer) t[6]);
            st.setStatus(1);
            serviceTypeService.save(st);
        }
        log.info("初始化服务类型：{}条", types.length);
    }
}
