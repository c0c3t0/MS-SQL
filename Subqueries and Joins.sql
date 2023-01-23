-- == [Part I – Queries for SoftUni Database] == --
USE SoftUni;


-- 1. Employee Address
SELECT
	TOP 5
	e.EmployeeId
	, e.JobTitle
	, e.AddressId
	, a.AddressText
FROM
	Employees AS e
JOIN Addresses AS a ON
	e.AddressID = a.AddressID
ORDER BY e.AddressID;


-- 2. Addresses with Towns
SELECT
	TOP 50
	e.FirstName
	, e.LastName
	, t.Name AS Town
	, a.AddressText
FROM
	Employees AS e
JOIN Addresses AS a ON
	e.AddressID = a.AddressID
JOIN Towns AS t ON
	a.TownID = t.TownID
ORDER BY
	e.FirstName
	, e.LastName;
	
	
-- 3. Sales Employee
SELECT
	e.EmployeeID
	, e.FirstName
	, e.LastName
	, d.Name AS DepartmentName
FROM
	Employees AS e
JOIN Departments AS d ON
	d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY
	e.EmployeeID;
	
	
-- 4. Employee Departments
SELECT
	TOP (5)
	e.EmployeeID
	, e.FirstName
	, e.Salary
	, d.Name AS DepartmentName
FROM
	Employees AS e
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
WHERE
	e.Salary > 15000
ORDER BY
	d.DepartmentID;

	
-- 5. Employees Without Project
SELECT
	TOP (3) e.EmployeeID
	, e.FirstName
FROM
	Employees AS e
LEFT JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
WHERE
	ep.ProjectID IS NULL;


-- 6. Employees Hired After
SELECT
	e.FirstName
	, e.LastName
	, e.HireDate
	, d.Name AS DeptName
FROM
	Employees AS e
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
WHERE
	DATEPART(YEAR, e.HireDate) > 1999
	AND d.Name IN ('Sales', 'Finance');
	

-- 7. Employees with Project
SELECT TOP (5)
	e.EmployeeID
	, e.FirstName
	, p.Name AS ProjectName
FROM
	Employees AS e
JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON
	ep.ProjectID = p.ProjectID
WHERE
	p.StartDate > '2002-08-13'
	AND p.EndDate IS NULL
ORDER BY
	e.EmployeeID;
	

-- 8. Employee 24
SELECT TOP (5)
	e.EmployeeID
	, e.FirstName
	, CASE WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL ELSE p.Name END AS ProjectName
FROM
	Employees AS e
JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON
	ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24; 


-- 9. Employee Manager
SELECT
	e.EmployeeID
	, e.FirstName
	, e.ManagerID
	, m.FirstName
FROM
	Employees AS e
JOIN Employees AS m ON
	m.EmployeeID = e.ManagerID
WHERE
	e.ManagerID IN (3, 7)
ORDER BY
	e.EmployeeID;


-- 10. Employees Summary
SELECT
	TOP (50)
	e.EmployeeID
	, CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName
	, CONCAT(m.FirstName, ' ', M.LastName) AS ManagerName
	, d.Name AS DepartmentName
FROM
	Employees AS e
JOIN Employees AS m ON
	m.EmployeeID = e.ManagerID
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
ORDER BY
	e.EmployeeID;



-- 11. Min Average Salary
SELECT
	TOP (1) AVG(e.Salary) AS MinAverageSalary
FROM
	Employees AS e
GROUP BY
	e.DepartmentID
ORDER BY
	MinAverageSalary;


-- == [Part II – Queries for Geography Database] == --
USE Geography;

-- 12. Highest Peaks in Bulgaria
SELECT
	mc.CountryCode
	, m.MountainRange
	, p.PeakName
	, p.Elevation
FROM
	MountainsCountries AS mc
JOIN Mountains AS m ON
	mc.MountainId = m.Id
JOIN Peaks p ON
	m.Id = p.MountainId
WHERE
	mc.CountryCode = 'BG'
	AND
	p.Elevation > 2835
ORDER BY
	p.Elevation DESC;


-- 13. Count Mountain Ranges
SELECT
	mc.CountryCode
	, COUNT(mc.CountryCode) AS MountainRange
FROM
	MountainsCountries AS mc
JOIN Mountains AS m ON
	mc.MountainId = m.Id
WHERE
	mc.CountryCode IN ('BG', 'RU', 'US')
GROUP BY
	mc.CountryCode;
	

--14. Countries With or Without Rivers
SELECT
	TOP 5 c.CountryName
	, r.RiverName
FROM
	Countries AS c
JOIN Continents AS c2 ON
	c.ContinentCode = c2.ContinentCode
