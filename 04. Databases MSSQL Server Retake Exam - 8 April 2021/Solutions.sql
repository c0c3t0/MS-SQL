-- == ***[Database Basics MS SQL Exam – 8 April 2021]*** == --


-- == [Section 1. DDL (30 pts)] == --

--01. DDL
CREATE DATABASE Service;
GO

USE Service;
GO

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY
	, Username VARCHAR(30) UNIQUE NOT NULL
	, Password VARCHAR(50) NOT NULL
	, Name VARCHAR(50)
	, Birthdate DATETIME 
	, Age INT CHECK(Age BETWEEN 14 AND 110)
	, Email VARCHAR(50) NOT NULL
);

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) NOT NULL
);

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY
	, FirstName VARCHAR(25)
	, LastName VARCHAR(25)
	, Birthdate DATETIME 
	, Age INT CHECK(Age BETWEEN 18 AND 110)
	, DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)	
);

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) NOT NULL
	, DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
);

CREATE TABLE Status(
	Id INT PRIMARY KEY IDENTITY
	, Label VARCHAR(30) NOT NULL
	);


CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY
	, CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	, StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL
	, OpenDate DATETIME NOT NULL
	, CloseDate DATETIME
	, Description VARCHAR(200) NOT NULL
	, UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
	, EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	);

-- == [Section 2. DML (10 pts)] == --

--02. Insert
INSERT INTO Employees(FirstName, LastName, Birthdate, DepartmentId) VALUES
	('Marlo', 'O''Malley', '1958-9-21', 1)
	, ('Niki', 'Stanaghan', '1969-11-26', 4)
	, ('Ayrton', 'Senna', '1960-03-21', 9)
	, ('Ronnie', 'Peterson', '1944-02-14', 9)
	, ('Giovanna', 'Amati', '1959-07-20', 5);

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId) VALUES
	(1,1,'2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2)
	, (6,3, '2015-09-05', '2015-12-06', 'Charity trail running',3,5)
	, (14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2)
	, (4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1);



--03. Update
UPDATE
	Reports
SET
	CloseDate = GETDATE()
WHERE
	CloseDate IS NULL;


--04. Delete
DELETE
FROM
	Reports
WHERE
	StatusId = 4;


-- == [Section 3. Querying (40 pts)] == --


--05. Unassigned Reports
SELECT
	Description
	, FORMAT(OpenDate
	, 'dd-MM-yyyy') AS OpenDate
FROM
	Reports r
WHERE
	EmployeeId IS NULL
ORDER BY
	FORMAT(OpenDate, 'yyyy-MM-dd')
	, Description;


--06. Reports & Categories
SELECT
	r.Description
	, c.Name AS CategoryName
FROM
	Reports r
JOIN Categories c ON
	c.Id = r.CategoryId
WHERE
	r.CategoryId IS NOT NULL
ORDER BY
	r.Description
	, c.Name;



--07. Most Reported Category
SELECT
	TOP 5
	c.Name AS CategoryName
	, rn.ReportsNumber
FROM
	(
	SELECT
		COUNT(*) AS ReportsNumber
		, CategoryId
	FROM
		Reports r
	GROUP BY
		CategoryId) AS rn
JOIN Categories c ON
	c.Id = rn.CategoryId
ORDER BY
	rn.ReportsNumber DESC
	, c.Name;


--08. Birthday Report
SELECT
	u.Username
	, c.Name AS CategoryName
FROM
	Users u
JOIN Reports r ON
	r.UserId = u.Id
JOIN Categories c ON
	c.Id = r.CategoryId
WHERE
	MONTH(u.Birthdate) = MONTH(r.OpenDate)
	AND DAY(u.Birthdate) = DAY(r.OpenDate)
ORDER BY
	u.Username
	, c.Name;



--09. Users per Employee
SELECT
	CONCAT(e.FirstName, ' ', e.LastName) AS FullName
	, CASE
		WHEN uc.UserCount IS NOT NULL THEN uc.UserCount
		WHEN uc.UserCount IS NULL THEN 0
	END
FROM
	(
	SELECT
		count(*) AS UserCount
		, EmployeeId
	FROM
		Reports r
	GROUP BY
		EmployeeId) AS uc
RIGHT JOIN Employees e ON
	e.Id = uc.EmployeeId
ORDER BY
	uc.UserCount DESC
	, FullName;



--10. Full Info
SELECT
	CASE
		WHEN e.Id IS NULL THEN 'None'
		ELSE cONCAT(e.FirstName, ' ', e.LastName)
	END AS Employee
	, COALESCE(d.Name, 'None') AS Department
	, c.Name AS Category
	, r.Description
	, FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate
	, s.Label
	, u.Name
FROM
	Reports r
LEFT JOIN Employees e ON
	r.EmployeeId = e.Id
LEFT JOIN Departments d ON
	e.DepartmentId = d.Id
LEFT JOIN Categories c ON
	r.CategoryId = c.Id
LEFT JOIN Status s ON
	r.StatusId = s.Id
LEFT JOIN Users u ON
	r.UserId = u.Id
ORDER BY
	e.FirstName DESC
	, e.LastName DESC
	, d.Name
	, c.Name
	, r.Description
	, r.OpenDate
	, s.Label
	, u.Name;



-- === [Section 4. Programmability (20 pts)] === --

--11. Hours to Complete
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	IF @StartDate IS NULL OR @EndDate IS NULL
	RETURN 0
	ELSE DECLARE @result INT = DATEDIFF(HOUR, @StartDate, @EndDate)
	RETURN @result
END

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports



--12. Assign Employee
CREATE OR ALTER PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	DECLARE @employeeDepId int = (
		SELECT
			e.DepartmentId
		FROM
			Employees e
		WHERE
			e.Id = @EmployeeId)
	DECLARE @categoryDepId int = (
		SELECT
			c.DepartmentId
		FROM
			Reports r
		JOIN Categories c ON
			r.CategoryId = c.Id
		WHERE
			r.Id = @ReportId)
	IF @employeeDepId = @categoryDepId
		UPDATE Reports
		SET
			EmployeeId = @EmployeeId
		WHERE
			Id = @ReportId
	ELSE
		THROW 51000, 'Employee doesn''t belong to the appropriate department!', 1;
END

EXEC usp_AssignEmployeeToReport 30, 1

EXEC usp_AssignEmployeeToReport 17, 2

