
-----------------------------------------------create database --------------------------

create database fast_f1

use fast_f1

-------------------------------------------------------------------------------------
---------------------------Step 1: Create Staging Table--------


-- Staging table for laps data (all columns as VARCHAR / NVARCHAR to avoid errors)

CREATE TABLE laps_staging (
    [Time] NVARCHAR(100),
    [Driver] NVARCHAR(10),
    [DriverNumber] NVARCHAR(10),
    [LapTime] NVARCHAR(100),
    [LapNumber] NVARCHAR(10),
    [Stint] NVARCHAR(10),
    [PitOutTime] NVARCHAR(100),
    [PitInTime] NVARCHAR(100),
    [Sector1Time] NVARCHAR(100),
    [Sector2Time] NVARCHAR(100),
    [Sector3Time] NVARCHAR(100),
    [Sector1SessionTime] NVARCHAR(100),
    [Sector2SessionTime] NVARCHAR(100),
    [Sector3SessionTime] NVARCHAR(100),
    [SpeedI1] NVARCHAR(50),
    [SpeedI2] NVARCHAR(50),
    [SpeedFL] NVARCHAR(50),
    [SpeedST] NVARCHAR(50),
    [IsPersonalBest] NVARCHAR(10),
    [Compound] NVARCHAR(50),
    [TyreLife] NVARCHAR(10),
    [FreshTyre] NVARCHAR(10),
    [Team] NVARCHAR(100),
    [LapStartTime] NVARCHAR(100),
    [LapStartDate] NVARCHAR(100),
    [TrackStatus] NVARCHAR(10),
    [Position] NVARCHAR(10),
    [Deleted] NVARCHAR(10),
    [DeletedReason] NVARCHAR(500),
    [FastF1Generated] NVARCHAR(10),
    [IsAccurate] NVARCHAR(10),
    [race_name] NVARCHAR(50)
);
--------------------------------------------

-- Staging table for telemetry data

CREATE TABLE telemetry_staging (
    [date] NVARCHAR(50),
    [sessiontime] NVARCHAR(100),
    [driverahead] NVARCHAR(50),
    [distancetodriverahead] NVARCHAR(50),
    [time] NVARCHAR(50),
    [rpm] NVARCHAR(50),
    [speed] NVARCHAR(50),
    [ngear] NVARCHAR(50),
    [throttle] NVARCHAR(50),
    [brake] NVARCHAR(50),
    [drs] NVARCHAR(50),
    [source] NVARCHAR(50),
    [distance] NVARCHAR(50),
    [relativedistance] NVARCHAR(50),
    [status] NVARCHAR(50),
    [drivernumber] NVARCHAR(50),
    [driver] NVARCHAR(50),
    [drivername] NVARCHAR(100),
    [race_name] NVARCHAR(50)
);


----------------------------------------------------------------

---------------------------Step 2: Bulk Insert CSV into Staging Tables------------

-- Import laps CSV
BULK INSERT laps_staging
FROM 'D:\Skills Dynamix.Data Engineering\Material\Final_Project\Final_fast1_data\clean_laps.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'  
);

SELECT COUNT(*) FROM laps_staging;

------------------------------------------------------------
-- Import telemetry CSV
BULK INSERT telemetry_staging
FROM 'D:\Skills Dynamix.Data Engineering\Material\Final_Project\Final_fast1_data\clean_telemetry.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

SELECT COUNT(*) FROM telemetry_staging;
---------------------------------------------------------------------------------------

---------------Step 3: Create Final Tables with Clean Column Names--------

