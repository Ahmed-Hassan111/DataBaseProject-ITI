USE ExaminationSystemDB;
GO

-- =============================================
-- 1. MASTER / REFERENCE TABLES (Stored in PRIMARY)
-- =============================================

-- 1. User Table
CREATE TABLE [User] (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'TrainingManager', 'Instructor', 'Student')),
    Cdate DATE NOT NULL DEFAULT GETDATE()
) ON [PRIMARY];
GO

-- 2. TrainingManager Table
CREATE TABLE TrainingManager (
    Mgrid INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    Mgrname NVARCHAR(100) NOT NULL,
    Mgrphone NVARCHAR(20),
    Mgremail NVARCHAR(100),
    CONSTRAINT FK_TrainingManager_User FOREIGN KEY (UserId) REFERENCES [User](UserId)
) ON [PRIMARY];
GO

-- 3. Department Table
CREATE TABLE Department (
    DeptId INT IDENTITY(1,1) PRIMARY KEY,
    DeptName NVARCHAR(100) NOT NULL,
    Mgrid INT NOT NULL,
    CONSTRAINT FK_Department_TrainingManager FOREIGN KEY (Mgrid) REFERENCES TrainingManager(Mgrid)
) ON [PRIMARY];
GO

-- 4. Branch Table
CREATE TABLE Branch (
    BrId INT IDENTITY(1,1) PRIMARY KEY,
    DeptId INT NOT NULL,
    Brname NVARCHAR(100) NOT NULL,
    Brloc NVARCHAR(255),
    CONSTRAINT FK_Branch_Department FOREIGN KEY (DeptId) REFERENCES Department(DeptId)
) ON [PRIMARY];
GO

-- 5. Track Table
CREATE TABLE Track (
    TrId INT IDENTITY(1,1) PRIMARY KEY,
    Trname NVARCHAR(100) NOT NULL,
    Trdes NVARCHAR(500),
    DeptId INT NOT NULL,
    CONSTRAINT FK_Track_Department FOREIGN KEY (DeptId) REFERENCES Department(DeptId)
) ON [PRIMARY];
GO

-- 6. Branch_track Table
CREATE TABLE Branch_track (
    BrId INT NOT NULL,
    TrId INT NOT NULL,
    Stdate DATE NOT NULL,
    PRIMARY KEY (BrId, TrId),
    CONSTRAINT FK_BranchTrack_Branch FOREIGN KEY (BrId) REFERENCES Branch(BrId),
    CONSTRAINT FK_BranchTrack_Track FOREIGN KEY (TrId) REFERENCES Track(TrId)
) ON [PRIMARY];
GO

-- 7. Intake Table
CREATE TABLE Intake (
    InId INT IDENTITY(1,1) PRIMARY KEY,
    Inname NVARCHAR(50) NOT NULL,
    Inyear INT NOT NULL,
    BrId INT NOT NULL,
    TrId INT NOT NULL,
    Mgrid INT NOT NULL,
    CONSTRAINT FK_Intake_Branch FOREIGN KEY (BrId) REFERENCES Branch(BrId),
    CONSTRAINT FK_Intake_Track FOREIGN KEY (TrId) REFERENCES Track(TrId),
    CONSTRAINT FK_Intake_TrainingManager FOREIGN KEY (Mgrid) REFERENCES TrainingManager(Mgrid)
) ON [PRIMARY];
GO

-- 8. Student Table
-- (Placed in Primary as it links to User, but could be moved to FG_ExamData if millions of students expected)
CREATE TABLE Student (
    StdId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    Stdname NVARCHAR(100) NOT NULL,
    Stdemail NVARCHAR(100),
    Stdphone NVARCHAR(20),
    Stdadd NVARCHAR(255),
    Birthday DATE,
    InId INT NOT NULL,
    Mgrid INT NOT NULL,
    CONSTRAINT FK_Student_User FOREIGN KEY (UserId) REFERENCES [User](UserId),
    CONSTRAINT FK_Student_Intake FOREIGN KEY (InId) REFERENCES Intake(InId),
    CONSTRAINT FK_Student_TrainingManager FOREIGN KEY (Mgrid) REFERENCES TrainingManager(Mgrid)
) ON [PRIMARY];
GO

-- 9. Instructor Table
CREATE TABLE Instructor (
    InstId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    Instname NVARCHAR(100) NOT NULL,
    Insphone NVARCHAR(20),
    Insemail NVARCHAR(100),
    Salary DECIMAL(18, 2),
    Hiredate DATE,
    CONSTRAINT FK_Instructor_User FOREIGN KEY (UserId) REFERENCES [User](UserId)
) ON [PRIMARY];
GO

-- 10. Course Table
CREATE TABLE Course (
    CrsId INT IDENTITY(1,1) PRIMARY KEY,
    Crs_name NVARCHAR(100) NOT NULL,
    Crs_desc NVARCHAR(500),
    Maxdegree INT NOT NULL,
    Mindegree INT NOT NULL
) ON [PRIMARY];
GO

