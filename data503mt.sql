-- Active: 1705727786418@@127.0.0.1@5432@analysis

-- Create a schema for the midterm since we'll be using multiple tables (don't forget to switch to that schema or your table won't create properly)
DROP SCHEMA IF EXISTS DATA_503_MT;

CREATE SCHEMA DATA_503_MT;

-- OBJECTIVE: Create a table with appropriate column types and constraints.
-- We need a table for all three of our tables: June On Time Reporting, Airport IDs, and Unique Carriers
DROP TABLE IF EXISTS june_flights;

CREATE TABLE june_flights (
    DAY_OF_WEEK INT,
    FL_DATE TIMESTAMP,
    OP_UNIQUE_CARRIER VARCHAR,
    OP_CARRIER_FL_NUM INT,
    ORIGIN_AIRPORT_ID INT,
    ORIGIN_AIRPORT_SEQ_ID INT,
    ORIGIN_CITY_MARKET_ID INT,
    DEST_AIRPORT_ID INT,
    DEST_AIRPORT_SEQ_ID INT,
    DEST_CITY_MARKET_ID INT,
    CRS_DEP_TIME INT,
    DEP_TIME INT,
    CRS_ARR_TIME INT,
    ARR_TIME INT,
    CANCELLED FLOAT,
    DIVERTED FLOAT,
    CRS_ELAPSED_TIME FLOAT,
    ACTUAL_ELAPSED_TIME FLOAT,
    DISTANCE FLOAT,
    CARRIER_DELAY FLOAT,
    WEATHER_DELAY FLOAT,
    NAS_DELAY FLOAT,
    SECURITY_DELAY FLOAT,
    LATE_AIRCRAFT_DELAY FLOAT
);

DROP TABLE IF EXISTS airport_id;

CREATE TABLE airport_id(
    code INT,
    description TEXT
);

DROP TABLE IF EXISTS carriers;

CREATE TABLE carriers(
    code TEXT,
    description TEXT
);

-- OBJECTIVE: Populate a table by reading in data from a CSV file format.
COPY june_flights(DAY_OF_WEEK,FL_DATE,OP_UNIQUE_CARRIER,OP_CARRIER_FL_NUM,ORIGIN_AIRPORT_ID,ORIGIN_AIRPORT_SEQ_ID,ORIGIN_CITY_MARKET_ID,DEST_AIRPORT_ID,DEST_AIRPORT_SEQ_ID,DEST_CITY_MARKET_ID,CRS_DEP_TIME,DEP_TIME,CRS_ARR_TIME,ARR_TIME,CANCELLED,DIVERTED,CRS_ELAPSED_TIME,ACTUAL_ELAPSED_TIME,DISTANCE,CARRIER_DELAY,WEATHER_DELAY,NAS_DELAY,SECURITY_DELAY,LATE_AIRCRAFT_DELAY)
FROM '/Users/tyanez/Desktop/DATA 503/Midterm Project/JUN_ONTIME_REPORT.csv'
DELIMITER ','
CSV HEADER;

COPY airport_id(code,description)
FROM '/Users/tyanez/Desktop/DATA 503/Midterm Project/AIRPORT_ID.csv'
DELIMITER ','
CSV HEADER;

COPY carriers(code,description)
FROM '/Users/tyanez/Desktop/DATA 503/Midterm Project/UNIQUE_CARRIERS.csv'
DELIMITER ','
CSV HEADER;

-- OBJECTIVE: Query a table to select a subset of rows and columns in a particular order.
-- Quick test to see if our table works: Which destination had the longest flights?
SELECT dest_airport_id as airport, distance
FROM june_flights
ORDER BY distance DESC;

-- OBJECTIVE: Use any JOIN statement to combine information from two or more tables.
-- Which airlines have the most cancelled flights
SELECT carriers.description as airlines, count(*) as cancellations
FROM june_flights
RIGHT JOIN carriers ON op_unique_carrier = carriers.code
WHERE cancelled = 1
GROUP BY op_unique_carrier, carriers.description
ORDER BY count(*) DESC;

-- OBJECTIVE: Showcase both column calculations and aggregate calculations.
-- Which airlines have the most hours over estimated flight times? (column calc)
SELECT 
    carriers.description as airlines,
    sum(crs_elapsed_time)/60 as estimated_flight_hours,
    sum(actual_elapsed_time - crs_elapsed_time)/60 as hours_over,
    count(*) as flights
FROM june_flights
RIGHT JOIN carriers ON op_unique_carrier = carriers.code
WHERE actual_elapsed_time > crs_elapsed_time
GROUP BY carriers.description
ORDER BY sum(actual_elapsed_time - crs_elapsed_time) DESC;

-- Which airport has the most delays caused by weather? How long is the average delay? (agg calc)
SELECT 
    airport_id.description as airport,
    avg(weather_delay) as mins_delayed,
    count(weather_delay) as flights_delayed
FROM june_flights
RIGHT JOIN airport_id ON origin_airport_id = airport_id.code
WHERE weather_delay > 0
GROUP BY origin_airport_id, airport_id.description
ORDER BY count(weather_delay) DESC;