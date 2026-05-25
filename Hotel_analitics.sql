use role sysadmin;

create warehouse if not exists hotel_wh;

create database if not exists hotel_db;
create schema if not exists hotel_schema;

create or replace file format FF_CSV
    type = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL','null','');

create or replace stage STG_HOTELBOOKINGS   
    file_format = FF_CSV;
    
create table if not exists BRONZE_HOTEL_BOOKING(
    booking_id STRING,
    hotel_id STRING,
    hotel_city STRING,
    customer_id STRING,
    customer_name STRING,
    customer_email STRING,
    check_in_date STRING,
    check_out_date STRING,
    room_type STRING,
    num_guests STRING,
    total_amount STRING,
    currency STRING,
    booking_status STRING

);

COPY INTO BRONZE_HOTEL_BOOKING
FROM @STG_HOTELBOOKINGS
FILE_FORMAT = (FORMAT_NAME = FF_CSV),
ON_ERROR = 'CONTINUE';

SELECT 
    *
FROM BRONZE_HOTEL_BOOKING LIMIT 100;

create or replace table  SILVER_HOTEL_BOOKING(
    booking_id VARCHAR,
    hotel_id VARCHAR,
    hotel_city VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    customer_email VARCHAR,
    check_in_date DATE,
    check_out_date DATE,
    room_type VARCHAR,
    num_guests INTEGER,
    total_amount FLOAT,
    currency VARCHAR,
    booking_status VARCHAR

);


SELECT customer_email 
FROM BRONZE_HOTEL_BOOKING
WHERE NOT (customer_email LIKE '%@%.%')
OR customer_email IS NULL;

SELECT total_amount
FROM BRONZE_HOTEL_BOOKING
WHERE TRY_TO_NUMBER (total_amount) < 0;

SELECT  check_in_date,
    check_out_date,
FROM BRONZE_HOTEL_BOOKING
WHERE TRY_TO_DATE(check_in_date) > TRY_TO_DATE(check_out_date);

SELECT  DISTINCT booking_status
FROM BRONZE_HOTEL_BOOKING;

INSERT INTO SILVER_HOTEL_BOOKING
    SELECT 
        booking_id ,
        hotel_id ,
        INITCAP(TRIM(hotel_city)) AS hotel_city,
        customer_id ,
        INITCAP(TRIM(customer_name)) AS customer_name,
          CASE
            WHEN customer_email LIKE '%@%.%' 
            THEN LOWER(TRIM(customer_email))
            ELSE NULL
          END
          AS customer_email,
        TRY_TO_DATE(NULLIF(check_in_date,'')) AS check_in_date ,
        TRY_TO_DATE(NULLIF(check_out_date,'')) AS check_out_date  ,
        room_type ,
        num_guests ,
        ABS(TRY_TO_NUMBER(total_amount)) AS total_amount,
        currency ,
        CASE 
        WHEN LOWER(booking_status) IN ('confirmeeed','confirmd')
        THEN 'confirmed'
        ELSE booking_status
        END 
        AS booking_status
FROM BRONZE_HOTEL_BOOKING
WHERE TRY_TO_DATE(check_in_date) IS NOT NULL 
    AND  TRY_TO_DATE(check_out_date) IS NOT NULL 
    AND  TRY_TO_DATE(check_in_date) <= TRY_TO_DATE(check_out_date);


SELECT * FROM SILVER_HOTEL_BOOKING LIMIT 50;

create table  GOLD_AGG_DAILY_BOOKING AS
SELECT
        check_in_date AS date,
        COUNT(*) AS total_booking,
        SUM(total_amount)  AS total_revenue
FROM SILVER_HOTEL_BOOKING
GROUP BY check_in_date
ORDER BY date;

create table  GOLD_AGG_HOTEL_CITY_SALES AS
SELECT
        hotel_city AS hotel,
        SUM(total_amount)  AS total_revenue
FROM SILVER_HOTEL_BOOKING
GROUP BY hotel_city
ORDER BY total_revenue DESC;


create or replace table  GOLD_HOTEL_BOOKING AS 
SELECT
    booking_id ,
    hotel_id ,
    hotel_city ,
    customer_id ,
    customer_name ,
    COALESCE(customer_email,'exemple@exemple.com') AS customer_email ,
    check_in_date ,
    check_out_date ,
    room_type ,
    num_guests ,
    total_amount ,
    currency ,
    booking_status 
FROM SILVER_HOTEL_BOOKING;

drop table if exists GOLD_HOTEL_BOOKING;

INSERT INTO GOLD_HOTEL_BOOKING 
SELECT
    booking_id ,
    hotel_id ,
    hotel_city ,
    customer_id ,
    customer_name ,
    COALESCE(customer_email, 'exemple@exemple.com') AS customer_email, //retira os nulls
    check_in_date ,
    check_out_date ,
    room_type ,
    num_guests ,
    total_amount ,
    currency ,
    booking_status 
FROM SILVER_HOTEL_BOOKING ;

SELECT *
FROM GOLD_HOTEL_BOOKING;

SELECT *
FROM GOLD_AGG_DAILY_BOOKING LIMIT 30;

SELECT *
FROM GOLD_AGG_HOTEL_CITY_SALES LIMIT 30;

SELECT DISTINCT(HOTEL_CITY), HOTEL_ID
FROM GOLD_HOTEL_BOOKING
GROUP BY HOTEL_CITY, HOTEL_ID
ORDER BY HOTEL_ID;