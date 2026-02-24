-- =============================================
-- Database Creation
-- Purpose: Separate static data from high-volume transactional data
-- =============================================

CREATE DATABASE ExaminationSystemDB
ON PRIMARY 
(
    -- Primary File: For small system tables and reference data (Users, Departments, Courses)
    NAME = 'ExamSys_Primary',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExaminationSystem_Data.mdf', -- Ensure this folder exists on your PC
    SIZE = 10MB,            -- Initial size
    MAXSIZE = 100MB,        -- Maximum size limit for this file
    FILEGROWTH = 5MB        -- Growth increment when file is full
),
FILEGROUP FG_ExamData       -- Secondary Filegroup: For large transactional data
(
    -- Data File: For tables expected to grow rapidly (Exams, Answers, Questions)
    NAME = 'ExamSys_Data',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExamSys_Data.ndf',
    SIZE = 50MB,            -- Larger initial size for expected volume
    MAXSIZE = UNLIMITED,    -- No maximum size limit
    FILEGROWTH = 10MB       -- Larger growth increment
)
LOG ON 
(
    -- Log File: For transaction logs
    NAME = 'ExamSys_Log',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExaminationSystem_Log.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);
GO

