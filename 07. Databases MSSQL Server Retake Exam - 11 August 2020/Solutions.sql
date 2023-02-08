--Section 1. DDL 
USE zoo

DROP DATABASE Bakery

CREATE DATABASE Bakery;
GO

USE Bakery;
GO

CREATE TABLE Countries(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) UNIQUE NOT NULL 
	);
	
CREATE TABLE Customers(
	Id int PRIMARY KEY IDENTITY
	, FirstName varchar(25) NOT NULL
	, LastName varchar(25) NOT NULL
	, Gender char(1) CHECK(Gender IN ('M', 'F')) NOT NULL
	, Age int NOT NULL
	, PhoneNumber char(10)
	, CountryId int FOREIGN KEY REFERENCES Countries(Id) NOT NULL 
	);
	
CREATE TABLE Products(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(25) UNIQUE NOT NULL
	, Description varchar(250) NOT NULL
	, Recipe varchar(max) NOT NULL
	, Price decimal(15, 2) CHECK(Price > 0) NOT NULL 
	);
	
CREATE TABLE Feedbacks(
	Id int PRIMARY KEY IDENTITY
	, Description varchar(255)
	, Rate decimal(4, 2) CHECK(Rate BETWEEN 0 AND 10) NOT NULL 
	, ProductId int FOREIGN KEY REFERENCES Products(Id) NOT NULL 
	, CustomerId int FOREIGN KEY REFERENCES Customers(Id) NOT NULL 
	);
	
CREATE TABLE Distributors(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(25) UNIQUE NOT NULL 
	, AddressText varchar(30) NOT NULL
	, Summary varchar(200) NOT NULL
	, CountryId int FOREIGN KEY REFERENCES Countries(Id) NOT NULL 
	);

CREATE TABLE Ingredients(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(30) NOT NULL 
	, Description varchar(200) NOT NULL
	, OriginCountryId int FOREIGN KEY REFERENCES Countries(Id) NOT NULL 
	, DistributorId int FOREIGN KEY REFERENCES Distributors(Id) NOT NULL 
	);

CREATE TABLE ProductsIngredients(
	ProductId int FOREIGN KEY REFERENCES Products(Id) NOT NULL 
	, IngredientId int FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL 
	PRIMARY KEY (ProductId, IngredientId)
	);
	


--02. Insert
INSERT INTO Distributors(Name, CountryId, AddressText, Summary) VALUES
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling')
	, ('Congress Title', 13, '58 Hancock St', 'Customer loyalty')
	, ('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery')
	, ('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group')
	, ('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware');
	
INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId) VALUES
	('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5)
	, ('Kendra', 'Loud', 22, 'F', '0063631526', 11)
	, ('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8)
	, ('Hannah', 'Edmison', 18, 'F', '0043343686', 1)
	, ('Tom', 'Loeza', 31, 'M', '0144876096', 23)
	, ('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29)
	, ('Hiu', 'Portaro', 25, 'M', '0068277755', 16)
	, ('Josefa', 'Opitz', 43, 'F', '0197887645', 17);
	
	
	
--03. Update	
UPDATE
	Ingredients
SET
	DistributorId = 35
WHERE
	Name IN ('Bay Leaf', 'Paprika', 'Poppy');

UPDATE
	Ingredients
SET
	OriginCountryId = 14
WHERE
	OriginCountryId = 8;


--04. Delete
DELETE
FROM
	Feedbacks
WHERE
	CustomerId = 14
	OR ProductId = 5;
	
	
--05. Products By Price
SELECT
	Name, Price, Description
FROM
	Products p
ORDER BY
	Price DESC
	, Name;
	
	
	
--06. Negative Feedback
SELECT
	f.ProductId AS ProductId
	, f.Rate
	, f.Description
	, f.CustomerId
	, c.Age
	, c.Gender
FROM
	Feedbacks f
JOIN Customers c ON
	c.Id = f.CustomerId
WHERE
	f.Rate < 5.0
ORDER BY
	f.ProductId DESC
	, f.Rate;


--07. Customers without Feedback
SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName
	, c.PhoneNumber
	,c.Gender
FROM
	Feedbacks f
RIGHT JOIN Customers c ON
	c.Id = f.CustomerId
WHERE
	f.CustomerId IS NULL
ORDER BY
	c.Id;

	
--08. Customers by Criteria
SELECT
	c.FirstName
	, c.Age
	, c.PhoneNumber
FROM
	Customers c
WHERE
	(c.Age > 20
		AND c.FirstName LIKE '%an%')
	OR (c.PhoneNumber LIKE '%38'
		AND c.CountryId <> 31)
ORDER BY
	c.FirstName
	, c.Age DESC;
	
	
	
--09. Middle Range Distributors
SELECT
	d.Name AS DistributorName
	, i.Name AS IngredientName
	, p.Name AS ProductName
	, f.Rate
FROM
	(
	SELECT
		AVG(Rate) AS Rate
		, fb.ProductId
	FROM
		Feedbacks fb
	GROUP BY
		fb.ProductId
	HAVING
		AVG(Rate) BETWEEN 5 AND 8
	) AS f
JOIN Products p ON
	p.Id = f.ProductId
JOIN ProductsIngredients pr ON
	p.Id = pr.ProductId
JOIN Ingredients i ON
	pr.IngredientId = i.Id
JOIN Distributors d ON
	d.Id = i.DistributorId
ORDER BY
	d.Name
	, i.Name
	, p.Name;



--10. Country Representative
SELECT
	ranked.CountryName
	, ranked.DistributorName
FROM
	(
	SELECT
		c.Name AS CountryName
		, d.Name AS DistributorName
		, DENSE_RANK() OVER(PARTITION BY c.Name ORDER BY COUNT(i.Id)DESC) AS r
	FROM
		Countries c
	JOIN Distributors d ON
		c.Id = d.CountryId
	LEFT JOIN Ingredients i ON
		d.Id = i.DistributorId
	GROUP BY
		c.Name
		, d.Name) AS ranked
WHERE
	ranked.r = 1
ORDER BY
	ranked.CountryName
	, ranked.DistributorName;



--11. Customers With Countries
CREATE VIEW v_UserWithCountries
AS
SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName
	, c.Age
	, c.Gender
	, co.Name
FROM
	Customers c
JOIN Countries co ON
	c.CountryId = co.Id;


SELECT
	TOP 5 *
FROM
	v_UserWithCountries
ORDER BY
	Age;


--12. Delete Products
CREATE TRIGGER tr_DeleteAllProductRelationsOnDelete ON Products 
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @deletedProductId INT = (
		SELECT
			p.Id
		FROM
			Products AS p
		JOIN deleted AS d ON
			p.Id = d.Id)
		DELETE
		FROM
			Feedbacks
		WHERE
			ProductId = @deletedProductId
		DELETE
		FROM
			ProductsIngredients
		WHERE
			ProductId = @deletedProductId
		DELETE
		FROM
			Products
		WHERE
			Id = @deletedProductId
END

DELETE
FROM
	Products
WHERE
	Id = 7;



