USE [ExaminationSystemDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Stored Procedure For Students
CREATE OR ALTER PROCEDURE GetDataStudent
(
    @id INT,                     -- used for Update/Delete
    @name NVARCHAR(50),
    @email NVARCHAR(50),
    @phone NVARCHAR(50),
    @IN_id INT,
    @address NVARCHAR(50),
    @MgrId INT,
    @UserId INT,
    @birthday DATE,
    @StatementType NVARCHAR(20)
)
WITH ENCRYPTION
AS
BEGIN
    -- INSERT
    IF @StatementType = 'Insert'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Student WHERE UserId = @UserId)
        BEGIN
            INSERT INTO Student
            (Stdname, Stdemail, Stdphone, InId, Stdadd, Mgrid, UserId, Birthday)
            VALUES
            (@name, @email, @phone, @IN_id, @address, @MgrId, @UserId, @birthday)

            SELECT 'Inserted' AS Result
        END
        ELSE
        BEGIN
            SELECT 'Duplicate UserId' AS Result
        END
    END

    -- UPDATE
    ELSE IF @StatementType = 'Update'
    BEGIN
        UPDATE Student
        SET
            Stdname = @name,
            Stdemail = @email,
            Stdphone = @phone,
            InId = @IN_id,
            Stdadd = @address,
            Mgrid = @MgrId,
            UserId = @UserId,
            Birthday = @birthday
        WHERE StdId = @id

        IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Student Not Found' AS Result
    END

    -- DELETE
    ELSE IF @StatementType = 'Delete'
    BEGIN
        DELETE FROM Student
        WHERE StdId = @id

        IF @@ROWCOUNT > 0
            SELECT 'Deleted' AS Result
        ELSE
            SELECT 'Student Not Found' AS Result
    END
END

/*
Execute GetDataStudent @id = NULL,
    @name = 'Ali Hassan',
    @email = 'ali@student.com',
    @phone = '01099999999',
    @IN_id = 3,
    @address = 'Nasr City',
    @MgrId = 2,
    @UserId = 1,
    @birthday = '2001-04-10',
    @StatementType = 'Insert'
GO

EXEC GetDataStudent
    23,
    'Sara Ibrahim',
    'sara.s@student.com',
    '01200000001',
    3,
    'Cairo, Maadi',
    2,
    2,
    '2000-05-15',
    'Update'
GO

EXEC GetDataStudent
    4,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    'Delete';
GO

sp_helptext 'GetDataStudent'
GO
*/
--------------------------------------
create or alter proc GetSelectStudent
With Encryption
  as
  SELECT stdid,stdname,stdemail,InId,UserId,stdadd,birthday
            FROM  Student
Execute GetSelectStudent
GO
sp_helptext 'GetSelectStudent'
Go
------------------------------------------------------------------------------------
----Stored Procedure For Department
create or alter PROCEDURE GetDataDepartment( 
							 @Id INT,
							@Name  nVARCHAR(50),
							@MgrId int,
							@StatementType NVARCHAR(20) = '')
	with Encryption
			 AS
          BEGIN
          IF @StatementType = 'Insert'
				BEGIN
                  INSERT INTO [dbo].[Department]
				      (Deptname,
					  Mgrid)
					  Values(@Name,
					         @MgrId)
				  SELECT 'Inserted' AS Result
			   END
        ELSE IF @StatementType = 'Update'
        BEGIN
            UPDATE [dbo].[Department]
            SET   
                       [DeptName] = @Name,
                       [Mgrid]   = @MgrId
               WHERE  [DeptId]=@Id

			   IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Dept Not Found' AS Result
    END
       ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM [dbo].[Department]
            WHERE   [DeptId]= @Id

			IF @@ROWCOUNT > 0
            SELECT 'Deleted' AS Result
			ELSE
				SELECT 'Dept Not Found' AS Result
        END
END

  Execute GetDataDepartment 2,'Python',2,'update'
Go
sp_helptext 'GetDataDepartment'
Go
  /*
  DeptId	DeptName	Mgrid
1	Information Technology	1
*/
----------------
  create or alter proc GetSelectDepartment
  With Encryption
  as
  SELECT Deptid,Deptname,Mgrid
            FROM  [dbo].[Department]

Execute GetSelectDepartment
GO
sp_helptext 'GetSelectDepartment'
GO
----------------------------------------------------------------------------------------------------------
--Stored Procedure For Courses
create or alter PROCEDURE GetDataCourse (@id INTEGER,@name nvarchar(50), @Maxdegree int, @Mindegree int, @StatementType NVARCHAR(20) = '')
 With Encryption