-- 11. Intcourse Table
CREATE TABLE Intcourse (
    InstId INT NOT NULL,
    CrsId INT NOT NULL,
    Classname NVARCHAR(50),
    PRIMARY KEY (InstId, CrsId),
    CONSTRAINT FK_Intcourse_Instructor FOREIGN KEY (InstId) REFERENCES Instructor(InstId),
    CONSTRAINT FK_Intcourse_Course FOREIGN KEY (CrsId) REFERENCES Course(CrsId)
) ON [PRIMARY];
GO

-- =============================================
-- 2. TRANSACTIONAL / HIGH-VOLUME TABLES (Stored in FG_ExamData)
-- =============================================

-- 12. QuestionPool Table (Will grow as instructors add questions)
CREATE TABLE QuestionPool (
    Qid INT IDENTITY(1,1) PRIMARY KEY,
    Qtext NVARCHAR(MAX) NOT NULL,
    Qtypes NVARCHAR(20) NOT NULL CHECK (Qtypes IN ('MCQ', 'TrueFalse', 'Text')),
    Correct NVARCHAR(MAX),
    [level] NVARCHAR(20),
    CrsId INT NOT NULL,
    InstId INT NOT NULL,
    Created_date DATE DEFAULT GETDATE(),
    CONSTRAINT FK_QuestionPool_Course FOREIGN KEY (CrsId) REFERENCES Course(CrsId),
    CONSTRAINT FK_QuestionPool_Instructor FOREIGN KEY (InstId) REFERENCES Instructor(InstId)
) ON [FG_ExamData];
GO

-- 13. Queschoices Table (Multiplies with every MCQ question)
CREATE TABLE Queschoices (
    ChId INT IDENTITY(1,1) PRIMARY KEY,
    Qid INT NOT NULL,
    Chtext NVARCHAR(255) NOT NULL,
    Chnum INT NOT NULL,
    CONSTRAINT FK_Queschoices_QuestionPool FOREIGN KEY (Qid) REFERENCES QuestionPool(Qid)
) ON [FG_ExamData];
GO

-- 14. Exam Table
CREATE TABLE Exam (
    ExId INT IDENTITY(1,1) PRIMARY KEY,
    Extypes NVARCHAR(20) CHECK (Extypes IN ('Exam', 'Corrective')),
    InstId INT NOT NULL,
    CrsId INT NOT NULL,
    InId INT NOT NULL,
    Ex_date DATE NOT NULL,
    StartTime TIME NOT NULL,
    Endtime TIME NOT NULL,
    [Year] INT NOT NULL,
    Totaltime INT NOT NULL,
    Totaldegree INT NOT NULL,
    [options] NVARCHAR(255),
    CONSTRAINT FK_Exam_Instructor FOREIGN KEY (InstId) REFERENCES Instructor(InstId),
    CONSTRAINT FK_Exam_Course FOREIGN KEY (CrsId) REFERENCES Course(CrsId),
    CONSTRAINT FK_Exam_Intake FOREIGN KEY (InId) REFERENCES Intake(InId)
) ON [FG_ExamData];
GO

-- 15. ExQuestion Table (Links Exams to Questions)
CREATE TABLE ExQuestion (
    ExId INT NOT NULL,
    Qid INT NOT NULL,
    Qdegree INT NOT NULL,
    PRIMARY KEY (ExId, Qid),
    CONSTRAINT FK_ExQuestion_Exam FOREIGN KEY (ExId) REFERENCES Exam(ExId),
    CONSTRAINT FK_ExQuestion_QuestionPool FOREIGN KEY (Qid) REFERENCES QuestionPool(Qid)
) ON [FG_ExamData];
GO

-- 16. StuExam Table (Records of students taking exams)
CREATE TABLE StuExam (
    StdId INT NOT NULL,
    ExId INT NOT NULL,
    Total_score DECIMAL(18, 2) DEFAULT 0,
    Obtained_degree DECIMAL(18, 2),
    startTime TIME,
    endtime TIME,
    PRIMARY KEY (StdId, ExId),
    CONSTRAINT FK_StuExam_Student FOREIGN KEY (StdId) REFERENCES Student(StdId),
    CONSTRAINT FK_StuExam_Exam FOREIGN KEY (ExId) REFERENCES Exam(ExId)
) ON [FG_ExamData];
GO

-- 17. Stanswer Table (THE LARGEST TABLE: Stores every answer given by every student)
CREATE TABLE Stanswer (
    Ans_id INT IDENTITY(1,1) PRIMARY KEY,
    StdId INT NOT NULL,
    ExId INT NOT NULL,
    Qid INT NOT NULL,
    Stanswer NVARCHAR(MAX),
    Gradmarks DECIMAL(18, 2),
    correct BIT,
    CONSTRAINT FK_Stanswer_Student FOREIGN KEY (StdId) REFERENCES Student(StdId),
    CONSTRAINT FK_Stanswer_Exam FOREIGN KEY (ExId) REFERENCES Exam(ExId),
    CONSTRAINT FK_Stanswer_QuestionPool FOREIGN KEY (Qid) REFERENCES QuestionPool(Qid)
) ON [FG_ExamData];
GO