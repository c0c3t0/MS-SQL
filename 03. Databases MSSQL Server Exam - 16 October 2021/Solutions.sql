-- == *** [Databases MSSQL Server Exam - 16 October 2021] *** == --


-- == [Section 1. DDL (30 pts)] == --

--01. Database design
CREATE DATABASE CigarShop;
GO

USE CigarShop;
GO

CREATE TABLE Sizes(
	Id INT PRIMARY KEY IDENTITY
	, [Length] INT CHECK([Length] BETWEEN 10 AND 25) NOT NULL
	, RingRange DECIMAL(18,2) CHECK(RingRange BETWEEN 1.5 AND 7.5) NOT NULL
);

CREATE TABLE Tastes(
	Id INT PRIMARY KEY IDENTITY
	, TasteType VARCHAR(20) NOT NULL
	, TasteStrength VARCHAR(15) NOT NULL
	, ImageURL NVARCHAR(100) NOT NULL
);

CREATE TABLE Brands(
	Id INT PRIMARY KEY IDENTITY
	, BrandName VARCHAR(30) UNIQUE NOT NULL
	, BrandDescription VARCHAR(MAX) 
);

CREATE TABLE Cigars(
	Id INT PRIMARY KEY IDENTITY
	, CigarName VARCHAR(80) NOT NULL
	, BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL
	, TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL
	, SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL
	, PriceForSingleCigar MONEY NOT NULL
	, ImageURL NVARCHAR(100) NOT NULL
);

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY
	, Town VARCHAR(30) NOT NULL
	, Country VARCHAR(30) NOT NULL
	, Streat VARCHAR(100) NOT NULL
	, ZIP VARCHAR(20) NOT NULL
);

CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY
	, FirstName VARCHAR(30) NOT NULL
	, LastName VARCHAR(30) NOT NULL
	, Email VARCHAR(50) NOT NULL
	, AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
);

CREATE TABLE ClientsCigars(
	ClientId INT foreign key REFERENCES Clients(Id)
	, CigarId INT foreign key REFERENCES Cigars(Id)
	PRIMARY KEY (ClientId, CigarId)
);



-- == [Section 2. DML (10 pts)] == --

--02. Insert
INSERT INTO Cigars(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL) VALUES
	('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg')
	, ('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg')
	, ('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg')
	, ('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg')
	, ('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg');

INSERT INTO Addresses(Town, Country, Streat, ZIP) VALUES
	('Sofia', 'Bulgaria', '18 Bul. Vasil levski', 1000)
	, ('Athens', 'Greece', '4342 McDonald Avenue', 10435)
	, ('Zagreb', 'Croatia', '4333 Lauren Drive', 10000);


-- 03. Update
UPDATE
	Cigars
SET
	PriceForSingleCigar *= 1.2
WHERE
	TastId = (
	SELECT
		t.Id
	FROM
		Tastes t
	WHERE
		t.TasteType = 'Spicy');

UPDATE
	Brands
SET
	BrandDescription = 'New description'
WHERE
	BrandDescription IS NULL;

--04. Delete
DELETE
FROM
	Clients
WHERE
	AddressId IN (
	SELECT
		id
	FROM
		Addresses
	WHERE
		Country LIKE 'C%');
DELETE
FROM
	Addresses
WHERE
	Country LIKE 'C%';


-- == [Section 3. Querying (40 pts)] == --

--05. Cigars by Price
SELECT
	CigarName
	, PriceForSingleCigar
	, ImageURL
FROM
	Cigars c
ORDER BY
	PriceForSingleCigar
	, CigarName DESC;


--06. Cigars by Taste
SELECT
	c.Id
	, c.CigarName
	, c.PriceForSingleCigar
	, t.TasteType
	, t.TasteStrength
FROM
	Cigars c
JOIN Tastes t ON
	t.Id = c.TastId
WHERE
	t.TasteType IN ('Earthy', 'Woody')
ORDER BY
	PriceForSingleCigar DESC;


--07. Clients without Cigars
SELECT
	c.Id
	, CONCAT(c.FirstName, ' ', c.LastName) AS ClientName
	, c.Email
FROM
	Clients c
LEFT JOIN ClientsCigars cc ON
	c.Id = cc.ClientId
WHERE
	cc.ClientId IS NULL
ORDER BY
	c.FirstName
	, c.LastName;


--08. First 5 Cigars
SELECT
	TOP 5 c.CigarName
	, c.PriceForSingleCigar
	, c.ImageURL
FROM
	Cigars c
JOIN Sizes s ON
	c.SizeId = s.Id
WHERE
	s.[Length] >= 12
	AND (c.CigarName LIKE '%ci%'
	OR c.PriceForSingleCigar > 50)
	AND s.RingRange > 2.55
ORDER BY
	c.CigarName
	, c.PriceForSingleCigar DESC;


--09. Clients with ZIP Codes
SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName
	, a.Country
	, a.ZIP
	, CONCAT('$', p.Price) AS CigarPrice
FROM
	(
	SELECT
		cc.ClientId
		, MAX(ci.PriceForSingleCigar) AS Price
	FROM
		ClientsCigars cc
	JOIN Cigars ci ON
		cc.CigarId = ci.Id
	GROUP BY
		cc.ClientId) AS p
JOIN Clients c ON
	p.ClientId = c.Id
JOIN Addresses a ON
	c.Id = a.Id
WHERE
	a.ZIP NOT LIKE '%[^0-9]%'
ORDER BY
	FullName;


--10. Cigars by Size
SELECT
	c.LastName
	, AVG(s.[Length]) AS CigarLength
	, CEILING(AVG(s.RingRange)) AS CigarRingRange
FROM
	Clients c
JOIN ClientsCigars cc ON
	cc.ClientId = c.Id
JOIN Cigars ci ON
	ci.Id = cc.CigarId
JOIN Sizes s ON
	s.Id = ci.SizeId
GROUP BY
	c.LastName
ORDER BY CigarLength DESC;


-- == [Section 4. Programmability (20 pts)] == --

--11. Client with Cigars
CREATE FUNCTION udf_ClientWithCigars(@name varchar(30))
RETURNS INT
AS
BEGIN
	DECLARE @result int = (
	SELECT
		COUNT(*)
	FROM
		ClientsCigars cc
	JOIN Clients c ON
		c.Id = cc.ClientId
	WHERE
		c.FirstName = @name )
	RETURN @result
END

SELECT dbo.udf_ClientWithCigars('Betty');



--12. Search for Cigar with Specific Taste
CREATE OR ALTER PROC usp_SearchByTaste(@taste varchar(30))
AS
BEGIN
	SELECT
	c.CigarName
	, CONCAT('$', c.PriceForSingleCigar) AS Price
	, t.TasteType
	, b.BrandName
	, CONCAT(s.[Length], ' cm') AS CigarLength
	, CONCAT(s.RingRange, ' cm') AS CigarRingRange
	FROM
		Cigars c
	JOIN Tastes t ON
		t.Id = c.TastId
	JOIN Brands b ON
		b.Id = c.BrandId
	JOIN Sizes s ON
		s.Id = c.SizeId
	WHERE
		t.TasteType = @taste
	ORDER BY 
		s.[Length], s.RingRange DESC
END

EXEC usp_SearchByTaste 'Woody';