AS     
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN
            INSERT INTO Course
                        (crs_name, Maxdegree, Mindegree)  
            VALUES     (@name, @Maxdegree, @Mindegree)
			SELECT 'Inserted' AS Result
		end
      ELSE IF @StatementType = 'Update'
        BEGIN
          UPDATE Course
            SET    crs_name=@name 
            WHERE  CrsId = @id

			IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Course Not Found' AS Result
      END
      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM Course
            WHERE  CrsId = @id

		 IF @@ROWCOUNT > 0
            SELECT 'Deleted' AS Result
        ELSE
            SELECT 'Student Not Found' AS Result
	   END
END

Exec GetDataCourse 4,'C# Basics', 100, 200, 'delete'
GO
sp_helptext 'GetDataCourse'
GO
------------------
create proc GetSelectCourse
With Encryption
  as
  SELECT Crsid,crs_name
            FROM  [dbo].[Course]

Execute GetSelectCourse
GO
sp_helptext 'GetSelectCourse'
Go
----------------------------------------------------------------------------
--Stored Procedure For Instructor
create or alter PROCEDURE GetDataInstructor (@id int,@name nvarchar(50),@email nvarchar(50),@sal int,@UserId int,@phone nvarchar(50),@StatementType nvarchar(50))
With Encryption
AS
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN
		 IF not exists (select 1 from Instructor where Userid=@UserId)
			BEGIN
				INSERT INTO Instructor
                        (instname,Insemail,Salary,userid,Insphone)  
				VALUES     (@name,@email,@sal,@UserId,@phone)
				SELECT 'Inserted' AS Result
			END
        ELSE
        BEGIN
            SELECT 'Duplicate UserId' AS Result
        END
	  END
      ELSE IF @StatementType = 'Update'
        BEGIN
            UPDATE Instructor
            SET    instname=@name,
				   Insemail=@email,
				   Salary=@sal,
				   userid=@UserId,
				   Insphone=@phone
            WHERE  Instid = @id

			 IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Instructor Not Found' AS Result
        END
      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM Instructor
            WHERE  Instid = @id

			IF @@ROWCOUNT > 0
            SELECT 'Deleted' AS Result
        ELSE
            SELECT 'Instructor Not Found' AS Result
      END
END

Exec GetDataInstructor 5,'salam','salam@inst.com',50000,8,'145268','update'
Go
sp_helptext 'GetDataInstructor'
GO
---------------
CREATE or alter PROC GetSelectInstructor @id int
With Encryption
as
select Instid,instname,Insemail,Salary,userid
      from [dbo].[Instructor] where instid=@id
Execute GetSelectInstructor 3
GO
sp_helptext 'GetSelectInstructor'
GO
----------------------------------------------------------------------------------------------------
--Stored Procedure For Ins_Crs
create or alter PROCEDURE GetDataIns_Crs (@InsID int,@crsID int,@StatementType nvarchar(50))
With Encryption
AS
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN
		 IF not exists (select Instid from Intcourse where Instid=@InsID And Crsid=@crsID )
			BEGIN
				INSERT INTO Intcourse
                        (Instid,Crsid)  
                VALUES     ( @InsID ,@crsID ) 
				SELECT 'Inserted' AS Result
			END
         ELSE
		 BEGIN
            SELECT 'Duplicate InsId or CrsId' AS Result
         END
		End 
      ELSE IF @StatementType = 'Update'
        BEGIN
            UPDATE Intcourse
            SET    Instid =@InsID,
			       Crsid=@crsID
      
            WHERE  Instid = @InsID AND Crsid=@crsID

			IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Course or Instructor Not Found' AS Result
        END
      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM Intcourse
            WHERE  Instid = @InsID AND Crsid=@crsID

			IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Course or Instructor Not Found' AS Result
        END
EnD

EXEC GetDataIns_Crs 1, 8, 'delete'
GO
sp_helptext 'GetDataIns_Crs'
GO
------------------------
Create or alter PROC GetSelectIns_Crs
With Encryption
as
select *
  from [dbo].[IntCourse]
EXEC GetSelectIns_Crs
GO
sp_helptext 'GetSelectIns_Crs'
GO
---------------------------------------------------------------------------------------------------------
--Stored Procedure For STudent_ex
Create or alter PROCEDURE GetDataStudent_Exam (@Std_ID int,@Ex_ID int,@grade int,@StatementType nvarchar(50))
with Encryption
AS
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN 
            INSERT INTO Stuexam
                        (stdid,Exid,total_score)  
            VALUES     ( @Std_ID ,@Ex_ID ,@grade)

			SELECT 'Inserted' AS Result
        END
      ELSE IF @StatementType = 'Update'
        BEGIN
            UPDATE Stuexam
            SET    stdid =@Std_ID,
			       exid=@Ex_ID,
				   total_score=@grade
            WHERE  stdid = @Std_ID AND exid=@Ex_ID

			IF @@ROWCOUNT > 0
            SELECT 'Updated' AS Result
        ELSE
            SELECT 'Student oe Exam Not Found' AS Result
        END
      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM Stuexam
            WHERE  stdid = @Std_ID AND exid=@Ex_ID

			IF @@ROWCOUNT > 0
            SELECT 'Deleted' AS Result
        ELSE
            SELECT 'Student or Exam Not Found' AS Result
    END
