----------- FUNCTIONS --------------


-- function 1 check student answer
CREATE OR ALTER FUNCTION fn_IsAnswerCorrect
(
    @Qid INT,
    @StudentAnswer NVARCHAR(MAX)
)
RETURNS NVARCHAR(50) ---- 
AS
BEGIN
    DECLARE @Result NVARCHAR(50) --BIT = 0
    DECLARE @CorrectAnswer NVARCHAR(MAX)
    DECLARE @QuestionType NVARCHAR(20)

    -- Get question info
    SELECT 
        @CorrectAnswer = Correct,
        @QuestionType = Qtypes
    FROM QuestionPool
    WHERE Qid = @Qid

    -- MCQ
    IF @QuestionType = 'MCQ'
    BEGIN
        IF @StudentAnswer = @CorrectAnswer
            SET @Result = 'CorrectAnswer'
		ELSE
			SET @Result = 'WrongAnswer'
    END

    -- TrueFalse
    ELSE IF @QuestionType = 'TrueFalse'
    BEGIN
        IF LOWER(LTRIM(RTRIM(@StudentAnswer))) = 
           LOWER(LTRIM(RTRIM(@CorrectAnswer)))
            SET @Result = 'CorrectAnswer'
		ELSE
			SET @Result = 'WrongAnswer'
    END

    -- Text
    ELSE IF @QuestionType = 'Text'
    BEGIN
        IF LOWER(LTRIM(RTRIM(@StudentAnswer))) = 
           LOWER(LTRIM(RTRIM(@CorrectAnswer)))
            SET @Result = 'CorrectAnswer'
		ELSE
			SET @Result = 'WrongAnswer'
    END

    RETURN @Result
END
GO

-- test
SELECT dbo.fn_IsAnswerCorrect(1, '8')   -- MCQ
SELECT dbo.fn_IsAnswerCorrect(2, 'False') -- TrueFalse
SELECT dbo.fn_IsAnswerCorrect(3, 'SELECT *') -- Text
SELECT dbo.fn_IsAnswerCorrect(1, '0') -- MCQ
SELECT dbo.fn_IsAnswerCorrect(3, 'SELECT') -- Text






-- function 2 calculate student total score
CREATE OR ALTER FUNCTION fn_StudentTotalScore
(
    @StName nvarchar(100),
    @ExId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2) = 0

    SELECT @Total = SUM(ISNULL(s.Gradmarks,0))
    FROM Stanswer s
	join Student ss on s.StdId = ss.StdId
    WHERE ss.Stdname = @StName AND s.ExId = @ExId

    RETURN @Total
END
GO

--test
SELECT dbo.fn_StudentTotalScore('Sara Ibrahim',1) AS Sara_Total -- Should return 100
SELECT dbo.fn_StudentTotalScore('Omar Khaled',1) AS Omar_Total -- Should return 0
SELECT dbo.fn_StudentTotalScore('Nour Hany',1) AS Nour_Total

 






-- Function 3: fn_GetExamStatus

CREATE FUNCTION fn_GetExamStatus
(
    @ExName NVARCHAR(50)
)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Status NVARCHAR(20)
    DECLARE @StartTime DATETIME
    DECLARE @EndTime DATETIME

    SELECT 
        @StartTime = CAST(Ex_date AS DATETIME) + CAST(StartTime AS DATETIME),
        @EndTime   = CAST(Ex_date AS DATETIME) + CAST(EndTime AS DATETIME)
    FROM Exam
    WHERE @ExName = @ExName

    IF GETDATE() < @StartTime
        SET @Status = 'Upcoming'
    ELSE IF GETDATE() BETWEEN @StartTime AND @EndTime
        SET @Status = 'Ongoing'
    ELSE
        SET @Status = 'Completed'

    RETURN @Status
END
GO

--test
SELECT dbo.fn_GetExamStatus('Database') AS Exam1_Status






--- Function 4: fn_CalculateAge student based on birthdate

