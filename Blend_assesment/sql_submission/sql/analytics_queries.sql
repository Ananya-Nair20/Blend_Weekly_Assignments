-- =====================================================
-- Intelligent Urban Mobility Analytics
-- Analytical SQL Queries
-- Database: SQLite
-- Table: taxi_trips
-- =====================================================

-- 1. Peak Demand Hours
SELECT
    pickup_hour,
    COUNT(*) AS trip_count
FROM taxi_trips
GROUP BY pickup_hour
ORDER BY trip_count DESC;


-- 2. Revenue by Pickup Zone
SELECT
    ROUND(pickup_latitude, 2) AS pickup_lat_zone,
    ROUND(pickup_longitude, 2) AS pickup_lon_zone,
    SUM(total_amount) AS total_revenue
FROM taxi_trips
GROUP BY pickup_lat_zone, pickup_lon_zone
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Top 10 Highest-Revenue Days
SELECT
    DATE(tpep_pickup_datetime) AS trip_date,
    SUM(total_amount) AS daily_revenue
FROM taxi_trips
GROUP BY trip_date
ORDER BY daily_revenue DESC
LIMIT 10;


-- 4. Average Fare by Weekday
SELECT
    pickup_day_of_week,
    AVG(fare_amount) AS avg_fare
FROM taxi_trips
GROUP BY pickup_day_of_week
ORDER BY pickup_day_of_week;


-- 5. Monthly Revenue Growth (Window Function)
SELECT
    pickup_month,
    SUM(total_amount) AS monthly_revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY pickup_month) AS previous_month_revenue,
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY pickup_month)) * 100.0
        / LAG(SUM(total_amount)) OVER (ORDER BY pickup_month),
        2
    ) AS revenue_growth_percentage
FROM taxi_trips
GROUP BY pickup_month
ORDER BY pickup_month;
