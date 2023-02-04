-- ***[Database Basics MS SQL Retake Exam – 10 Dec 2021]*** --

-- === [Section 1. DDL (30 pts)] === --
CREATE DATABASE Airport;
GO

USE Airport;
GO 

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY
	, FullName VARCHAR(100) UNIQUE NOT NULL
	, Email VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Pilots(
	Id INT PRIMARY KEY IDENTITY
	, FirstName VARCHAR(30) UNIQUE NOT NULL
	, LastName VARCHAR(30) UNIQUE NOT NULL
	, Age TINYINT CHECK(Age BETWEEN 21 AND 62) NOT NULL
	, Rating FLOAT CHECK(Rating BETWEEN 0.0 AND 10.0)
);

CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY
	, TypeName VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY
	, Manufacturer VARCHAR(25) NOT NULL
	, Model VARCHAR(30) NOT NULL
	, [Year] INT NOT NULL
	, FlightHours INT
	, [Condition] CHAR(1) NOT NULL
	, TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
);

CREATE TABLE PilotsAircraft(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL 
	, PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL 
	PRIMARY KEY (AircraftId, PilotId)
);

CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY
	, AirportName VARCHAR(70) UNIQUE NOT NULL
	, Country VARCHAR(100) UNIQUE NOT NULL 
);

CREATE TABLE FlightDestinations(
	Id INT PRIMARY KEY IDENTITY
	, AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL
	, [Start] DATETIME NOT NULL
	, AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL
	, PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
	, TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL 
);



-- === [Section 2. DML (10 pts)] === --

--02.Insert
INSERT
	INTO
	Passengers
SELECT
	CONCAT(p.FirstName, ' ', p.LastName) AS FullName
	, CONCAT(p.FirstName, p.LastName, '@gmail.com') AS Email
FROM
	Pilots AS p
WHERE
	p.Id BETWEEN 5 AND 15;


--03. Update
UPDATE
	Aircraft
SET
	[Condition] = 'A'
WHERE
	[Condition] IN ('C', 'B')
	AND (FlightHours IS NULL
		OR FlightHours <= 100)
	AND [Year] >= 2013;


--04. Delete
DELETE
FROM
	Passengers
WHERE
	LEN(FullName) <= 10;


-- === [Section 3. Querying (40 pts)] === --
USE Airport;

--05. Aircraft
SELECT
	Manufacturer
	, Model
	, FlightHours
	, [Condition]
FROM
	Aircraft
ORDER BY
	FlightHours DESC;


--06. Pilots and Aircraft
SELECT
	p.FirstName
	, p.LastName
	, a.Manufacturer
	, a.Model
	, a.FlightHours
FROM
	Pilots p
JOIN PilotsAircraft pa ON
	p.Id = pa.PilotId
JOIN Aircraft a ON
	pa.AircraftId = a.Id
WHERE
	a.FlightHours < 304
ORDER BY
	a.FlightHours DESC
	, p.FirstName;


--07. Top 20 Flight Destinations
SELECT
	TOP 20 fd.Id
	, fd.[Start]
	, p.FullName
	, a.AirportName
	, fd.TicketPrice
FROM
	FlightDestinations fd
JOIN Passengers p ON
	fd.PassengerId = p.Id
JOIN Airports a ON
	fd.AirportId = a.Id
WHERE
	DAY(fd.[Start]) % 2 = 0
ORDER BY
	fd.TicketPrice DESC
	, a.AirportName;



--08. Number of Flights for Each Aircraft
SELECT
	fd.AircraftId
	, a.Manufacturer
	, a.FlightHours
	, fd.FlightDestinationsCount
	, fd.AvgPrice
FROM
	(
	SELECT
		fd.AircraftId
		, COUNT(*) AS FlightDestinationsCount
		, ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
	FROM
		FlightDestinations fd
	GROUP BY
		AircraftId
	HAVING
		COUNT(*)>1) AS fd
JOIN Aircraft a ON
	fd.AircraftId = a.Id
ORDER BY 
	fd.FlightDestinationsCount DESC
	, fd.AircraftId;



--09. Regular Passengers
SELECT
	p.FullName
	, fd.CountOfAircraft
	, fd.TotalPayed
FROM
	(
	SELECT
		COUNT(*) AS CountOfAircraft
		, fd.PassengerId
		, SUM(fd.TicketPrice) AS TotalPayed
	FROM
		FlightDestinations fd
	GROUP BY
		PassengerId
	HAVING
		COUNT(*) >= 2) AS fd
JOIN Passengers p ON
	p.Id = fd.PassengerId
WHERE
	p.FullName LIKE '_a%'
ORDER BY p.FullName;



--10. Full Info for Flight Destinations
SELECT
	a.AirportName
	, fd.[Start] AS DayTime
	, fd.TicketPrice
	, p.FullName
	, ac.Manufacturer
	, ac.Model
FROM
	FlightDestinations fd
JOIN Airports a ON
	fd.AirportId = a.Id
JOIN Passengers p ON
	fd.PassengerId = p.Id
JOIN Aircraft ac ON
	fd.AircraftId = ac.Id
WHERE
	(DATEPART(HOUR, [Start]) BETWEEN 6 AND 20)
	AND TicketPrice > 2500
ORDER BY
	ac.Model;

-- == [Section 4. Programmability (20 pts)] == --

--11. Find all Destinations by Email Address
CREATE FUNCTION udf_FlightDestinationsByEmail(@email varchar(50))
RETURNs INT
AS
BEGIN
	DECLARE @result int = (
	SELECT
		COUNT(*)
	FROM
		FlightDestinations AS fd
	JOIN Passengers p ON p.Id = fd.PassengerId
	WHERE p.Email = @email)
	RETURN @result
END

SELECT dbo.udf_FlightDestinationsByEmail ('PierretteDunmuir@gmail.com')

SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com')

SELECT dbo.udf_FlightDestinationsByEmail('MerisShale@gmail.com')


--12. Full Info for Airports
CREATE OR ALTER PROC usp_SearchByAirportName(@airportName varchar(70))
AS
BEGIN
	SELECT
	a.AirportName
	, p.FullName
	, CASE 
		WHEN fd.TicketPrice <= 400 THEN 'Low'
		WHEN fd.TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
		WHEN fd.TicketPrice>1500 THEN 'High'
	END
	, ac.Manufacturer
	, ac.[Condition]
	, airt.TypeName
FROM
	FlightDestinations fd
JOIN Airports a ON
	a.Id = fd.AirportId
JOIN Passengers p ON
	p.Id = fd.PassengerId
JOIN Aircraft ac ON
	ac.Id = fd.AircraftId
JOIN AircraftTypes airt ON
	airt.Id = ac.TypeId
WHERE
	a.AirportName = @airportName
ORDER BY
	ac.Manufacturer
	, p.FullName
END

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'