CREATE or alter FUNCTION fn_CalculateAge
(
    @Birthday DATE
)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @Birthday, GETDATE()) 
           - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @Birthday, GETDATE()), @Birthday) > GETDATE() 
                  THEN 1 ELSE 0 END
END
GO

-- test
SELECT Stdname, dbo.fn_CalculateAge(Birthday) AS Age
FROM Student









-- Function 5 : fn_CourseFinalResult calc final student result in course

CREATE OR ALTER FUNCTION fn_CourseFinalResult
(
    @StdName nvarchar(50),
    @CrsName nvarchar(50)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @FinalResult DECIMAL(18,2)

    SELECT @FinalResult = SUM(ISNULL(se.Obtained_degree,0))
    FROM StuExam se
    JOIN Exam e ON se.ExId = e.ExId
	JOIN Course c ON e.CrsId = c.CrsId
	JOIN Student s ON se.StdId = s.StdId
    WHERE s.Stdname = @StdName
      AND c.Crs_name = @CrsName

    RETURN ISNULL(@FinalResult,0)
END
GO


-- test
SELECT dbo.fn_CourseFinalResult('Sara Ibrahim','SQL Server') AS Sara_Final;
SELECT dbo.fn_CourseFinalResult('Omar Khaled','SQL Server') AS Omar_Final;
SELECT dbo.fn_CourseFinalResult('Nour Hany','SQL Server') AS Nour_Final;





-- Function 6 : fn_IsStudentPassedCourse Check student state about course

CREATE FUNCTION fn_IsStudentPassedCourse
(
    @StdName NVARCHAR(100),
    @CrsName NVARCHAR(100)
)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2)
    DECLARE @MinDegree INT

    -- Get final result using existing function
    SET @Result = dbo.fn_CourseFinalResult(@StdName, @CrsName)

    -- Get minimum degree for course
    SELECT @MinDegree = Mindegree
    FROM Course
    WHERE Crs_name = @CrsName

    -- If course not found return NULL
    IF @MinDegree IS NULL
        RETURN NULL

    IF @Result >= @MinDegree
        RETURN 'Passed'

    RETURN 'Failed'
END
GO

--test
SELECT dbo.fn_IsStudentPassedCourse('Sara Ibrahim','SQL Server') AS Sara_Status;
SELECT dbo.fn_IsStudentPassedCourse('Omar Khaled','SQL Server') AS Omar_Status;








-- Function 7 : fn_GetStudentRankInExam get student rank

CREATE or alter FUNCTION fn_GetStudentRankInExam
(
    @StdName NVARCHAR(100),
    @CrsName NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @Rank INT

    SELECT @Rank = Rnk
    FROM (
        SELECT s.Stdname,
               ROW_NUMBER() OVER (ORDER BY se.Obtained_degree DESC) AS Rnk
        FROM StuExam se
        JOIN Student s ON se.StdId = s.StdId
        JOIN Exam e ON se.ExId = e.ExId
        JOIN Course c ON e.CrsId = c.CrsId
        WHERE c.Crs_name = @CrsName
    ) t
    WHERE Stdname = @StdName

    RETURN @Rank
END
GO

--test
SELECT dbo.fn_GetStudentRankInExam('Sara Ibrahim','SQL Server') AS Sara_Rank;

SELECT dbo.fn_GetStudentRankInExam('Omer Khaled','SQL Server') AS Sara_Rank;






-- Function 8 : fn_IsExamTimeValid insure that student can enter exam in time allowed

CREATE FUNCTION fn_IsExamTimeValid
(
    @ExName nvarchar
)
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @Start DATETIME
    DECLARE @End DATETIME

    SELECT 
        @Start = CAST(Ex_date AS DATETIME) + CAST(StartTime AS DATETIME),
        @End   = CAST(Ex_date AS DATETIME) + CAST(EndTime AS DATETIME)
    FROM Exam
    WHERE ExName = @ExName

    IF GETDATE() BETWEEN @Start AND @End
        RETURN 'Go To Exam'

    RETURN 'Timed Out'
END
GO

--test
SELECT dbo.fn_IsExamTimeValid('DataBase')
