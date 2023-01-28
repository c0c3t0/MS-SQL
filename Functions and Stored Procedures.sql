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
	ELSE SET @SalaryLevel = 'High';
	RETURN @SalaryLevel;
END

SELECT
	Salary
	, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
FROM
	Employees;







