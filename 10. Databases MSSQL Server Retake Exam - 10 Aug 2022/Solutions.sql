CREATE DATABASE NationalTouristSitesOfBulgaria;
GO

USE NationalTouristSitesOfBulgaria;
GO

CREATE TABLE Categories(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	);
	
CREATE TABLE Locations(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	, Municipality varchar(50)
	, Province varchar(50)
	);

CREATE TABLE Sites(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(100) NOT NULL 
	, LocationId int NOT NULL FOREIGN KEY REFERENCES Locations(Id)
	, CategoryId int NOT NULL FOREIGN KEY REFERENCES Categories(Id)
	, Establishment varchar(15)
	);

CREATE TABLE Tourists(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	, Age int CHECK(Age BETWEEN 0 AND 120) NOT NULL
	, PhoneNumber varchar(20) NOT NULL
	, Nationality varchar(30) NOT NULL
	, Reward varchar(20)
	);

CREATE TABLE SitesTourists(
	TouristId int NOT NULL FOREIGN KEY REFERENCES Tourists(Id)
	, SiteId int NOT NULL FOREIGN KEY REFERENCES Sites(Id)
	, PRIMARY KEY (TouristId, SiteId)
	);

CREATE TABLE BonusPrizes(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL 
	);

CREATE TABLE TouristsBonusPrizes(
	TouristId int NOT NULL FOREIGN KEY REFERENCES Tourists(Id)
	, BonusPrizeId int NOT NULL FOREIGN KEY REFERENCES BonusPrizes(Id)
	, PRIMARY KEY (TouristId, BonusPrizeId)
	);


--02. Insert
INSERT INTO Tourists(Name, Age, PhoneNumber, Nationality, Reward) VALUES
	('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL)
	, ('Peter Bosh', 48, '+447911844141', 'UK', NULL)
	, ('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge')
	, ('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge')
	, ('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL);
	
INSERT INTO Sites(Name, LocationId, CategoryId, Establishment) VALUES
	('Ustra fortress', 90, 7, 'X')
	, ('Karlanovo Pyramids', 65, 7, NULL)
	, ('The Tomb of Tsar Sevt', 63, 8, 'V BC')
	, ('Sinite Kamani Natural Park', 17, 1, NULL)
	, ('St. Petka of Bulgaria – Rupite', 92, 6, '1994');
	
	
--03. Update
UPDATE
	Sites
SET
	Establishment = 'not defined'
WHERE
	Establishment IS NULL;
	

--04. Delete
DELETE
FROM
	TouristsBonusPrizes
WHERE
	BonusPrizeId = (
	SELECT
		Id
	FROM
		BonusPrizes
	WHERE
		Name = 'Sleeping bag');
	
DELETE
FROM
	BonusPrizes
WHERE
	Name = 'Sleeping bag';
	

--05. Tourists
SELECT
	t.Name
	, t.Age
	, t.PhoneNumber
	, t.Nationality
FROM
	Tourists t
ORDER BY
	t.Nationality
	, t.Age DESC
	, t.Name;
	


--06. Sites with Their Location and Category
SELECT
	s.Name
	, l.Name
	, s.Establishment
	, c.Name
FROM
	Sites s
JOIN Locations l ON
	l.Id = s.LocationId
JOIN Categories c ON
	c.Id = s.CategoryId
ORDER BY
	c.Name DESC
	, l.Name
	, s.Name;


--07. Count of Sites in Sofia Province
SELECT
	l.Province
	, l.Municipality
	, l.Name AS Location
	, COUNT(*) AS CountOfSites
FROM
	Locations l
JOIN Sites s ON
	s.LocationId = l.Id
WHERE
	Province = 'Sofia'
GROUP BY
	l.Name, l.Province, l.Municipality
ORDER BY
	CountOfSites DESC
	, l.Name;


--08. Tourist Sites established BC
SELECT
	s.Name AS Site
	, l.Name AS Location
	, l.Municipality
	, l.Province
	, s.Establishment
FROM
	Sites s
JOIN Locations l ON
	s.LocationId = l.Id
WHERE
	SUBSTRING(l.Name, 1, 1) NOT IN ('B', 'M', 'D')
	AND s.Establishment LIKE '%BC'
ORDER BY
	s.Name;
	
	
	
--09. Tourists with their Bonus Prizes
SELECT
	t.Name
	, t.Age
	, t.PhoneNumber
	, t.Nationality
	, ISNULL(bp.Name
	, '(no bonus prize)') AS Reward
FROM
	Tourists t
LEFT JOIN TouristsBonusPrizes tb ON
	tb.TouristId = t.Id
LEFT JOIN BonusPrizes bp ON
	bp.Id = tb.BonusPrizeId
ORDER BY
	t.Name;
	

--10. Tourists visiting History & Archaeology sites
SELECT
	LTRIM(SUBSTRING(t.Name, CHARINDEX(' ', t.Name), LEN(t.Name))) AS LastName
	, t.Nationality
	, t.Age
	, t.PhoneNumber
FROM
	Tourists t
JOIN SitesTourists st ON
	t.Id = st.TouristId
JOIN Sites s ON
	st.SiteId = s.Id
JOIN Categories c ON
	s.CategoryId = c.Id
WHERE
	c.Name = 'History and archaeology'
GROUP BY
	t.Name
	, t.Nationality
	, t.Age
	, t.PhoneNumber
ORDER BY
	LastName;



--11. Tourists Count on a Tourist Site
CREATE OR ALTER FUNCTION udf_GetTouristsCountOnATouristSite (@Site varchar(30))
RETURNS int
AS
BEGIN
	RETURN (
		SELECT
			count(*)
		FROM
			Sites s
		JOIN SitesTourists st ON
			s.Id = st.SiteId
		WHERE
			s.Name = @Site)
END

						
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa');

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress');

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Gorge of Erma River');
			


--12. Annual Reward Lottery
CREATE OR ALTER PROC usp_AnnualRewardLottery(@TouristName nvarchar(50))
AS
BEGIN
	DECLARE 
		@siteCount int = (
			SELECT
				count(*)
			FROM
				Tourists t
			JOIN SitesTourists st ON
				t.Id = st.TouristId
			WHERE
				t.Name = @TouristName)
	IF @siteCount >= 100
		UPDATE Tourists
		SET Reward = 'Gold badge'
		WHERE Name = @TouristName
	ELSE IF @siteCount >= 50
		UPDATE Tourists
		SET Reward = 'Silver badge'
		WHERE Name = @TouristName
	ELSE IF @siteCount >= 25
		UPDATE Tourists
		SET Reward = 'Bronze badge'
		WHERE Name = @TouristName
	SELECT 
		t.Name
		, t.Reward
	FROM 
		Tourists t
	WHERE 
		t.Name = @TouristName
END

EXEC usp_AnnualRewardLottery 'Gerhild Lutgard';

EXEC usp_AnnualRewardLottery 'Teodor Petrov';

EXEC usp_AnnualRewardLottery 'Zac Walsh';

EXEC usp_AnnualRewardLottery 'Brus Brown';
