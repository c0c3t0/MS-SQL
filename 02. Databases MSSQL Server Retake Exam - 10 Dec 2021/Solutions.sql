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




