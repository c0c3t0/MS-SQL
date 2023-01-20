-- 1. One-To-One Relationship

USE TableRelations;

CREATE TABLE Persons (
	PersonID INT PRIMARY KEY IDENTITY
	, FirstName NVARCHAR(50) NOT NULL
	, Salary DECIMAL(10, 2)
	, PassportID INT UNIQUE NOT NULL 
);

CREATE TABLE Passports (
	PassportID INT PRIMARY KEY IDENTITY(101, 1)
	, PassportNumber NVARCHAR(10) NOT NULL
);

INSERT
	INTO
	Persons
VALUES 
	('Roberto', 43300.00, 102)
	, ('Tom', 54100.00, 103)
	, ('Yana', 60200.00, 101);
	
INSERT
	INTO
	Passports
VALUES
	('N34FG21B'),
	('K65LO4R7'),
	('ZE657QP2');
	
ALTER TABLE Persons ADD FOREIGN KEY (PassportID) REFERENCES Passports(PassportID);



-- 2. One-To-Many Relationship

CREATE TABLE Manufacturers (
	ManufacturerID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(20) NOT NULL,
	EstablishedOn DATE NOT NULL
);


CREATE TABLE Models (
	ModelID INT PRIMARY KEY IDENTITY(101, 1),
	Name NVARCHAR(20) NOT NULL,
	ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
);

INSERT INTO Manufacturers VALUES
	('BMW', '07/03/1916'),
	('Tesla', '01/01/2003'),
	('Lada', '01/05/1966');

INSERT INTO Models VALUES 
	('X1', 1),
	('i6', 1),
	('ModelS', 2),
	('ModelX', 2),
	('Model3', 2),
	('Nova', 3)	;

	
-- 3. Many-To-Many Relationship
	
CREATE TABLE Students (
	StudentID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(20) NOT NULL,
);

CREATE TABLE Exams (
	ExamID INT PRIMARY KEY IDENTITY(101, 1),
	Name NVARCHAR(40) NOT NULL
);

CREATE TABLE StudentsExams (
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID),
	PRIMARY KEY (StudentID, ExamID)
);

INSERT INTO Students VALUES
	('Mila'),
	('Toni'),
	('Ron');
	
INSERT INTO Exams VALUES
	('SpringMVC'),
	('Neo4j'),
	('Oracle 11g');
	
	
INSERT INTO StudentsExams VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103);
	
	
-- 4. Self-Referencing 
	
CREATE TABLE Teachers (
	TeacherID INT PRIMARY KEY IDENTITY(101,1),
	Name NVARCHAR(10) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
);

INSERT INTO Teachers VALUES
	('John', NULL),
	('Maya', 106),
	('Silvia', 106),
	('Ted', 105),
	('Mark', 101),
	('Greta',101);
	
	
-- 5. Online Store Database

CREATE DATABASE OnlineStore;

USE OnlineStore;

CREATE TABLE Cities (
	CityID INT PRIMARY KEY,
	Name NVARCHAR(20) NOT NULL
);

CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY,
	Name NVARCHAR(20) NOT NULL,
	Birthday DATE,
	CityID INT FOREIGN KEY REFERENCES Cities(CityID)
);

CREATE TABLE Orders (
	OrderID INT PRIMARY KEY,
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

CREATE TABLE ItemTypes (
	ItemTypesID INT PRIMARY KEY,
	Name NVARCHAR(20) NOT NULL
);

CREATE TABLE Items (
	ItemID INT PRIMARY KEY,
	Name NVARCHAR(20) NOT NULL,
	ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypesID)
);

CREATE TABLE OrderItems (
	OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
	ItemID INT FOREIGN KEY REFERENCES Items(ItemID),
	PRIMARY KEY (OrderID, ItemID)
);


-- 6. University Database
CREATE DATABASE University;

USE University;

CREATE TABLE Subjects (
	SubjectID INT PRIMARY KEY,
	SubjectName NVARCHAR(30) NOT NULL
);


CREATE TABLE Majors(
	MajorID INT PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL
);

CREATE TABLE Students (
	StudentID INT PRIMARY KEY,
	StudentNumber INT NOT NULL,
	StudentName NVARCHAR(40) NOT NULL,
	MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
);

CREATE TABLE Agenda (
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
	PRIMARY KEY (StudentID, SubjectID)
);

CREATE TABLE Payments (
	PaymentID INT PRIMARY KEY,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL(10,2) NOT NULL,
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
);


-- 9. Peaks in Rila
USE Geography;

SELECT
	m.MountainRange
	,p.PeakName
	,p.Elevation
FROM
	Peaks AS p
JOIN Mountains AS m ON
	p.MountainId = m.Id
WHERE
	P.MountainId = (
	SELECT
		Id
	FROM
		Mountains
	WHERE
		MountainRange = 'Rila')
ORDER BY p.Elevation DESC;




































	

