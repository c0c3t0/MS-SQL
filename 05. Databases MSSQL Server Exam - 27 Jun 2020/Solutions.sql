--- === *** [Database Basics MS SQL Exam – 27 June 2020] === ---

--- == [Section 1. DDL ] === --

--01.Database design
CREATE DATABASE WMS;
GO

USE WMS;
GO

CREATE TABLE Clients (
	ClientId INT PRIMARY KEY IDENTITY
	, FirstName VARCHAR(50) NOT NULL
	, LastName VARCHAR(50) NOT NULL
	, Phone CHAR(12) NOT NULL
	);

CREATE TABLE Mechanics (
	MechanicId INT PRIMARY KEY IDENTITY
	, FirstName VARCHAR(50) NOT NULL
	, LastName VARCHAR(50) NOT NULL
	, Address VARCHAR(255) NOT NULL
	);

CREATE TABLE Models(
	ModelId INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) UNIQUE NOT NULL
	);

CREATE TABLE Jobs(
	JobId INT PRIMARY KEY IDENTITY
	, ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL
	, Status VARCHAR(11) CHECK(Status IN ('Pending', 'In Progress', 'Finished')) DEFAULT 'Pending' NOT NULL
	, ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL
	, MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId)
	, IssueDate DATE NOT NULL
	, FinishDate DATE
	);

CREATE TABLE Orders(
	OrderId INT PRIMARY KEY IDENTITY
	, JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
	, IssueDate DATE
	, Delivered BIT DEFAULT 0 NOT NULL 
	);

CREATE TABLE Vendors(
	VendorId INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Parts(
	PartId INT PRIMARY KEY IDENTITY
	, SerialNumber VARCHAR(50) UNIQUE NOT NULL 
	, Description VARCHAR(255)
	, Price MONEY CHECK(Price BETWEEN 0 AND 9999.99) NOT NULL
	, VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL 
	, StockQty INT CHECK(StockQty >= 0) DEFAULT 0 NOT NULL
	);

CREATE TABLE OrderParts(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL
	, PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
	, Quantity INT CHECK(Quantity >= 0) DEFAULT 1 NOT NULL
	, PRIMARY KEY (OrderId, PartId)
	);

CREATE TABLE PartsNeeded(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
	, PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
	, Quantity INT CHECK(Quantity >= 0) DEFAULT 1 NOT NULL
	, PRIMARY KEY (JobId, PartId)
	);

-- == [Section 2. DML] == --

--02. Insert
INSERT INTO Clients(FirstName, LastName, Phone) VALUES
	('Teri', 'Ennaco', '570-889-5187')
	, ('Merlyn', 'Lawler', '201-588-7810')
	, ('Georgene', 'Montezuma', '925-615-5185')
	, ('Jettie', 'Mconnell', '908-802-3564')
	, ('Lemuel', 'Latzke', '631-748-6479')
	, ('Melodie', 'Knipp', '805-690-1682')
	, ('Candida', 'Corbley', '908-275-8357');

INSERT INTO Parts(SerialNumber, Description, Price, VendorId) VALUES
	('WP8182119', 'Door Boot Seal', 117.86, 2)
	, ('W10780048', 'Suspension Rod', 42.81, 1)
	, ('W10841140', 'Silicone Adhesive', 6.77, 4)
	, ('WPY055980', 'High Temperature Adhesive', 13.94, 3);
	
	
	
--03. Update
UPDATE
	Jobs
SET
	Status = 'In Progress'
	, MechanicId = 3
WHERE
	Status = 'Pending';



--04. Delete
DELETE
	OrderParts
WHERE
	OrderId = 19;

DELETE
	Orders
WHERE
	OrderId = 19;



-- === [Section 3. Querying ] === --

--05. Mechanic Assignments
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic
	, j.Status
	, j.IssueDate
FROM
	Jobs j
JOIN Mechanics m ON
	j.MechanicId = m.MechanicId
ORDER BY
	m.MechanicId
	, j.IssueDate
	, JobId;


--06. Current Clients
SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS Client
	, DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going]
	, j.Status
FROM
	Jobs j
JOIN Clients c ON
	c.ClientId = j.ClientId
WHERE
	j.Status <> 'Finished'
ORDER BY
	[Days going] DESC
	, c.ClientId;



--07. Mechanic Performance
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic
	, av.[Average Days]
FROM
	(
	SELECT
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
		, MechanicId
	FROM
		Jobs j
	WHERE
		j.FinishDate IS NOT NULL
	GROUP BY
		MechanicId) AS av