LEFT JOIN CountriesRivers AS cr ON
	c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON
	cr.RiverId = r.Id
WHERE
	c2.ContinentName = 'Africa'
ORDER BY
	c.CountryName;



--15. *Continents and Currencies
SELECT
	ranked.ContinentCode
	, ranked.CurrencyCode
	, ranked.CurrencyUsage
FROM
	(
	SELECT
		ContinentCurrences.ContinentCode
		, ContinentCurrences.CurrencyCode
		, ContinentCurrences.CurrencyUsage
		, DENSE_RANK() OVER(PARTITION BY ContinentCurrences.ContinentCode
	ORDER BY
		ContinentCurrences.CurrencyUsage DESC) AS [Usage]
	FROM
		(
		SELECT
			ContinentCode
			, CurrencyCode
			, COUNT(CurrencyCode) AS CurrencyUsage
		FROM
			Countries
		GROUP BY
			ContinentCode
			, CurrencyCode
		HAVING
			COUNT(CurrencyCode) > 1
		) AS ContinentCurrences
	) AS ranked
WHERE
	ranked.[Usage] = 1
ORDER BY
	ranked.ContinentCode; 


--16. Countries Without any Mountains
SELECT
	COUNT(c.CountryCode)
--		c.CountryCode
--		, MC.MountainId
FROM
	Countries AS c
LEFT JOIN MountainsCountries AS mc ON
	mc.CountryCode = c.CountryCode
WHERE
	mc.MountainId IS NULL;


-- 17. Highest Peak and Longest River by Country
SELECT
	TOP (5)
	c.CountryName
	, MAX(p.Elevation) AS HighestPeakElevation
	, MAX(r.[Length]) AS LongestRiverLength
FROM
	Countries AS c
JOIN MountainsCountries AS mc ON
		mc.CountryCode = c.CountryCode
JOIN Peaks AS p ON
		p.MountainId = mc.MountainId
JOIN CountriesRivers AS cr ON
	cr.CountryCode = c.CountryCode
JOIN Rivers AS r ON
	r.Id = cr.RiverId
GROUP BY
	c.CountryName
ORDER BY
	HighestPeakElevation DESC
	, LongestRiverLength DESC
	, c.CountryName;

		
-- 18. *Highest Peak Name and Elevation by Country
WITH PeaksMountains_CTE (Country
, PeakName
, PeakElevation
, Mountain) AS 
(
SELECT
	c.CountryName
	, p.PeakName
	, p.Elevation
	, m.MountainRange
FROM
	Countries AS c
LEFT JOIN MountainsCountries AS mc ON
		mc.CountryCode = c.CountryCode
LEFT JOIN Peaks AS p ON
		p.MountainId = mc.MountainId
LEFT JOIN Mountains AS m ON
	m.Id = mc.MountainId
)
SELECT
	TOP 5
	highest.Country AS Country
	, COALESCE(pm.PeakName, '(no highest peak)') AS [Highest Peak Name]
	, COALESCE(highest.maxE, 0) AS [Highest Peak Elevation]
	, COALESCE(pm.Mountain, '(no mountain)') AS Mountain
FROM
	(
	SELECT
		Country
		, MAX(PeakElevation) AS maxE
	FROM
		PeaksMountains_CTE
	GROUP BY
		Country
	) AS highest
LEFT JOIN PeaksMountains_CTE AS pm 
ON
	(highest.Country = pm.Country
		AND highest.maxE = pm.PeakElevation)
ORDER BY
	Country
	, PeakName;



WITH PeaksMountains_CTE (Country, PeakName, Elevation, Mountain) AS (

  SELECT c.CountryName, p.PeakName, p.Elevation, m.MountainRange
  FROM Countries AS c
  LEFT JOIN MountainsCountries as mc ON c.CountryCode = mc.CountryCode
  LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
  LEFT JOIN Peaks AS p ON p.MountainId = m.Id
)

SELECT TOP 5
  TopElevations.Country AS Country,
  ISNULL(pm.PeakName, '(no highest peak)') AS HighestPeakName,
  ISNULL(TopElevations.HighestElevation, 0) AS HighestPeakElevation,	
  ISNULL(pm.Mountain, '(no mountain)') AS Mountain
FROM 
  (SELECT Country, MAX(Elevation) AS HighestElevation
   FROM PeaksMountains_CTE 
   GROUP BY Country) AS TopElevations
LEFT JOIN PeaksMountains_CTE AS pm 
ON (TopElevations.Country = pm.Country AND TopElevations.HighestElevation = pm.Elevation)
ORDER BY Country, HighestPeakName 
--ORDER BY c.CountryName, [Highest Peak Name]


















