package com.cleanmate.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 高德地图地理编码工具
 * 将地址字符串转换为经纬度坐标
 */
@Slf4j
@Component
public class GeocodingUtil {

    @Value("${amap.key}")
    private String amapKey;

    private static final String GEO_URL = "https://restapi.amap.com/v3/geocode/geo";
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    /**
     * 地址 → 经纬度，返回 [longitude, latitude]，失败返回 null
     */
    public BigDecimal[] geocode(String address) {
        try {
            String encoded = URLEncoder.encode(address, StandardCharsets.UTF_8);
            String url = GEO_URL + "?address=" + encoded + "&key=" + amapKey;

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            JsonNode root = mapper.readTree(response.body());

            if (!"1".equals(root.path("status").asText())) {
                log.warn("高德地理编码失败: {}", response.body());
                return null;
            }

            JsonNode geocodes = root.path("geocodes");
            if (geocodes.isEmpty()) {
                log.warn("地址未找到坐标: {}", address);
                return null;
            }

            // 返回格式："longitude,latitude"
            String location = geocodes.get(0).path("location").asText();
            String[] parts = location.split(",");
            return new BigDecimal[]{
                    new BigDecimal(parts[0]),  // longitude
                    new BigDecimal(parts[1])   // latitude
            };
        } catch (Exception e) {
            log.warn("地理编码异常, address={}: {}", address, e.getMessage());
            return null;
        }
    }
}
