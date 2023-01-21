-- ==[Part I – Queries for SoftUni Database]== --
USE SoftUni;


-- 1. Find Names of All Employees by First Name
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	FirstName LIKE 'Sa%';


-- 2. Find Names of All Employees by Last Name 
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	LastName LIKE '%ei%';
	

-- 3. Find First Names of All Employees
SELECT
	FirstName
FROM
	Employees
WHERE
	DepartmentID IN (3, 10)
	AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005;
	
	
-- 4. Find All Employees Except Engineers
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	JobTitle NOT LIKE '%engineer%';


-- 5. Find Towns with Name Length
SELECT
	[Name]
FROM
	Towns
	WHERE LEN([Name]) IN (5, 6)
ORDER BY
	[Name];


-- 6. Find Towns Starting With
SELECT
	TownID
	,[Name]
FROM
	Towns
	WHERE LEFT([Name], 1) LIKE '[MKBE]'
ORDER BY
	[Name];


-- 7. Find Towns Not Starting With
SELECT
	TownID
	,[Name]
FROM
	Towns
	WHERE LEFT([Name], 1) LIKE '[^RBD]'
ORDER BY
	[Name];


-- 8. Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 AS 
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	DATEPART(YEAR, HireDate) > 2000;

SELECT
	*
FROM
	V_EmployeesHiredAfter2000;


-- 9. Length of Last Name
SELECT
	FirstName
	, LastName
FROM
	Employees
WHERE
	LEN(LastName) = 5;


-- 10. Rank Employees by Salary
SELECT * FROM (SELECT
	EmployeeID
	, FirstName
	, LastName
	, Salary
	, DENSE_RANK() OVER(PARTITION BY Salary
ORDER BY
	EmployeeID) AS [Rank]
FROM
	Employees
WHERE
	Salary BETWEEN 10000 AND 50000
ORDER BY
	Salary DESC) AS DenseRankSelection
	WHERE [Rank] = 2


-- 11. Find All Employees with Rank 2
SELECT
	*
FROM
	(
	SELECT
		EmployeeID
		, FirstName
		, LastName
		, Salary
		, DENSE_RANK() OVER(PARTITION BY Salary
	ORDER BY
		EmployeeID) AS [Rank]
	FROM
		Employees
	WHERE
		Salary BETWEEN 10000 AND 50000
	) AS DenseRankSelection
WHERE
	[Rank] = 2
ORDER BY
		Salary DESC;
	
	
-- == [Part II – Queries for Geography Database]== --
USE Geography;


-- 12. Countries Holding 'A' 3 or More Times
SELECT
	CountryName AS [Country Name]
	, IsoCode AS [ISO Code]
FROM
	Countries
WHERE
	CountryName LIKE '%a%a%a%'
ORDER BY
	IsoCode;


-- 13.  Mix of Peak and River Names
SELECT
	p.PeakName
	, r.RiverName
	, LOWER(CONCAT(LEFT(p.PeakName, LEN(p.PeakName)-1), r.RiverName)) AS Mix
FROM
	Peaks AS p
JOIN Rivers AS r ON RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix;

SELECT Peaks.PeakName,
       Rivers.RiverName,
       LOWER(CONCAT(LEFT(Peaks.PeakName, LEN(Peaks.PeakName)-1), Rivers.RiverName)) AS Mix
FROM Peaks
     JOIN Rivers ON RIGHT(Peaks.PeakName, 1) = LEFT(Rivers.RiverName, 1)
ORDER BY Mix;


-- ==[Part III – Queries for Diablo Database]== --
USE Diablo;


-- 14. Games from 2011 and 2012 Year
SELECT
	TOP(50) [Name]
	, FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM
	Games
WHERE
	DATEPART(YEAR, [Start]) IN (2011, 2012)
ORDER BY
	[Start]
	, [Name];


-- 15. User Email Providers
SELECT
	Username AS [Name]
	, RIGHT(Email
	, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
FROM
	Users
ORDER BY
	[Email Provider]
	, Username;


-- 16. Get Users with IP Address Like Pattern
SELECT
	Username
	, IpAddress AS [IP Address]
FROM
	Users
WHERE
	IpAddress LIKE '___.1%.%.___'
ORDER BY
	Username;


-- 17. Show All Games with Duration and Part of the Day
SELECT
	Name AS Game
	, CASE
		WHEN DATEPART(HOUR, [Start]) <= 11 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) <= 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS [Part of the Day]
	, CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration <= 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		ELSE 'Extra Long'
	END AS Duration
FROM
	Games
ORDER BY
	Game
	, Duration
	, [Part of the Day];


-- == [Part IV – Date Functions Queries] == --

-- 18. Orders Table
USE Orders;

SELECT
	ProductName
	, OrderDate
	, DATEADD(DAY, 3, OrderDate) AS [Pay Date]
	, DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM
	Orders;


-- 19. People Table












	