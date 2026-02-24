USE ExaminationSystemDB;
GO

-- =============================================
-- 1. USERS (Parent Table for all roles)
-- =============================================
INSERT INTO [User] (Username, Password, Role, Cdate) VALUES 
('admin_user', '123456', 'Admin', '2023-01-01'),-- id 1
('ahmed_mgr', '123456', 'TrainingManager', '2023-01-10'),-- id 2
('sara_mgr', '123456', 'TrainingManager', '2023-02-15'),-- id 3
('mohamed_inst', '123456', 'Instructor', '2023-03-01'),-- id 4
('ali_inst', '123456', 'Instructor', '2023-03-05'),-- id 5
('sara_std', '123456', 'Student', '2023-09-01'),-- id 6
('omar_std', '123456', 'Student', '2023-09-02'),-- id 7
('nour_std', '123456', 'Student', '2023-09-03');-- id 8
GO
INSERT INTO [User] (Username, Password, Role, Cdate) VALUES 
('ali_mgr', '123456', 'TrainingManager', '2026-01-10')-- id 9
-- =============================================
-- 2. ROLES TABLES (Managers, Instructors, Students)
-- =============================================
-- Note: We use the UserId generated above. Assuming IDENTITY started at 1.
-- Admin=1, AhmedMgr=2, SaraMgr=3, MohamedInst=4, AliInst=5, SaraStd=6, OmarStd=7, NourStd=8

INSERT INTO TrainingManager (UserId, Mgrname, Mgrphone, Mgremail) VALUES 
(2, 'Ahmed Mohamed', '01000000001', 'ahmed@training.com'),
(3, 'Sara Ali', '01000000002', 'sara@training.com');
INSERT INTO TrainingManager (UserId, Mgrname, Mgrphone, Mgremail) VALUES 
(9, 'Ali Ahmed', '01000000012', 'ali@training.com');
select * from TrainingManager

INSERT INTO Instructor (UserId, Instname, Insphone, Insemail, Salary, Hiredate) VALUES 
(4, 'Mohamed Hassan', '01100000001', 'mohamed@inst.com', 5000.00, '2023-01-01'),
(5, 'Ali Mahmoud', '01100000002', 'ali@inst.com', 4500.00, '2023-02-01');

-- We will insert Students later after we create Intakes
GO

-- =============================================
-- 3. ORGANIZATION STRUCTURE (Dept, Branch, Track)
-- =============================================
INSERT INTO Department (DeptName, Mgrid) VALUES 
('Information Technology', 1), -- Managed by Ahmed
('Web Development', 2);        -- Managed by Sara

select * from Department

INSERT INTO Branch (DeptId, Brname, Brloc) VALUES 
(7, 'Cairo Branch', 'Downtown'),
(8, 'Giza Branch', 'Haram');
INSERT INTO Track (Trname, Trdes, DeptId) VALUES 
('.Net Track', 'Learning C# and ASP.NET', 8),
('Java Track', 'Learning Core Java', 8),
('Front-End Track', 'HTML, CSS, JS', 7);
select * from Track
select * from Branch


-- ============================================= 
-- 4. LINKING TABLES (Branch_Track, Intake)
-- =============================================
INSERT INTO Branch_track (BrId, TrId, Stdate) VALUES 
(1, 1, '2023-01-01'), -- Cairo .Net
(1, 2, '2023-01-01'), -- Cairo Java
(2, 3, '2023-02-01'); -- Giza Front-End

select * from Branch_track
select * from Branch
select * from Track
select * from TrainingManager
select * from Intake

