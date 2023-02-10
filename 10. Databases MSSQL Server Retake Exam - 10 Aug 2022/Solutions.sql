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

	






	
	
	
	
	


