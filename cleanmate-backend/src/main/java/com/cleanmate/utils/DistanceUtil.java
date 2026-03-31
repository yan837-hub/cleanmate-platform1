package com.cleanmate.utils;

/**
 * 地理距离计算工具（Haversine 公式，单位：km）
 */
public class DistanceUtil {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /**
     * 计算两点之间的直线距离（km）
     *
     * @param lat1 纬度1
     * @param lon1 经度1
     * @param lat2 纬度2
     * @param lon2 经度2
     * @return 距离（km），保留2位小数
     */
    public static double calculateKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distanceKm = EARTH_RADIUS_KM * c;

        return Math.round(distanceKm * 100.0) / 100.0;
    }

    /**
     * 计算两点之间的距离（米）
     */
    public static int calculateMeters(double lat1, double lon1, double lat2, double lon2) {
        return (int) (calculateKm(lat1, lon1, lat2, lon2) * 1000);
    }

    private DistanceUtil() {}
}
