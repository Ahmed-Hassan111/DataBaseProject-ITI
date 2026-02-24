----------- VIEWS -----------

--- view 1 student state in exam

CREATE or alter VIEW vw_StudentCourseResults
AS
SELECT 
    s.Stdname,
    c.Crs_name,
    SUM(ISNULL(se.Total_score,0)) AS FinalResult,
    CASE 
        WHEN SUM(ISNULL(se.Obtained_degree,0)) >= c.Mindegree 
        THEN 'Passed'
        ELSE 'Failed'
    END AS Status
FROM StuExam se
JOIN Student s ON se.StdId = s.StdId
JOIN Exam e ON se.ExId = e.ExId
JOIN Course c ON e.CrsId = c.CrsId
GROUP BY s.Stdname, c.Crs_name, c.Mindegree

---test
SELECT * FROM vw_StudentCourseResults;


--- view 2 ranking in specific exam

CREATE or alter VIEW vw_ExamRanking
AS
SELECT 
    e.ExId,
    s.Stdname,
    se.Total_score,
	se.Obtained_degree,
    RANK() OVER (PARTITION BY e.ExId ORDER BY se.Obtained_degree DESC) AS RankInExam
FROM StuExam se
JOIN Student s ON se.StdId = s.StdId
JOIN Exam e ON se.ExId = e.ExId
GO

---test
SELECT * FROM vw_ExamRanking WHERE ExId = 1;



----- view 3 Instructor Courses 
CREATE or alter VIEW vw_InstructorCourses
AS
SELECT 
    i.Instname,
    c.Crs_name
FROM Instructor i
JOIN Intcourse ic on i.InstId= ic.InstId
join Course c on ic.CrsId = c.CrsId

---test
select * from vw_InstructorCourses

---- view 4 Student Exam Details

CREATE or alter VIEW vw_StudentExamDetails
AS
SELECT 
    s.Stdname,
    c.Crs_name,    
	se.Obtained_degree,
    se.Total_score,
	c.Mindegree,
	-- Custom Column
    CASE 
        WHEN se.Obtained_degree >= c.Mindegree 
            THEN 'Passed'
        ELSE 'Failed'
    END AS ExamStatus

FROM StuExam se
JOIN Student s ON se.StdId = s.StdId
JOIN Exam e ON se.ExId = e.ExId
JOIN Course c ON e.CrsId = c.CrsId
GO

---test
SELECT * 
FROM vw_StudentExamDetails
WHERE Stdname = 'Omar Khaled'


--- views 5 report of CoursePerformanceSummary

CREATE OR ALTER VIEW vw_CoursePerformanceSummary
AS
SELECT 
    c.Crs_name,
    COUNT(se.StdId) AS TotalStudents,
    SUM(CASE WHEN se.Obtained_degree >= c.Mindegree THEN 1 ELSE 0 END) AS PassedStudents, ----sum of passed students
    SUM(CASE WHEN se.Obtained_degree < c.Mindegree THEN 1 ELSE 0 END) AS FailedStudents,------ sum of failed students
    CAST(
        (SUM(CASE WHEN se.Obtained_degree >= c.Mindegree THEN 1 ELSE 0 END) * 100.0)
        / NULLIF(COUNT(se.StdId),0)
        AS DECIMAL(5,2)
    ) AS PassPercentage  ----- precentage of passed students
FROM StuExam se
JOIN Exam e ON se.ExId = e.ExId
JOIN Course c ON e.CrsId = c.CrsId
GROUP BY c.Crs_name
GO

--test
select * from vw_CoursePerformanceSummary


--- view 6 top students per course
CREATE OR ALTER VIEW vw_TopStudentsPerCourse
AS
SELECT *
FROM (
    SELECT 
        c.Crs_name,
        s.Stdname,
        se.Obtained_degree,
        DENSE_RANK() OVER (PARTITION BY c.Crs_name 
                           ORDER BY se.Obtained_degree DESC) AS RankInCourse
    FROM StuExam se
    JOIN Student s ON se.StdId = s.StdId
    JOIN Exam e ON se.ExId = e.ExId
    JOIN Course c ON e.CrsId = c.CrsId
) t
WHERE RankInCourse <= 3
GO

--test 
select * from vw_TopStudentsPerCourse



--- view 7 Students At Risk

CREATE OR ALTER VIEW vw_StudentsAtRisk
AS
SELECT 
    s.Stdname,
    c.Crs_name,
    se.Obtained_degree,
    c.Mindegree,
    (c.Mindegree - se.Obtained_degree) AS NeededMarks ---- marks required to be passed
FROM StuExam se
JOIN Student s ON se.StdId = s.StdId
JOIN Exam e ON se.ExId = e.ExId
JOIN Course c ON e.CrsId = c.CrsId
WHERE se.Obtained_degree < c.Mindegree
GO

--test
select * from vw_StudentsAtRisk


--- view 8 Exam Difficulty Indicator

CREATE OR ALTER VIEW vw_ExamStatistics
AS
SELECT 
    e.ExId,
    c.Crs_name,
    AVG(se.Obtained_degree) AS AvgScore,
    MIN(se.Obtained_degree) AS MinScore,
    MAX(se.Obtained_degree) AS MaxScore
FROM StuExam se
JOIN Exam e ON se.ExId = e.ExId
JOIN Course c ON e.CrsId = c.CrsId
GROUP BY e.ExId, c.Crs_name
GO

--- test
select * from vw_ExamStatistics