END
Exec GetDataStudent_Exam 5,2,150,'delete'
GO
sp_helptext 'GetDataStudent_Exam'
GO
---------------------------
create proc GetSelectStudent_Exam 
with Encryption
  as
    select * from StuExam
Exec GetSelectStudent_Exam 
GO
sp_helptext 'GetSelectStudent_Exam'
GO
-----------------------------------------------------------------------------------
--Stored Procedure For Intake
CREATE OR ALTER PROCEDURE AddIntake
(
    @ID INT,
    @InName VARCHAR(50),
    @Inyear INT,
	@BrId INT,
	@TrId INT,
    @MgrId INT
)
with Encryption
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE InName = @InName)
    BEGIN
        INSERT INTO Intake (InName, Inyear, BrId, TrId, MgrId)
        VALUES (@InName, @Inyear, @BrId, @TrId, @MgrId)
		SELECT 'Intake added successfully';
    END
    ELSE
    BEGIN
        SELECT 'Intake already exists';
    END
END
AddIntake 2,Intake56,2024,3,2,2
GO
SP_helptext 'AddIntake'
GO
-----------------------------------------------------------------------------------
--Stored Procedure For Branch
CREATE or alter PROC UpdateBranch
    @BrId INT,
	@DeptId INT,
    @NewName VARCHAR(100),
    @NewLocation VARCHAR(MAX)
with Encryption
AS
BEGIN
    UPDATE Branch
    SET DeptId=@DeptId, BrName = @NewName, Brloc = @NewLocation
    WHERE BrID = @BrID

	SELECT 'Branch added successfully'
END

UpdateBranch 3, 2, 'Cairo Branch', 'Smart'
GO
SP_helptext 'UpdateBranch'
GO
-----------------------------------------------------------------------------------
--Stored Procedure For Assign Student To Exam
CREATE or ALTER PROCEDURE AssignStdToEx
    @StdID INT,
    @ExID INT,
    @StartTime TIME,
    @EndTime TIME
with Encryption
AS
BEGIN
    IF EXISTS (SELECT 1 FROM StuExam WHERE ExId = @ExID)
    BEGIN
        INSERT INTO StuExam (StdID, ExID, StartTime, EndTime)
        VALUES (@StdID, @ExID, @StartTime, @EndTime)
    END
    ELSE
    BEGIN
        SELECT 'Error: Exam ID does not exist.' AS Result
    END
END
AssignStdToEx 23, 1, '10:05:00.0000000', '10:45:00.0000000'
GO
SP_helptext 'AssignStdToEx'
GO
-----------------------------------------------------------------------------------
--Stored Procedure For Generate Random Exam
CREATE OR ALTER PROCEDURE GenerateRandomExammm
(
    @CrsID INT,
    @ExType NVARCHAR(20),
    @NumQuestions INT,
    @InstID INT,
	@InId INT,
    @Year INT,
    @ExDate DATE,
    @StartTime TIME,
    @EndTime TIME,
    @TotalTime INT
)
with Encryption
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRAN  

        DECLARE 
            @NewExamID INT,
            @QID INT,
            @Degree FLOAT,
			@TotalDegree INT

        -- Insert Exam
        INSERT INTO Exam
        (
            CrsId, Extypes, InstId, InId, Ex_date, StartTime, Endtime,
            [Year], Totaltime, Totaldegree
        )
        VALUES
        (
            @CrsID, @ExType, @InstID, @InId, @ExDate, @StartTime, @EndTime,
            @Year, @TotalTime, 100
        );

        SET @NewExamID = SCOPE_IDENTITY();
        SET @Degree = 100.0 / @NumQuestions;

        -- Cursor
        DECLARE QuestionCursor CURSOR FOR
        SELECT TOP (@NumQuestions) QID
        FROM QuestionPool
        WHERE CrsID = @CrsID
        ORDER BY NEWID();

        OPEN QuestionCursor;
        FETCH NEXT FROM QuestionCursor INTO @QID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO ExQuestion (ExID, QID, Qdegree)
            VALUES (@NewExamID, @QID, @Degree);

            FETCH NEXT FROM QuestionCursor INTO @QID;
        END

        CLOSE QuestionCursor;
        DEALLOCATE QuestionCursor;

        COMMIT TRAN

        SELECT 'Exam generated successfully' AS Result;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO


/*
     @CrsID INT,
    @ExType NVARCHAR(20),
    @NumQuestions INT,
    @InstID INT,
    @Year INT,
    @ExDate DATE,
    @StartTime TIME,
    @EndTime TIME,
    @TotalTime INT
*/
GenerateRandomExammm 8, 'Exam', 3, 5, 6, 2025, '2025-11-01', '10:00:00.0000000', '12:00:00.0000000',120
GO
SP_helptext 'AssignStdToEx'
GO


