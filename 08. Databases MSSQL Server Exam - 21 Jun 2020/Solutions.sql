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
SELECT * FROM Cities c


