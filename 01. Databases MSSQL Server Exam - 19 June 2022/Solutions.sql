-- == [Section 1. DDL (30 pts)] == --
CREATE DATABASE Zoo;
GO

USE Zoo;

CREATE TABLE Owners(
	Id INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) NOT NULL
	, PhoneNumber VARCHAR(15) NOT NULL
	, Address VARCHAR(50)
);

CREATE TABLE AnimalTypes(
	Id INT PRIMARY KEY IDENTITY
	, AnimalType VARCHAR(30) NOT NULL
);

CREATE TABLE Cages(
	Id INT PRIMARY KEY IDENTITY
	, AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
);

CREATE TABLE Animals(
	Id INT PRIMARY KEY IDENTITY
	, Name VARCHAR(30) NOT NULL
	, BirthDate DATE NOT NULL
	, OwnerId INT FOREIGN KEY REFERENCES Owners(Id)
	, AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
);


CREATE TABLE AnimalsCages(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages(Id)
	, AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals(Id)
	, PRIMARY KEY (CageId, AnimalId)
);

CREATE TABLE VolunteersDepartments(
	Id INT PRIMARY KEY IDENTITY
	, DepartmentName VARCHAR(30) NOT NULL
);

CREATE TABLE Volunteers(
	Id INT PRIMARY KEY IDENTITY
	, Name VARCHAR(50) NOT NULL
	, PhoneNumber VARCHAR(15) NOT NULL
	, Address VARCHAR(50)
	, AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
	, DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments(Id)
);



-- == [Section 2. DML (10 pts)] == --

--02. INSERT
INSERT INTO Volunteers(Name, PhoneNumber, Address, AnimalId, DepartmentId) VALUES
	('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1)
	, ('Dimitur Stoev', '0877564223', NULL, 42, 4)
	, ('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7)
	, ('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8)
	, ('Boryana Mileva', '0888112233', NULL, 31, 5);

INSERT INTO Animals(Name, BirthDate, OwnerId, AnimalTypeId) VALUES
	('Giraffe', '2018-09-21', 21, 1)
	, ('Harpy Eagle', '2015-04-17', 15, 3)
	, ('Hamadryas Baboon', '2017-11-02', NULL, 1)
	, ('Tuatara', '2021-06-30', 2, 4);



--03. Update
UPDATE
	Animals
SET
	OwnerId = (
	SELECT
		Id
	FROM
		Owners
	WHERE
		Name = 'Kaloqn Stoqnov')
WHERE
	OwnerId IS NULL;

SELECT
	*
	FROM Animals a
WHERE
	OwnerId IS NULL;


--04. DELETE
DELETE
FROM
	Volunteers
WHERE
	DepartmentId = (
	SELECT
		Id
	FROM
		VolunteersDepartments
	WHERE
		DepartmentName = 'Education program assistant');

DELETE FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant';


-- == [Section 3. Querying (40 pts)] == --

--05. Volunteers
SELECT
	Name
	, PhoneNumber
	, Address
	, AnimalId
	, DepartmentId
FROM
	Volunteers
ORDER BY
	Name
	, AnimalId
	, DepartmentId;



--06. Animals data
SELECT
	a.Name
	, atype.AnimalType
	, FORMAT(a.BirthDate
	, 'dd.MM.yyyy')
FROM
	Animals AS a
JOIN AnimalTypes AS atype ON
	a.AnimalTypeId = atype.Id
ORDER BY
	Name;


--07. Owners and Their Animals
SELECT
	TOP 5 
	o.Name AS Owner
	, COUNT(*) AS CountOfAnimals
FROM
	Owners AS o
JOIN Animals AS a ON
	o.Id = a.OwnerId
GROUP BY
	a.OwnerId
	, o.Name
ORDER BY
	COUNT(*) DESC
	, o.Name;



--08. Owners, Animals and Cages
SELECT
	CONCAT(o.Name, '-', a.Name) AS OwnersAnimals
	, o.PhoneNumber
	, ac.CageId
FROM
	Owners o
JOIN Animals a ON
	o.Id = a.OwnerId
JOIN AnimalTypes atypes ON
	atypes.Id = a.AnimalTypeId
JOIN AnimalsCages AS ac ON
		a.Id = ac.AnimalId
WHERE
	atypes.AnimalType = 'Mammals'
ORDER BY
	o.Name
	, a.Name DESC;



--09. Volunteers in Sofia
SELECT
	v.Name
	, v.PhoneNumber
	, SUBSTRING(v.Address, CHARINDEX(',', v.Address) + 2, LEN(v.Address))AS Address
FROM
	Volunteers v
WHERE
	v.DepartmentId = (
	SELECT
		Id
	FROM
		VolunteersDepartments vd
	WHERE
		vd.DepartmentName = 'Education program assistant')
	AND v.Address LIKE '%Sofia%'
ORDER BY
	v.Name;


--10. Animals for Adoption
SELECT
	a.Name
	, DATEPART(YEAR, a.BirthDate) AS BirthYear
	, at2.AnimalType
FROM
	Animals a
JOIN AnimalTypes at2 ON
	a.AnimalTypeId = at2.Id
WHERE
	a.OwnerId IS NULL
	AND DATEDIFF(YEAR, a.BirthDate, '2022') < 5
	AND a.AnimalTypeId <> (
	SELECT
		at2.Id
	FROM
		AnimalTypes at2
	WHERE
		at2.AnimalType = 'Birds')
ORDER BY
	a.Name;



-- === [Section 4. Programmability (20 pts)] === --

--11. All Volunteers in a Department
CREATE FUNCTION udf_GetVolunteersCountFromADepartment(@VolunteersDepartment varchar(50))
RETURNS int
AS
BEGIN
	DECLARE @count int = (
	SELECT
		COUNT(*)
	FROM
		Volunteers AS v
	JOIN VolunteersDepartments AS vd ON
		v.DepartmentId = vd.Id
	WHERE vd.DepartmentName = @VolunteersDepartment)
	RETURN @count
END


SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')


--12. Animals with Owner or Not
CREATE OR ALTER PROC usp_AnimalsWithOwnersOrNot(@AnimalName varchar(50))
AS
BEGIN
	SELECT
	a.Name
	, COALESCE(o.Name, 'For adoption') AS OwnersName
FROM
	Animals a
LEFT JOIN Owners o ON
	a.OwnerId = o.Id
WHERE
	a.Name = @AnimalName
END

EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'

EXEC usp_AnimalsWithOwnersOrNot 'Hippo'

EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'