JOIN Mechanics m ON
	m.MechanicId = av.MechanicId
ORDER BY
	m.MechanicId;



--08. Available Mechanics
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Available
FROM
	Mechanics m
WHERE
	m.MechanicId NOT IN (
	SELECT
		MechanicId
	FROM
		Jobs j
	WHERE
		MechanicId IS NOT NULL
		AND j.Status <> 'Finished'
	GROUP BY
		MechanicId
		, j.Status)
ORDER BY
	m.MechanicId;


--09. Past Expenses
SELECT
	j.JobId
	, ISNULL(SUM(p.Price * op.Quantity)
	, 0) AS Total
FROM
	Jobs j
LEFT JOIN Orders o ON
	j.JobId = o.JobId
LEFT JOIN OrderParts op ON
	op.OrderId = o.OrderId
LEFT JOIN Parts p ON
	p.PartId = op.PartId
WHERE
	j.Status = 'Finished'
GROUP BY
	j.JobId
ORDER BY
	Total DESC
	, JobId;

	
	
--	10. Missing Parts
SELECT
	p.PartId
	, p.Description
	, SUM(pn.Quantity) AS Required
	, SUM(p.StockQty) AS [In Stock]
	, ISNULL(SUM(g.Quantity), 0) AS Ordered
FROM
	Parts p
LEFT JOIN PartsNeeded pn ON
	pn.PartId = p.PartId
LEFT JOIN Jobs j ON
	pn.JobId = j.JobId
LEFT JOIN (
	SELECT 
		op.PartId
		, op.Quantity
	FROM
		Orders AS o
	JOIN OrderParts AS op ON
		op.OrderId = o.OrderId
	WHERE
		o.Delivered = 0) AS g ON
	g.PartId = p.PartId
WHERE
	j.Status <> 'Finished'
GROUP BY
	p.PartId
	, p.Description
HAVING
	SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(g.Quantity), 0)
ORDER BY
	p.PartId;




--- === [Section 4. Programmability] === ---
--    11. Place Order
CREATE OR ALTER PROC usp_PlaceOrder(@jobId INT, @partSerialNumber VARCHAR(50), @quantity INT)
AS
BEGIN
	IF ((SELECT Status
         FROM Jobs
         WHERE JobId = @jobId) = 'Finished')
        THROW 50011, 'This job is not active!', 1;
    IF @quantity <= 0
        THROW 50012, 'Part quantity must be more than zero!', 1;
	DECLARE
		@job INT = (SELECT JobId
	                FROM Jobs
	                WHERE JobId = @jobId)
	    IF @job IS NULL
	        THROW 50013, 'Job not found!', 1;
	DECLARE
    	@partId INT = (SELECT PartId
                   FROM Parts
                   WHERE SerialNumber = @partSerialNumber)
	    IF @partId IS NULL
	        THROW 50014, 'Part not found!', 1;
	    IF (SELECT OrderId
	         FROM Orders
	         WHERE JobId = @jobId
	           AND IssueDate IS NULL) IS NULL
	        BEGIN
	            INSERT INTO Orders (JobId, IssueDate, Delivered)
	            VALUES (@jobId, NULL, 0)
	        END
	DECLARE
	    @orderId int = (
	        SELECT OrderId
	        FROM Orders
	        WHERE JobId = @jobId
	          AND IssueDate IS NULL)
	DECLARE
	    @orderPartsQuantity INT = (SELECT Quantity
	                               FROM OrderParts
	                               WHERE OrderId = @orderId
	                                 AND PartId = @partId)
	    IF @orderPartsQuantity IS NULL
            INSERT INTO OrderParts (OrderId, PartId, Quantity)
            VALUES (@orderId, @partId, @quantity)
	    ELSE
            UPDATE OrderParts
            SET Quantity += @quantity
            WHERE OrderId = @orderId
              AND PartId = @partId
END



--12. Cost of Order
CREATE FUNCTION udf_GetCost(@jobId int)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE 
		@totalCost DECIMAL(10,2) = (
			SELECT
				SUM(p.Price)
			FROM
				Parts AS p
			JOIN OrderParts AS op ON
				p.PartId = op.PartId
			JOIN Orders AS o ON
				o.OrderId = op.OrderId
			JOIN Jobs AS j ON
				j.JobId = o.JobId
			WHERE
				j.JobId = @jobId)
		IF @totalCost IS NULL
			RETURN 0
	    RETURN @totalCost
END

SELECT dbo.udf_GetCost(1)




