CREATE DATABASE ColonialJourney;
GO

USE ColonialJourney;
GO

CREATE TABLE Planets(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(30) NOT NULL 
	);
	
CREATE TABLE Spaceports(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	, PlanetId int NOT NULL FOREIGN KEY REFERENCES Planets(Id)
	);
	
CREATE TABLE Spaceships(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	, Manufacturer varchar(30) NOT NULL
	, LightSpeedRate int DEFAULT 0
	);
	
CREATE TABLE Colonists(
	Id int PRIMARY KEY IDENTITY
	, FirstName varchar(20) NOT NULL 
	, LastName varchar(20) NOT NULL 
	, Ucn varchar(10) UNIQUE NOT NULL
	, BirthDate date NOT NULL
	);
	
CREATE TABLE Journeys(
	Id int PRIMARY KEY IDENTITY
	, JourneyStart datetime NOT NULL
	, JourneyEnd datetime NOT NULL
	, Purpose varchar(11) CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military'))
	, DestinationSpaceportId int NOT NULL FOREIGN KEY REFERENCES Spaceports(Id)
	, SpaceshipId int NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
	);
	
CREATE TABLE TravelCards(
	Id int PRIMARY KEY IDENTITY
	, CardNumber char(10) UNIQUE NOT NULL
	, JobDuringJourney varchar(8) CHECK(JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'))
	, ColonistId int NOT NULL FOREIGN KEY REFERENCES Colonists(Id)
	, JourneyId int NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
	);

--02. Insert
INSERT INTO Planets(Name) VALUES 
	('Mars')
	, ('Earth')
	, ('Jupiter')
	, ('Saturn');
	
INSERT INTO Spaceships(Name, Manufacturer, LightSpeedRate) VALUES
	('Golf', 'VW', 3)
	, ('WakaWaka', 'Wakanda', 4)
	, ('Falcon9', 'SpaceX', 1)
	, ('Bed', 'Vidolov', 6);


--03.Update
UPDATE
	Spaceships
SET
	LightSpeedRate = 1
WHERE
	Id BETWEEN 8 AND 12;


--04. Delete
DELETE
FROM
	TravelCards
WHERE
	JourneyId IN (1, 2, 3);

DELETE
FROM
	Journeys
WHERE
	Id IN (1, 2, 3);



--05. Select all millitary journeys
SELECT
	j.Id
	, FORMAT(JourneyStart
	, 'dd/MM/yyyy') AS JourneyStart
	, FORMAT(JourneyEnd
	, 'dd/MM/yyyy') AS JourneyEnd
FROM
	Journeys j
WHERE
	Purpose = 'Military'
ORDER BY
	JourneyStart;



--06. Select all pilots
SELECT
	c.Id
	, CONCAT(c.FirstName, ' ', c.LastName) AS FullName
FROM
	Colonists c
JOIN TravelCards tc ON
	c.Id = tc.ColonistId
WHERE
	tc.JobDuringJourney = 'Pilot'
ORDER BY
	c.Id;


--07. Count colonists
SELECT
	COUNT(*) AS [Count]
FROM
	Colonists c
JOIN TravelCards tc ON
	tc.ColonistId = c.Id
JOIN Journeys j ON
	j.Id = tc.JourneyId
WHERE
	j.Purpose = 'Technical';



--08. Select spaceships with pilots younger than 30 years
SELECT
	s.Name
	, s.Manufacturer
FROM
	Spaceships s
JOIN Journeys j ON
	j.SpaceshipId = s.Id
JOIN TravelCards tc ON
	tc.JourneyId = j.Id
JOIN Colonists c ON
	c.Id = tc.ColonistId
WHERE
	DATEDIFF(YEAR, c.BirthDate, '2019') < 30
ORDER BY
	s.Name;


--09. Select all planets and their journey count
SELECT
	p.Name
	, COUNT(*) AS JourneysCount
FROM
	Planets p
JOIN Spaceports s ON
	p.Id = s.PlanetId
JOIN Journeys j ON
	j.DestinationSpaceportId = s.Id
GROUP BY
	p.Id
	, p.Name
ORDER BY
	JourneysCount DESC
	, p.Name;



--10. Select Second Oldest Important Colonist
SELECT
	*
FROM
	(
	SELECT
		tc.JobDuringJourney
		, CONCAT(c.FirstName, ' ', c.LastName) AS FullName
		, DENSE_RANK() OVER (PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [Rank]
	FROM
		Colonists c
	JOIN TravelCards tc ON
		tc.ColonistId = c.Id
	JOIN Journeys j ON
		j.Id = tc.JourneyId) AS r
WHERE
	r.[Rank] = 2;


--11. Get Colonists Count
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR(30))
RETURNS int
AS
BEGIN
	RETURN (
		SELECT
			COUNT(*) AS [Count]
		FROM
			Planets p
		JOIN Spaceports s ON
			p.Id = s.PlanetId
		JOIN Journeys j ON
			s.Id = j.DestinationSpaceportId
		JOIN TravelCards tc ON
			j.Id = tc.JourneyId
		JOIN Colonists c ON
			tc.ColonistId = c.Id
		WHERE p.Name = @PlanetName) 
END

SELECT dbo.udf_GetColonistsCount('Otroyphus');


--12. Change Journey Purpose
CREATE OR ALTER PROC usp_ChangeJourneyPurpose(@JourneyId int, @NewPurpose varchar(30))
AS
BEGIN
	IF @JourneyId NOT IN (
		SELECT
			j.Id
		FROM
			Journeys j)
		THROW 50001, 'The journey does not exist!', 1;
	IF @NewPurpose = (
		SELECT
			j.Purpose
		FROM
			Journeys j
		WHERE
			j.Id = @JourneyId)
		THROW 50002, 'You cannot change the purpose!', 1;
	UPDATE
		Journeys
	SET
		Purpose = @NewPurpose
	WHERE
		Id = @JourneyId;
END

EXEC usp_ChangeJourneyPurpose 4, 'Technical';

EXEC usp_ChangeJourneyPurpose 2, 'Educational';

EXEC usp_ChangeJourneyPurpose 196, 'Technical';


