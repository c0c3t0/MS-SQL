--Section 1. DDL (30 pts)

CREATE DATABASE TripService
GO

USE TripService
GO

CREATE TABLE Cities(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(20) NOT NULL
	, CountryCode char(2) NOT NULL
	);
	
CREATE TABLE Hotels(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(30) NOT NULL
	, CityId int NOT NULL FOREIGN KEY REFERENCES Cities(Id)
	, EmployeeCount int NOT NULL
	, BaseRate decimal(10,2)
	);
	
CREATE TABLE Rooms(
	Id int PRIMARY KEY IDENTITY
	, Price decimal(10,2) NOT NULL
	, [Type] varchar(20) NOT NULL
	, Beds int NOT NULL
	, HotelId int NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
	);
	
CREATE TABLE Trips(
	Id int PRIMARY KEY IDENTITY
	, RoomId int NOT NULL FOREIGN KEY REFERENCES Rooms(Id)
	, BookDate date NOT NULL
	, ArrivalDate date NOT NULL 
	, ReturnDate date NOT NULL 
	, CancelDate date
	, CHECK (BookDate < ArrivalDate)
	, CHECK (ArrivalDate < ReturnDate)
	);

CREATE TABLE Accounts(
	Id int PRIMARY KEY IDENTITY
	, FirstName varchar(50) NOT NULL
	, MiddleName varchar(20)
	, LastName varchar(50) NOT NULL
	, CityId int NOT NULL FOREIGN KEY REFERENCES Cities(Id)
	, BirthDate date NOT NULL
	, Email varchar(100) NOT NULL UNIQUE
	);

CREATE TABLE AccountsTrips(
	AccountId int NOT NULL FOREIGN KEY REFERENCES Accounts(Id)
	, TripId int NOT NULL FOREIGN KEY REFERENCES Trips(Id)
	, Luggage int NOT NULL CHECK(Luggage >= 0)
	PRIMARY KEY (AccountId, TripId)
	);


--02. Insert
INSERT INTO Accounts(FirstName, MiddleName,LastName, CityId, BirthDate, Email) VALUES
	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com')
	, ('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com')
	, ('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg')
	, ('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate) VALUES
	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02')
	, (102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29')
	, (103, '2013-07-17', '2013-07-23', '2013-07-24', NULL)
	, (104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10')
	, (109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)


--03. Update
UPDATE
	Rooms
SET
	Price *= 1.14
WHERE
	HotelId IN (5, 7, 9);



--04. Delete
DELETE
FROM
	AccountsTrips
WHERE
	AccountId = 47;


--05. EEE-Mails
SELECT
	a.FirstName
	, a.LastName
	, FORMAT(a.BirthDate, 'MM-dd-yyyy') AS BirthDate
	, c.Name
	, a.Email
FROM
	Accounts a
JOIN Cities c ON
	a.CityId = c.Id
WHERE
	Email LIKE 'e%'
ORDER BY
	c.Name;


--06. City Statistics
SELECT
	c.Name
	, COUNT(*) AS Hotels
FROM
	Cities c
JOIN Hotels h ON
	h.CityId = c.Id
GROUP BY
	CityId
	, c.Name
ORDER BY
	Hotels DESC
	, c.Name;


--07. Longest and Shortest Trips
SELECT
	info.AccountId
	, info.LongestTrip
	, info.ShortestTrip
FROM
	(
	SELECT
		atr.AccountId
		, MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip
		, MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
	FROM
		AccountsTrips atr
	JOIN Trips t ON
		atr.TripId = t.Id
	WHERE
		t.CancelDate IS NULL
	GROUP BY
		atr.AccountId) AS info
JOIN Accounts a ON
	a.Id = info.AccountId
WHERE
	a.MiddleName IS NULL
ORDER BY
	info.LongestTrip DESC
	, info.ShortestTrip;



--08. Metropolis
SELECT
	TOP 10
	c.Id
	, c.Name AS City
	, c.CountryCode AS Country
	, a.Accounts
FROM
	(
	SELECT
		CityId
		, COUNT(*) AS Accounts
	FROM
		Accounts
	GROUP BY
		CityId) AS a
JOIN Cities c ON
	a.CityId = c.Id
ORDER BY
	a.Accounts DESC;



--09. Romantic Getaways
SELECT
	a.Id
	, a.Email
	, c.Name AS City
	, COUNT(atr.TripId) AS Trips
FROM
	Accounts a
JOIN AccountsTrips atr ON
	a.Id = atr.AccountId
JOIN Trips t ON
	t.Id = atr.TripId
JOIN Rooms r ON
	t.RoomId = r.Id
JOIN Hotels h ON
	h.CityId = a.CityId
	AND h.Id = r.HotelId
JOIN Cities c ON
	a.CityId = c.Id
GROUP BY
	a.Id
	, a.Email
	, c.Name
ORDER BY
	Trips DESC, a.Id;



--10. GDPR Violation
SELECT
	t.Id
	, CONCAT(a.FirstName, ' ', a.MiddleName, ' ', a.LastName) AS FullName
	, c.Name AS [From]
	, c2.Name AS [To]
	, CASE​
110
--06. City Statistics
111
SELECT * FROM Cities c
		WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
		ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
	END AS Duration
FROM
	Trips t
JOIN AccountsTrips at2 ON
	at2.TripId = t.Id
JOIN Accounts a ON
	a.Id = at2.AccountId
JOIN Cities c ON
	c.Id = a.CityId
JOIN Rooms r ON
	r.Id = t.RoomId
JOIN Hotels h ON
	h.Id = r.HotelId
JOIN Cities c2 ON
	c2.Id = h.CityId
ORDER BY
	FullName
	, t.Id;