-- Final laps table (clean names + correct data types)
CREATE TABLE laps_clean (
    lap_id INT IDENTITY(1,1) PRIMARY KEY,
    session_time_sec FLOAT,               -- from [Time]
    driver_code NVARCHAR(10),              -- from [Driver]
    driver_number INT,                     -- from [DriverNumber]
    lap_time_sec FLOAT,                    -- from [LapTime]
    lap_number INT,                        -- from [LapNumber]
    stint INT,                             -- from [Stint]
    pit_out_time_sec FLOAT,                -- from [PitOutTime]
    pit_in_time_sec FLOAT,                 -- from [PitInTime]
    sector1_time_sec FLOAT,                -- from [Sector1Time]
    sector2_time_sec FLOAT,
    sector3_time_sec FLOAT,
    sector1_session_time_sec FLOAT,        -- from [Sector1SessionTime]
    sector2_session_time_sec FLOAT,
    sector3_session_time_sec FLOAT,
    speed_i1 FLOAT,                        -- from [SpeedI1]
    speed_i2 FLOAT,
    speed_fl FLOAT,
    speed_st FLOAT,
    is_personal_best BIT,                  -- from [IsPersonalBest]
    compound NVARCHAR(20),                 -- from [Compound]
    tyre_life INT,                         -- from [TyreLife]
    fresh_tyre BIT,                        -- from [FreshTyre]
    team NVARCHAR(50),                     -- from [Team]
    lap_start_time_sec FLOAT,              -- from [LapStartTime]
    lap_start_datetime DATETIME2,          -- from [LapStartDate]
    track_status INT,                      -- from [TrackStatus]
    position INT,                          -- from [Position]
    deleted BIT,                           -- from [Deleted]
    deleted_reason NVARCHAR(255),          -- from [DeletedReason]
    fastf1_generated BIT,                  -- from [FastF1Generated]
    is_accurate BIT,                       -- from [IsAccurate]
    session_type NVARCHAR(20)              -- from [race_name]
);
-----------------------------------------------------------------
-- Final telemetry table
CREATE TABLE telemetry_clean (
    telem_id INT IDENTITY(1,1) PRIMARY KEY,
    date_offset_sec FLOAT,                 -- from [date] (MM:SS.ms)
    session_time_sec FLOAT,                -- from [sessiontime]
    driver_ahead INT,                      -- from [driverahead]
    distance_to_driver_ahead FLOAT,        -- from [distancetodriverahead]
    sample_time_sec FLOAT,                 -- from [time] (SS.ms)
    rpm INT,                               -- from [rpm]
    speed_kmh FLOAT,                       -- from [speed]
    gear TINYINT,                          -- from [ngear]
    throttle_pct FLOAT,                    -- from [throttle]
    brake_pct FLOAT,                       -- from [brake]
    drs BIT,                               -- from [drs]
    source_type NVARCHAR(20),              -- from [source]
    distance_m FLOAT,                      -- from [distance]
    relative_distance FLOAT,               -- from [relativedistance]
    status NVARCHAR(20),                   -- from [status]
    driver_number INT,                     -- from [drivernumber]
    driver_code NVARCHAR(10),              -- from [driver]
    driver_full_name NVARCHAR(50),         -- from [drivername]
    session_type NVARCHAR(20)              -- from [race_name]
);


-----------------------------------------------------------------------

--------------Step 4: Insert Data from Staging to Final (with conversion & renaming)--

