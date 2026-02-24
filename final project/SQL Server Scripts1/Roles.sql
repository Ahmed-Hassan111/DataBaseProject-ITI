----------- Roles -----------

---------------- LOGINS IN SERVER LEVEL-------------
USE master;
GO

CREATE LOGIN admin_l WITH PASSWORD = 'A1234';
CREATE LOGIN instructor_l WITH PASSWORD = 'M1234';
CREATE LOGIN manager_l WITH PASSWORD = 'I1234';
CREATE LOGIN student_l WITH PASSWORD = 'S1234';



------------ Users in ExaminationSystemDB database ------------
USE ExaminationSystemDB;
GO

CREATE USER admin_user FOR LOGIN admin_l;
CREATE USER instructor_user FOR LOGIN instructor_l;
CREATE USER manager_user FOR LOGIN manager_l;
CREATE USER student_user FOR LOGIN student_l;

------------------- creating roles -------------
CREATE ROLE AdminRole;
CREATE ROLE InstructorRole;
CREATE ROLE ManagerRole;
CREATE ROLE StudentRole;
-------------------- link users to roles ---------
ALTER ROLE AdminRole ADD MEMBER admin_user;
ALTER ROLE InstructorRole ADD MEMBER instructor_user;
ALTER ROLE ManagerRole ADD MEMBER manager_user;
ALTER ROLE StudentRole ADD MEMBER student_user;

------admin roles(full access)-----
ALTER ROLE db_owner ADD MEMBER admin_user;


-------------Instructor role--------
---  table ---- 
GRANT SELECT ON dbo.Student TO InstructorRole;

-- sp

-- func
GRANT EXECUTE ON fn_IsAnswerCorrect TO InstructorRole;
GRANT EXECUTE ON fn_StudentTotalScore TO InstructorRole;
GRANT EXECUTE ON fn_CourseFinalResult TO InstructorRole;
GRANT EXECUTE ON fn_IsStudentPassedCourse TO InstructorRole;
GRANT EXECUTE ON fn_GetStudentRankInExam TO InstructorRole;
-- views
GRANT SELECT ON vw_StudentExamDetails TO InstructorRole;
GRANT SELECT ON vw_ExamRanking TO InstructorRole;
GRANT SELECT ON vw_InstructorCourses TO InstructorRole;

GO
---- manager roles ---

---  table ---- 
GRANT SELECT ON SCHEMA::dbo TO ManagerRole;

-- sp
GRANT EXECUTE ON AddIntake TO ManagerRole;
GRANT EXECUTE ON UpdateBranch TO ManagerRole;
GO
-- func

-- views
GRANT SELECT ON vw_CoursePerformanceSummary TO ManagerRole;
GRANT SELECT ON vw_TopStudentsPerCourse TO ManagerRole;
GRANT SELECT ON vw_StudentsAtRisk TO ManagerRole;
GRANT SELECT ON vw_ExamStatistics TO ManagerRole;
GRANT SELECT ON vw_StudentCourseResults TO ManagerRole;

GO


--------- student roles --------

---  table ---- 
-- deny from and operation in tables
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO StudentRole;
GO
--sp

GO
--func
GRANT EXECUTE ON fn_CourseFinalResult TO StudentRole;
GRANT EXECUTE ON fn_IsStudentPassedCourse TO StudentRole;
GRANT EXECUTE ON fn_GetStudentRankInExam TO StudentRole;
GRANT EXECUTE ON fn_IsExamTimeValid TO StudentRole;
GO
-- view
GRANT SELECT ON vw_StudentExamDetails TO StudentRole;
GRANT SELECT ON vw_StudentCourseResults TO StudentRole;
GO

GO








----------------- TEST -------------

----- instructor-------
USE ExaminationSystemDB;
GO

EXECUTE AS USER = 'instructor_user';

-- will success
SELECT * FROM dbo.Student;

SELECT * FROM vw_StudentExamDetails;

SELECT dbo.fn_CourseFinalResult(1,1);

-- will fail 
DELETE FROM dbo.Student;

REVERT;



--------- manager ------
EXECUTE AS USER = 'manager_user';

-- will success
SELECT * FROM dbo.Student;

EXEC AddIntake;

-- will fail 
INSERT INTO dbo.Student VALUES (...);

REVERT;


---- Student ----
EXECUTE AS USER = 'student_user';



--  (views)
SELECT * FROM vw_StudentExamDetails;

--  (functions)
SELECT dbo.fn_GetStudentRankInExam(1,1);

--  (table access)
SELECT * FROM dbo.Student;
REVERT;