INSERT INTO Intake (Inname, Inyear, BrId, TrId, Mgrid) VALUES 
('Intake 55', 2023, 1, 2, 2), -- Cairo .Net 
('Intake 56', 2023, 2, 1, 1); -- Giza Front-End 
GO
INSERT INTO Intake (Inname, Inyear, BrId, TrId, Mgrid) VALUES 
('Intake 66', 2026, 1, 1, 3), -- Cairo JAVA 
('Intake 67', 2026, 2, 3, 2); -- Giza Front-End 
GO
-- =============================================
-- 5. STUDENTS (Now we can link them to Intake)
-- =============================================
-- Sara Std (ID 6) joins Intake 1 (Intake 55)
-- Omar Std (ID 7) joins Intake 1 (Intake 55)
-- Nour Std (ID 8) joins Intake 2 (Intake 56)
INSERT INTO Student (UserId, Stdname, Stdemail, Stdphone, Stdadd, Birthday, InId, Mgrid) VALUES 
(6, 'Sara Ibrahim', 'sara.s@student.com', '01200000001', 'Cairo, Maadi', '2000-05-15', 1, 2),
(7, 'Omar Khaled', 'omar.k@student.com', '01200000002', 'Cairo, Nasr City', '2001-02-10', 1, 2),
(8, 'Nour Hany', 'nour.h@student.com', '01200000003', 'Giza, 6th October', '2002-08-20', 2, 1);
GO
select * from TrainingManager
select * from Student
select * from Course
select * from Instructor
select * from QuestionPool
-- =============================================
-- 6. COURSES & TEACHING ASSIGNMENTS
-- =============================================
INSERT INTO Course (Crs_name, Crs_desc, Maxdegree, Mindegree) VALUES 
('SQL Server', 'Database Fundamentals', 100, 50),
('C# Basics', 'Programming Logic', 100, 50),
('HTML & CSS', 'Web Structure', 100, 40);

-- Mohamed Inst (ID 1) teaches SQL (ID 1)
-- Ali Inst (ID 2) teaches HTML (ID 3)
INSERT INTO Intcourse (InstId, CrsId, Classname) VALUES 
(1, 1, 'Class A'),
(2, 3, 'Class B');

select * from Course
select * from Instructor
select * from Intcourse
INSERT INTO Intcourse (InstId, CrsId, Classname) VALUES 
(2, 2, 'Class C');


-- =============================================
-- 7. QUESTION POOL (For SQL Course)
-- =============================================
-- Q1: MCQ
INSERT INTO QuestionPool (Qtext, Qtypes, Correct, [level], CrsId, InstId, Created_date) VALUES 
('What does SQL stand for?', 'MCQ', '1', 'Easy', 1, 1, '2023-05-01');

-- Add Choices for Q1 (Qid=1)
INSERT INTO Queschoices (Qid, Chtext, Chnum) VALUES 
(1, 'Structured Query Language', 1),
(1, 'Simple Question Language', 2),
(1, 'System Query Logic', 3);

-- Q2: TrueFalse
INSERT INTO QuestionPool (Qtext, Qtypes, Correct, [level], CrsId, InstId, Created_date) VALUES 
('Primary Key can be NULL.', 'TrueFalse', 'False', 'Easy', 1, 1, '2023-05-02');
INSERT INTO QuestionPool (Qtext, Qtypes, Correct, [level], CrsId, InstId, Created_date) VALUES 
('Forign Key can be NULL.', 'TrueFalse', 'True', 'Easy', 1, 1, '2023-05-02');

-- Q3: Text Question
INSERT INTO QuestionPool (Qtext, Qtypes, Correct, [level], CrsId, InstId, Created_date) VALUES 
('Write the command to select all columns.', 'Text', 'SELECT *', 'Medium', 1, 1, '2023-05-03');
INSERT INTO QuestionPool (Qtext, Qtypes, Correct, [level], CrsId, InstId, Created_date) VALUES 
('Write the keyword to filter result in query without agg functions', 'Text', 'WHERE', 'Easy', 1, 1, '2023-05-03');
GO