INSERT INTO laps_clean (
    session_time_sec,
    driver_code,
    driver_number,
    lap_time_sec,
    lap_number,
    stint,
    pit_out_time_sec,
    pit_in_time_sec,
    sector1_time_sec,
    sector2_time_sec,
    sector3_time_sec,
    sector1_session_time_sec,
    sector2_session_time_sec,
    sector3_session_time_sec,
    speed_i1,
    speed_i2,
    speed_fl,
    speed_st,
    is_personal_best,
    compound,
    tyre_life,
    fresh_tyre,
    team,
    lap_start_time_sec,
    lap_start_datetime,
    track_status,
    position,
    deleted,
    deleted_reason,
    fastf1_generated,
    is_accurate,
    session_type
)
SELECT
    -- session_time_sec (from [Time])
    CASE 
        WHEN [Time] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST(REPLACE([Time], '0 days ', '') AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST(REPLACE([Time], '0 days ', '') AS TIME)) / 1000.0)
        ELSE NULL 
    END,
    [Driver],                                 -- driver_code
    TRY_CAST(TRY_CAST([DriverNumber] AS FLOAT) AS INT),  -- driver_number (handle decimal)

    -- lap_time_sec
    CASE 
        WHEN [LapTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([LapTime] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([LapTime] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- lap_number (handle '1.0' -> 1)
    CASE 
        WHEN [LapNumber] LIKE '%.0' THEN TRY_CAST(LEFT([LapNumber], LEN([LapNumber])-2) AS INT)
        ELSE TRY_CAST([LapNumber] AS INT)
    END,

    -- stint (same treatment)
    CASE 
        WHEN [Stint] LIKE '%.0' THEN TRY_CAST(LEFT([Stint], LEN([Stint])-2) AS INT)
        ELSE TRY_CAST([Stint] AS INT)
    END,

    -- pit_out_time_sec
    CASE 
        WHEN [PitOutTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([PitOutTime] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([PitOutTime] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- pit_in_time_sec
    CASE 
        WHEN [PitInTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([PitInTime] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([PitInTime] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector1_time_sec
    CASE 
        WHEN [Sector1Time] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([Sector1Time] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([Sector1Time] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector2_time_sec
    CASE 
        WHEN [Sector2Time] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([Sector2Time] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([Sector2Time] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector3_time_sec
    CASE 
        WHEN [Sector3Time] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST([Sector3Time] AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST([Sector3Time] AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector1_session_time_sec
    CASE 
        WHEN [Sector1SessionTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST(REPLACE([Sector1SessionTime], '0 days ', '') AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST(REPLACE([Sector1SessionTime], '0 days ', '') AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector2_session_time_sec
    CASE 
        WHEN [Sector2SessionTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST(REPLACE([Sector2SessionTime], '0 days ', '') AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST(REPLACE([Sector2SessionTime], '0 days ', '') AS TIME)) / 1000.0)
        ELSE NULL 
    END,

    -- sector3_session_time_sec
    CASE 
        WHEN [Sector3SessionTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST(REPLACE([Sector3SessionTime], '0 days ', '') AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST(REPLACE([Sector3SessionTime], '0 days ', '') AS TIME)) / 1000.0)
        ELSE NULL 
    END,
    TRY_CAST([SpeedI1] AS FLOAT),
    TRY_CAST([SpeedI2] AS FLOAT),
    TRY_CAST([SpeedFL] AS FLOAT),
    TRY_CAST([SpeedST] AS FLOAT),
    CASE WHEN [IsPersonalBest] = 'True' THEN 1 ELSE 0 END,
    [Compound],

    -- tyre_life (handle decimal)
    CASE 
        WHEN [TyreLife] LIKE '%.0' THEN TRY_CAST(LEFT([TyreLife], LEN([TyreLife])-2) AS INT)
        ELSE TRY_CAST([TyreLife] AS INT)
    END,
    CASE WHEN [FreshTyre] = 'True' THEN 1 ELSE 0 END,
    [Team],

    -- lap_start_time_sec
    CASE 
        WHEN [LapStartTime] != '' 
        THEN DATEDIFF(SECOND, '00:00:00', TRY_CAST(REPLACE([LapStartTime], '0 days ', '') AS TIME))
             + (DATEPART(MILLISECOND, TRY_CAST(REPLACE([LapStartTime], '0 days ', '') AS TIME)) / 1000.0)
        ELSE NULL 
    END,
    TRY_CAST([LapStartDate] AS DATETIME2),
    TRY_CAST([TrackStatus] AS INT),

    -- position (handle decimal)
    CASE 
        WHEN [Position] LIKE '%.0' THEN TRY_CAST(LEFT([Position], LEN([Position])-2) AS INT)
        ELSE TRY_CAST([Position] AS INT)
    END,
    CASE WHEN [Deleted] = 'True' THEN 1 ELSE 0 END,
    NULLIF([DeletedReason], ''),
    CASE WHEN [FastF1Generated] = 'True' THEN 1 ELSE 0 END,
    CASE WHEN [IsAccurate] = 'True' THEN 1 ELSE 0 END,
    [race_name]
FROM laps_staging;


SELECT COUNT(*) FROM laps_clean;
-----------------------------------------------------------

INSERT INTO telemetry_clean (
    date_offset_sec,
    session_time_sec,
    driver_ahead,
    distance_to_driver_ahead,
    sample_time_sec,
    rpm,
    speed_kmh,
    gear,
    throttle_pct,
    brake_pct,
    drs,
    source_type,
    distance_m,
    relative_distance,
    status,
    driver_number,
    driver_code,
    driver_full_name,
    session_type
)
SELECT
    -- date column: '00:13.4' (MM:SS.ms) -> seconds
    CASE 
        WHEN [date] IS NOT NULL AND [date] != '' 
        THEN (CAST(LEFT([date], CHARINDEX(':', [date])-1) AS INT) * 60) 
             + CAST(RIGHT([date], LEN([date]) - CHARINDEX(':', [date])) AS FLOAT)
        ELSE NULL 
    END,
    
    -- sessiontime: '0 days HH:MM:SS.ms' -> total seconds (as FLOAT)
    CASE 
        WHEN [sessiontime] IS NOT NULL AND [sessiontime] != '' 
        THEN 
            -- Extract the time part after '0 days '
            DATEDIFF(SECOND, '00:00:00', 
                TRY_CAST(REPLACE([sessiontime], '0 days ', '') AS TIME)
            )
            -- Add milliseconds as fraction (if needed)
            + (DATEPART(MILLISECOND, 
                TRY_CAST(REPLACE([sessiontime], '0 days ', '') AS TIME)
               ) / 1000.0)
        ELSE NULL 
    END,
    
    TRY_CAST([driverahead] AS INT),
    TRY_CAST([distancetodriverahead] AS FLOAT),
    
    -- time column: '00:00.8' (SS.ms) -> seconds
    CASE 
        WHEN [time] IS NOT NULL AND [time] != '' 
        THEN 
            CASE 
                WHEN CHARINDEX(':', [time]) > 0 
                THEN (CAST(LEFT([time], CHARINDEX(':', [time])-1) AS INT) * 60) 
                     + CAST(RIGHT([time], LEN([time]) - CHARINDEX(':', [time])) AS FLOAT)
                ELSE TRY_CAST([time] AS FLOAT)
            END
        ELSE NULL 
    END,
    
    TRY_CAST(ROUND(TRY_CAST([rpm] AS FLOAT), 0) AS INT),
    TRY_CAST([speed] AS FLOAT),
    TRY_CAST([ngear] AS TINYINT),
    TRY_CAST([throttle] AS FLOAT),
    TRY_CAST([brake] AS FLOAT),
    CASE WHEN [drs] = '1' THEN 1 ELSE 0 END,
    [source],
    TRY_CAST([distance] AS FLOAT),
    TRY_CAST([relativedistance] AS FLOAT),
    [status],
    TRY_CAST([drivernumber] AS INT),
    [driver],
    [drivername],
    [race_name]
FROM telemetry_staging;

SELECT COUNT(*) FROM telemetry_clean;
---------------------------------------------------------------------------

----Step 5: Verify and Drop Staging Tables (Optional)--

-- Check row counts
SELECT COUNT(*) FROM laps_clean;
SELECT COUNT(*) FROM laps_staging;  -- should match

------------------------------------------------------------------

SELECT COUNT(*) FROM telemetry_clean;
SELECT COUNT(*) FROM telemetry_staging;  -- should match

------------------------------------------------------------------
-- Drop staging if everything is correct

#DROP TABLE laps_staging;
#DROP TABLE telemetry_staging;

--------------------------------------------



---------------------------------------------------------------------------------------

select*from laps_clean
select*from telemetry_clean

-------------------------------------------
use fast_f1
-----------------------------------------------------------

------------------Step 6 : Add the lap_number column to telemetry_clean------

ALTER TABLE telemetry_clean ADD lap_number INT NULL;


CREATE INDEX idx_tele_join ON telemetry_clean (driver_code, session_type, session_time_sec);

CREATE INDEX idx_laps_join ON laps_clean (driver_code, session_type, lap_start_time_sec, lap_time_sec) INCLUDE (lap_number);



UPDATE t
SET t.lap_number = l.lap_number
FROM telemetry_clean t
INNER JOIN laps_clean l 
    ON l.driver_code = t.driver_code
    AND l.session_type = t.session_type
    AND t.session_time_sec BETWEEN l.lap_start_time_sec 
                               AND l.lap_start_time_sec + l.lap_time_sec;


SELECT TOP 10 driver_code, session_type, session_time_sec, lap_number 
FROM telemetry_clean 
WHERE lap_number IS NOT NULL;


-------------------------------------------------------------------

-----------Step 7: Create Dimensional Tables from laps_clean and populate them from laps_clean --------------------



select*from laps_clean
select*from telemetry_clean


-----7a : dim_driver (from fact laps_clean and fact telemetry_clean)– Driver & Team information

CREATE TABLE dim_driver (
    driver_key INT IDENTITY PRIMARY KEY,
    driver_code NVARCHAR(10),
    driver_number INT,
    driver_full_name NVARCHAR(50),
    team NVARCHAR(50)
);

----Populate dim_driver from laps_clean

INSERT INTO dim_driver (driver_code, driver_number, driver_full_name, team)
SELECT DISTINCT 
    COALESCE(l.driver_code, t.driver_code) AS driver_code,
    COALESCE(l.driver_number, t.driver_number) AS driver_number,
    t.driver_full_name,
    l.team
FROM laps_clean l
FULL OUTER JOIN telemetry_clean t ON l.driver_code = t.driver_code;

select * from dim_track
-------------------------------------------------------------------

----7b : dim_session (from fact laps_clean)– Time & Session Identification

CREATE TABLE dim_session (
    session_key INT IDENTITY PRIMARY KEY,
    session_type NVARCHAR(20),      -- FP1, Race, etc.
    session_date DATE,               -- derived from lap_start_datetime
    track_status INT                -- if needed
);

----Populate dim_session from laps_clean-----

INSERT INTO dim_session (session_type, session_date, track_status)
SELECT DISTINCT 
    session_type,
    CAST(lap_start_datetime AS DATE),
    track_status
FROM laps_clean
WHERE lap_start_datetime IS NOT NULL;

-------------------------------------------------------------------------

----7c : dim_tyre_stint (from fact laps_clean)– Tyre & Stint

CREATE TABLE dim_tyre_stint (
    stint_key INT IDENTITY PRIMARY KEY,
    stint_number INT,
    compound NVARCHAR(20),
    tyre_life_at_start INT,
    fresh_tyre BIT
);

------Populate dim_tyre_stint from laps_clean

INSERT INTO dim_tyre_stint (stint_number, compound, tyre_life_at_start, fresh_tyre)
SELECT DISTINCT 
    stint,
    compound,
    tyre_life,
    fresh_tyre
FROM laps_clean
WHERE stint IS NOT NULL;

------------------------------------------------

----7d: dim_pit (from fact laps_clean)– Pit Stop Info (only for laps that had a pit)

CREATE TABLE dim_pit (
    pit_key INT IDENTITY PRIMARY KEY,
    pit_in_time_sec FLOAT,
    pit_out_time_sec FLOAT
);


----Populate dim_pit from laps_clean--

INSERT INTO dim_pit (pit_in_time_sec, pit_out_time_sec)
SELECT DISTINCT 
    pit_in_time_sec,
    pit_out_time_sec
FROM laps_clean
WHERE pit_in_time_sec IS NOT NULL OR pit_out_time_sec IS NOT NULL;

-------------------------------------------------------

----7e : dim_track (from fact laps_clean)– Track & Position flags--

CREATE TABLE dim_track (
    track_key INT IDENTITY(1,1) PRIMARY KEY,
    track_status INT,
    position INT,
    deleted BIT,
    deleted_reason NVARCHAR(255)
);

----Populate dim_track from laps_clean--

INSERT INTO dim_track (track_status, position, deleted, deleted_reason)
SELECT DISTINCT 
    track_status,
    position,
    deleted,
    deleted_reason
FROM laps_clean;

-------------------------------------------------------------------------------

-----7f : dim_data_quality (from fact laps_clean)– Data Quality Flags

CREATE TABLE dim_data_quality (
    quality_key INT IDENTITY PRIMARY KEY,
    is_accurate BIT,
    fastf1_generated BIT
);

----Populate dim_data_quality from laps_clean--

INSERT INTO dim_data_quality (is_accurate, fastf1_generated)
SELECT DISTINCT 
    is_accurate,
    fastf1_generated
FROM laps_clean;

---------------------------------------------------------------------

---------------Step 8 : Add foreign key columns to laps_clean and Link laps_clean to dimensions

ALTER TABLE laps_clean ADD driver_key INT;

ALTER TABLE laps_clean ADD session_key INT;

ALTER TABLE laps_clean ADD stint_key INT;

ALTER TABLE laps_clean ADD pit_key INT;

ALTER TABLE laps_clean ADD track_key INT;

ALTER TABLE laps_clean ADD quality_key INT;


-------------------------------------------------------------------------------------------

-----------------------Step 9 : Populate the Dimention Tables--------------------

-----9a : Populate driver_key and session_key in laps_clean and link to dimention table


UPDATE l
SET l.driver_key = d.driver_key
FROM laps_clean l
INNER JOIN dim_driver d ON l.driver_code = d.driver_code;

UPDATE l
SET l.session_key = s.session_key
FROM laps_clean l
INNER JOIN dim_session s 
    ON l.session_type = s.session_type
    AND CAST(l.lap_start_datetime AS DATE) = s.session_date;
--------------------------------------------------------

-----9b : Populate dim_tyre_stint in laps_clean and link to laps_clean---------

UPDATE l
SET l.stint_key = ts.stint_key
FROM laps_clean l
INNER JOIN dim_tyre_stint ts 
    ON l.stint = ts.stint_number
    AND l.compound = ts.compound
    AND l.tyre_life = ts.tyre_life_at_start
    AND l.fresh_tyre = ts.fresh_tyre;

--------------------------------------------------------------------------

-----9c : Populate dim_pit in laps_clean and link to laps_clean

UPDATE l
SET l.pit_key = p.pit_key
FROM laps_clean l
INNER JOIN dim_pit p 
    ON ISNULL(l.pit_in_time_sec, 0) = ISNULL(p.pit_in_time_sec, 0)
    AND ISNULL(l.pit_out_time_sec, 0) = ISNULL(p.pit_out_time_sec, 0)
WHERE l.pit_in_time_sec IS NOT NULL OR l.pit_out_time_sec IS NOT NULL;

-------------------------------------------------------------------------------

-----9d : Populate dim_track in laps_clean and link to laps_clean

UPDATE l
SET l.track_key = t.track_key
FROM laps_clean l
INNER JOIN dim_track t 
    ON ISNULL(l.track_status, 0) = ISNULL(t.track_status, 0)
    AND ISNULL(l.position, 0) = ISNULL(t.position, 0)
    AND l.deleted = t.deleted
    AND ISNULL(l.deleted_reason, '') = ISNULL(t.deleted_reason, '');
-------------------------------------------------------------------------

-----9e : Populate dim_data_quality in laps_clean and link to laps_clean

UPDATE l
SET l.quality_key = q.quality_key
FROM laps_clean l
INNER JOIN dim_data_quality q 
    ON l.is_accurate = q.is_accurate
    AND l.fastf1_generated = q.fastf1_generated;

---------------------------------------------------------------------------------------------------------------

-------------------------Step 10 : Add foreign key constraints for laps_clean

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_driver FOREIGN KEY (driver_key) REFERENCES dim_driver(driver_key);

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_session FOREIGN KEY (session_key) REFERENCES dim_session(session_key);

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_stint FOREIGN KEY (stint_key) REFERENCES dim_tyre_stint(stint_key);

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_pit FOREIGN KEY (pit_key) REFERENCES dim_pit(pit_key);

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_track FOREIGN KEY (track_key) REFERENCES dim_track(track_key);

ALTER TABLE laps_clean ADD CONSTRAINT FK_laps_quality FOREIGN KEY (quality_key) REFERENCES dim_data_quality(quality_key);

---------------------------------------------------------------------------------------------------------------------------

----------Step 11 :Add foreign key columns to telemetry_clean and Link telemetry_clean to dimensions

ALTER TABLE telemetry_clean ADD driver_key INT;

ALTER TABLE telemetry_clean ADD session_key INT;

ALTER TABLE telemetry_clean ADD stint_key INT;

ALTER TABLE telemetry_clean ADD pit_key INT;

ALTER TABLE telemetry_clean ADD track_key INT;

ALTER TABLE telemetry_clean ADD quality_key INT;

select * from telemetry_clean

---------------------------Step 12 : Populate the foreign keys in telemetry_clean columns------------------- 

-----12 a : Populate driver_key and session_key in telemetry_clean using lap_key

UPDATE t
SET t.driver_key = l.driver_key,
    t.session_key = l.session_key
FROM telemetry_clean t
INNER JOIN laps_clean l 
ON t.lap_key = l.lap_id;

-----12 b : Populate stint_key , pit_key , track_key , quality_key in telemetry_clean using lap_key---

UPDATE t
SET 
    t.stint_key = l.stint_key,
    t.pit_key = l.pit_key,
    t.track_key = l.track_key,
    t.quality_key = l.quality_key
FROM telemetry_clean t
INNER JOIN laps_clean l ON t.lap_key = l.lap_id;
-------------------------------------------------------------------------------------------

--------------------Step 13 : Add foreign key constraints for telemetry_clean

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_driver FOREIGN KEY (driver_key) REFERENCES dim_driver(driver_key);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_session FOREIGN KEY (session_key) REFERENCES dim_session(session_key);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_lap FOREIGN KEY (lap_key) REFERENCES laps_clean(lap_id);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_stint FOREIGN KEY (stint_key) REFERENCES dim_tyre_stint(stint_key);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_pit FOREIGN KEY (pit_key) REFERENCES dim_pit(pit_key);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_track FOREIGN KEY (track_key) REFERENCES dim_track(track_key);

ALTER TABLE telemetry_clean ADD CONSTRAINT FK_tele_quality FOREIGN KEY (quality_key) REFERENCES dim_data_quality(quality_key);

-----------------------------------------------------------------------------------------------------------

-- Check laps_clean keys are fully populated
SELECT 
    COUNT(*) AS total_laps,
    COUNT(driver_key) AS has_driver,
    COUNT(session_key) AS has_session,
    COUNT(stint_key) AS has_stint,
    COUNT(pit_key) AS has_pit,
    COUNT(track_key) AS has_track,
    COUNT(quality_key) AS has_quality
FROM laps_clean;

-- Check telemetry_clean keys
SELECT 
    COUNT(*) AS total_tele,
    COUNT(driver_key) AS has_driver,
    COUNT(session_key) AS has_session,
    COUNT(lap_key) AS has_lap
FROM telemetry_clean;



SELECT * FROM dim_track;
















SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'telemetry_clean' AND COLUMN_NAME = 'driver_key';

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'telemetry_clean' AND COLUMN_NAME = 'session_key';



SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'telemetry_clean' AND COLUMN_NAME = 'session_key';






