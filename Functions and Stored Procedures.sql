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