-- =============================================
-- 8. EXAMS
-- =============================================
-- Create a Midterm Exam for SQL Course, Intake 1
INSERT INTO Exam (Extypes, InstId, CrsId, InId, Ex_date, StartTime, Endtime, [Year], Totaltime, Totaldegree, [options]) VALUES 
('Exam', 1, 1, 1, '2023-10-01', '10:00', '12:00', 2023, 120, 100, 'Open Book');
GO
INSERT INTO Exam (Extypes, InstId, CrsId, InId, Ex_date, StartTime, Endtime, [Year], Totaltime, Totaldegree, [options], ExName) VALUES 
('Exam', 1, 2, 1, '2023-10-10', '10:00', '12:00', 2023, 120, 100, 'Open Book', 'C#Basics');
INSERT INTO Exam (Extypes, InstId, CrsId, InId, Ex_date, StartTime, Endtime, [Year], Totaltime, Totaldegree, [options], ExName) VALUES 
('Exam', 1, 2, 1, '2023-10-10', '10:00', '12:00', 2023, 120, 100, 'Open Book', 'HTML&CSS');
GO
select * from Exam
select * from Student
select * from Course
select * from Instructor
select * from Intake
-- =============================================
-- 9. EXAM QUESTIONS (Link Questions to Exam)
-- =============================================
-- Add Q1 (50 deg), Q2 (20 deg), Q3 (30 deg) to Exam 1
INSERT INTO ExQuestion (ExId, Qid, Qdegree) VALUES 
(1, 1, 50),
(1, 2, 20),
(1, 3, 30);
GO
INSERT INTO ExQuestion (ExId, Qid, Qdegree) VALUES 
(1, 5, 10)
select * from QuestionPool
select * from ExQuestion
select * from Exam
select * from Student
select * from Stanswer
select * from StuExam
select * from Course
select * from Instructor

-- =============================================
-- 10. STUDENT EXAMS (Register Students for Exam)
-- =============================================
-- Sara (StdId 1) and Omar (StdId 2) take Exam 1
INSERT INTO StuExam (StdId, ExId, startTime, endtime) VALUES 
(1, 1, '10:05', '11:30'),
(2, 1, '10:10', '11:45');
GO
INSERT INTO StuExam (StdId, ExId, startTime, endtime) VALUES 
(3, 1, '10:05', '11:30')

GO
-- =============================================
-- 11. STUDENT ANSWERS (The Results)
-- =============================================
-- Sara's Answers (StdId 1, ExId 1)
-- Q1: She chose Option 1 (Correct)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (1, 1, 1, '1', 50, 1);
-- Q2: She chose False (Correct)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (1, 1, 2, 'False', 20, 1);
-- Q3: She wrote "SELECT *" (Correct)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (1, 1, 3, 'SELECT *', 30, 1);

-- Omar's Answers (StdId 2, ExId 1)
-- Q1: He chose Option 2 (Wrong)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (2, 1, 1, '2', 0, 0);
-- Q2: He chose True (Wrong)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (2, 1, 2, 'True', 0, 0);
-- Q3: He wrote "SELECT" (Partial/Wrong depending on logic, let's say 0 for now)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer, Gradmarks, correct) VALUES (2, 1, 3, 'SELECT', 0, 0);

-- norhan's Answers (StdId 3, ExId 1)
-- Q1: He chose Option 2 (Wrong)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer) VALUES (3, 1, 1, '2');
-- Q2: He chose True (Wrong)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer) VALUES (3, 1, 2, 'False');
-- Q3: He wrote "SELECT" (Partial/Wrong depending on logic, let's say 0 for now)
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer) VALUES (3, 1, 3, 'SELECT *');
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer) VALUES (3, 1, 4, 'SELECT *');
INSERT INTO Stanswer (StdId, ExId, Qid, Stanswer) VALUES (3, 1, 5, 'True');


update Stanswer set correct = 1
where Ans_id = 11

select * from  Student
select * from  Stanswer
select * from  StuExam
select * from  ExQuestion




-- =============================================
-- 12. UPDATE FINAL SCORES (Manual Step for Demo)
-- =============================================
-- Update Sara's Total Score (50+20+30 = 100)
UPDATE StuExam SET Total_score = 100, Obtained_degree = 100 WHERE StdId = 1 AND ExId = 1;

-- Update Omar's Total Score (0)
UPDATE StuExam SET Total_score = 100, Obtained_degree = 0 WHERE StdId = 2 AND ExId = 1;
GO

-- Verify Data
SELECT * FROM [User];
SELECT * FROM Student;
SELECT * FROM Exam;
SELECT * FROM Stanswer;