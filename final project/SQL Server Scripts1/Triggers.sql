
==============================================Triggers=========================================================

-- 1-  Auto Grade

CREATE or alter TRIGGER AutoGrade
ON Stanswer
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SA
    SET 
        SA.Gradmarks = CASE 
            WHEN QP.Qtypes IN ('MCQ', 'TrueFalse') AND SA.Stanswer = QP.Correct THEN EQ.Qdegree
            ELSE 0 
        END,
        SA.correct = CASE 
            WHEN QP.Qtypes IN ('MCQ', 'TrueFalse') AND SA.Stanswer = QP.Correct THEN 1
            ELSE 0 
        END
    FROM Stanswer SA
    JOIN inserted i ON SA.Ans_id = i.Ans_id
    JOIN QuestionPool QP ON SA.Qid = QP.Qid
    JOIN ExQuestion EQ ON SA.ExId = EQ.ExId AND SA.Qid = EQ.Qid;

 
	UPDATE SE

SET SE.Obtained_degree = CASE 
	
    WHEN CalculatedSum > E.TotalDegree THEN E.TotalDegree 
	

    ELSE CalculatedSum 

END

FROM StuExam SE

JOIN inserted i ON SE.StdId = i.StdId AND SE.ExId = i.ExId

JOIN Exam E ON SE.ExId = E.ExId

CROSS APPLY (

    SELECT ISNULL(SUM(Gradmarks), 0) AS CalculatedSum

    FROM Stanswer 

    WHERE StdId = i.StdId AND ExId = i.ExId

) AS TempTable;
 
END;
GO 
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger -----------------------------------------------------------------------

insert into Stanswer (stdid, exid, qid, stanswer)
values (1, 1, 2, 'False'); 

select gradmarks, correct 
from stanswer 
where stdid = 1 and qid = 1;

select obtained_degree 
from stuexam 
where stdid = 1 and exid = 1;

==============================================================================================================================

-- 2- Locked Answer AfterTime
CREATE TRIGGER LockedAnswerAfterTime
ON Stanswer
FOR INSERT, UPDATE
AS
BEGIN
   
    DECLARE @CurrentTime TIME = CAST(GETDATE() AS TIME);

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN StuExam se ON i.StdId = se.StdId AND i.ExId = se.ExId
        WHERE @CurrentTime > se.endtime 
    )
    BEGIN
        RAISERROR ('Sorry cannot add/edit answer. Exam time has ended', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger -----------------------------------------------------------------------

update exam 
set endtime = cast(dateadd(minute, -1, getdate()) as time) 
where exid = 1;

update stuexam 
set endtime = cast(dateadd(minute, -1, getdate()) as time) 
where exid = 1 and stdid = 1;

update stanswer set stanswer = 'B' where stdid = 1 and qid = 1;

==============================================================================================================================

-- 3- Exam Overlap
CREATE TRIGGER ExamOverlap
ON StuExam
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN StuExam se ON i.StdId = se.StdId
        WHERE i.ExId <> se.ExId 
        AND i.startTime < se.endtime 
        AND i.endtime > se.startTime
    )
    BEGIN
        RAISERROR ('Student is already registered in another exam at this time', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger -----------------------------------------------------------------------
SELECT * FROM StuExam WHERE StdId = 1 AND ExId = 1;
DELETE FROM StuExam WHERE StdId = 1 AND ExId = 1;

insert into StuExam (stdid, exid, starttime, endtime)
values (1, 1, '10:00:00', '12:00:00');

insert into StuExam (stdid, exid, starttime, endtime)
values (1, 4, '11:00:00', '13:00:00');

==============================================================================================================================

-- 4 - Audit Grade Changes

create table gradeauditlog (
    auditid int identity(1,1) primary key,
    stdid int,
    exid int,
    oldgrade decimal(5,2),
    newgrade decimal(5,2),
    changedby nvarchar(100),
    changedate datetime default getdate()
);
go

CREATE TRIGGER AuditGradeChanges
ON Stanswer
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Gradmarks) 
    BEGIN
        INSERT INTO gradeauditlog (stdid, exid, oldgrade, newgrade, changedby)
        SELECT d.stdid, d.exid, d.gradmarks, i.gradmarks, SUSER_NAME()
        FROM inserted i
        JOIN deleted d ON i.ans_id = d.ans_id;
    END
END;
GO

-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger -----------------------------------------------------------------------

update stanswer set gradmarks = 50 where ans_id = 1;

select * from gradeauditlog;

==============================================================================================================================

-- 5 - Check Track Capacity

CREATE TRIGGER CheckTrackCapacity
ON Student
FOR INSERT
AS
BEGIN
    DECLARE @MaxCapacity INT = 25; 

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN (
            SELECT InId, COUNT(*) as currentcount 
            FROM Student 
            GROUP BY InId
        ) s ON i.InId = s.InId
        WHERE s.currentcount > @MaxCapacity
    )
    BEGIN
        RAISERROR ('Maximum capacity reached for this track', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger ----------------------------------------------------------------------



-- Befor try shoud be change @MaxCapacity to 1 or 2 to try 

insert into [user] (username, password, role) values ('test_user', '123', 'Student');
insert into student (userid, stdname, inid, mgrid) values (scope_identity(), 'Ali', 1, 1);

==============================================================================================================================

-- 6 - Protect Pool Exam

CREATE OR ALTER TRIGGER ProtectPoolExam
ON QuestionPool
FOR UPDATE, DELETE
AS
BEGIN
    DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @CurrentTime TIME = CAST(GETDATE() AS TIME);

    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN ExQuestion eq ON d.Qid = eq.Qid
        JOIN Exam e ON eq.ExId = e.ExId
        WHERE CAST(e.Ex_date AS DATE) = @CurrentDate  -- ? ??? ?????
        AND @CurrentTime BETWEEN e.StartTime AND e.EndTime  -- ? ??? ?????
    )
    BEGIN
        RAISERROR ('Can not modify questions while an active exam is using them', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Try Trigger ----------------------------------------------------------------------


update exam set starttime = '00:00:00', endtime = '23:59:59' where exid = 1;
update exam set Ex_date = '2026-10-01' where exid = 1;

delete from questionpool where qid = 1;