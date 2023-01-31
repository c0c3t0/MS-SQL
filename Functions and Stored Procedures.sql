-- == [Part I – Queries for SoftUni Database] == --
USE SoftUni;

-- 1. Employees with Salary Above 35000
CREATE OR ALTER PROC usp_GetEmployeesSalaryAbove35000
AS
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	Salary > 35000;
GO

EXEC usp_GetEmployeesSalaryAbove35000;


--02. Employees with Salary Above Number
CREATE OR ALTER PROC usp_GetEmployeesSalaryAboveNumber(@searchedSalary DECIMAL(18, 4))
AS
SELECT
	FirstName
	, LastName
--	, Salary
FROM
	Employees
WHERE
	Salary >= @searchedSalary;
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100;


--03. Town Names Starting With
CREATE OR ALTER PROC usp_GetTownsStartingWith(@startingChar NVARCHAR(MAX))
AS
SELECT
	[Name] AS Town
FROM
	Towns
WHERE
	Name LIKE CONCAT(@startingChar, '%');
GO

EXEC usp_GetTownsStartingWith 'b';


--04. Employees from Town
CREATE OR ALTER PROC usp_GetEmployeesFromTown(@townName NVARCHAR(100))
AS
SELECT
	e.FirstName
	, e.LastName
FROM
	Employees AS e
JOIN Addresses AS a ON
	e.AddressID = a.AddressID
JOIN Towns AS t ON
	a.TownID = t.TownID
WHERE
	t.Name = @townName;


EXEC usp_GetEmployeesFromTown 'sofia';



--05. Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(20)
BEGIN
	DECLARE @SalaryLevel NVARCHAR(20)
	IF (@salary < 30000) SET @SalaryLevel = 'Low'
	ELSE IF (@salary BETWEEN 30000 and 50000) SET @SalaryLevel = 'Average'
	ELSE IF (@salary > 50000) SET @SalaryLevel = 'High';
	RETURN @SalaryLevel;
END

SELECT
	Salary
	, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
FROM
	Employees;



--06. Employees by Salary Level
CREATE OR ALTER PROC usp_EmployeesBySalaryLevel(@salaryLevel NVARCHAR(20))
AS
SELECT FirstName, LastName FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel;

EXEC usp_EmployeesBySalaryLevel 'high';


--07. Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX))
RETURNS BIT
BEGIN
	DECLARE @index SMALLINT = 1
	WHILE (@index <= LEN(@word))
	BEGIN
		DECLARE @currentChar NVARCHAR(2) = SUBSTRING(@word, @index, 1)
		IF CHARINDEX(@currentChar
		, @setOfLetters
		, 1) = 0
		RETURN 0
		ELSE
		SET
		@index += 1
	END
	RETURN 1
END

CREATE TABLE Test (setOfLetters NVARCHAR(MAX), word NVARCHAR(MAX));
GO

INSERT
	INTO
	Test
VALUES 
  ('oistmiahf', 'Sofia')
, ('oistmiahf', 'halves')
, ('bobr', 'Rob')
, ('pppp', 'Guy');
GO

SELECT setOfLetters, word,
  dbo.ufn_IsWordComprised(setOfLetters, word) AS [Result]
FROM Test




--08. *Delete Employees and Departments
CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS









--09. Find Full Name
CREATE OR ALTER PROC usp_GetHoldersFullName
AS
SELECT
	CONCAT(FirstName, ' ', LastName) AS [Full Name]
FROM
	AccountHolders;

EXEC usp_GetHoldersFullName;



--10. People with Balance Higher Than
CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan(@num MONEY)
AS
SELECT
	ah.FirstName AS [First Name]
	, ah.LastName AS [Last Name]
	--	, a.Balance
FROM
	AccountHolders AS ah
JOIN Accounts AS a ON
	ah.Id = a.AccountHolderId
GROUP BY
	ah.LastName
	, ah.FirstName
HAVING
	@num < SUM(a.Balance);


EXEC usp_GetHoldersWithBalanceHigherThan 75000;



--11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue(@sum MONEY
, @interestRate FLOAT
, @years INT)
RETURNS MONEY
AS
BEGIN
	RETURN @sum * (POWER(1 + @interestRate, @years))
END;



--12. Calculating Interest
CREATE OR ALTER PROC usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
DECLARE 
	@years INT = 5
SELECT
	ah.Id AS [Account Id]
	, ah.FirstName AS [First Name]
	, ah.LastName AS [Last Name]
	, a.Balance AS [Current Balance]
	, dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, @years) AS [Balance in 5 years]
FROM
	AccountHolders AS ah
JOIN Accounts AS a ON
	ah.Id = a.AccountHolderId
WHERE
	a.Id = @accountId;


EXEC usp_CalculateFutureValueForAccount 1, 0.1;



-- == [Part II – Queries for Diablo Database] == --
USE Diablo;


--13. *Cash in User Games Odd Rows
CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT
		SUM(ocbg.Cash) AS SumCash
	FROM
		(
		SELECT
			g.Name
			, ug.Cash
			, ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS rowNum
		FROM
			Games AS g
		JOIN UsersGames AS ug ON
			ug.GameId = g.Id
		WHERE
			Name = @gameName) AS ocbg
	WHERE
		ocbg.rowNum % 2 != 0);
	
SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist');


