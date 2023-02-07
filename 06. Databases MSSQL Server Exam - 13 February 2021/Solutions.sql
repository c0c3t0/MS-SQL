-- === *** [Section 1. DDL (30 pts)] *** === --

CREATE DATABASE Bitbucket;
GO

USE Bitbucket;
GO

CREATE TABLE Users(
	Id int PRIMARY KEY IDENTITY
	, Username varchar(30) NOT NULL
	, Password varchar(30) NOT NULL
	, Email varchar(50) NOT NULL
	);
	
CREATE TABLE Repositories(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(50) NOT NULL
	);
	
CREATE TABLE RepositoriesContributors(
	RepositoryId int NOT NULL FOREIGN KEY REFERENCES Repositories(Id)
	, ContributorId int NOT NULL FOREIGN KEY REFERENCES Users(Id)
	PRIMARY KEY (RepositoryId, ContributorId)
	);
	
CREATE TABLE Issues(
	Id int PRIMARY KEY IDENTITY
	, Title varchar(255) NOT NULL
	, IssueStatus varchar(6) NOT NULL
	, RepositoryId int NOT NULL FOREIGN KEY REFERENCES Repositories(Id)
	, AssigneeId int NOT NULL FOREIGN KEY REFERENCES Users(Id)
	);
	
CREATE TABLE Commits(
	Id int PRIMARY KEY IDENTITY
	, Message varchar(255) NOT NULL
	, IssueId int FOREIGN KEY REFERENCES Issues(Id)
	, RepositoryId int NOT NULL FOREIGN KEY REFERENCES Repositories(Id)
	, ContributorId int NOT NULL FOREIGN KEY REFERENCES Users(Id)
	);
	
CREATE TABLE Files(
	Id int PRIMARY KEY IDENTITY
	, Name varchar(100) NOT NULL
	, [Size] decimal(20, 2) NOT NULL
	, ParentId int FOREIGN KEY REFERENCES Files(Id)
	, CommitId int NOT NULL FOREIGN KEY REFERENCES Commits(Id)
	);
	
--02. Insert
INSERT INTO Files(Name, [Size], ParentId, CommitId) VALUES
	('Trade.idk', 2598.0, 1, 1)
	, ('menu.net', 9238.31, 2, 2)
	, ('Administrate.soshy', 1246.93, 3, 3)
	, ('Controller.php', 7353.15, 4, 4)
	, ('Find.java', 9957.15, 5, 5)
	, ('Controller.json', 14034.87, 3, 6)
	, ('Operate.xix', 7662.92, 7, 7);

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId) VALUES
	('Critical Problem with HomeController.cs file', 'open', 1, 4)
	, ('Typo fix in Judge.html', 'open', 4, 3)
	, ('Implement documentation for UsersService.cs', 'closed', 8, 2)
	, ('Unreachable code in Index.cs', 'open', 9, 8);



-- 03. Update
UPDATE
	Issues
SET
	IssueStatus = 'closed'
WHERE
	AssigneeId = 6;


-- 04. Delete
DELETE
FROM
	RepositoriesContributors
WHERE
	RepositoryId = 3;

DELETE
FROM
	Issues
WHERE
	RepositoryId = 3;

DELETE
	Files
WHERE
	CommitId = 36;

DELETE
FROM
	Commits
WHERE
	RepositoryId = 3;

DELETE
FROM
	Repositories
WHERE
	Id = 3;



--05. Commits
SELECT
	Id
	, Message
	, RepositoryId
	, ContributorId
FROM
	Commits c
ORDER BY
	Id
	, Message
	, RepositoryId
	, ContributorId;


--06. Front-end
SELECT
	id, Name, [Size]
FROM
	Files f
WHERE
	[Size] > 1000
	AND Name LIKE '%html%'
ORDER BY
	[Size] DESC
	, Id
	, Name;



--07. Issue Assignment
SELECT
	i.Id
	, CONCAT(u.Username, ' : ', i.Title) AS IssueAssignee
FROM
	Issues i
JOIN Users u ON
	i.AssigneeId = u.Id
ORDER BY
	i.Id DESC
	, i.AssigneeId;


--08. Single Files
SELECT
	f.Id
	, f.Name
	, CONCAT(f.[Size], 'KB') AS [Size]
FROM
	Files f
LEFT JOIN Files p ON
	f.Id = p.ParentId
WHERE
	p.ParentId IS NULL
ORDER BY
	f.Id
	, f.Name
	, f.[Size] DESC;


--09. Commits in Repositories
SELECT
	TOP 5
	r.Id
	, r.Name
	, COUNT(r.Id) AS Commits
FROM
	Repositories r
JOIN Commits c ON
	r.Id = c.RepositoryId
JOIN RepositoriesContributors rc ON
	rc.RepositoryId = r.Id
GROUP BY
	r.Id
	, r.Name
ORDER BY
	Commits DESC
	, r.Id
	, r.Name;



--10. Average Size
SELECT
	u.Username
	, AVG(ISNULL(f.[Size], 0)) AS [Size]
FROM
	Users u
JOIN Commits c ON
	c.ContributorId = u.Id
JOIN Files f ON
	c.Id = f.CommitId
GROUP BY
	c.ContributorId
	, u.Username
ORDER BY
	AVG(f.[Size]) DESC
	, Username;



--11. All User Commits
CREATE FUNCTION udf_AllUserCommits(@username varchar(30))
RETURNS int
AS
BEGIN
	RETURN (SELECT
		COUNT(*)
	FROM
		Users u
	JOIN Commits c ON
		u.Id = c.ContributorId
	WHERE u.Username = @username)
END

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')


--12. Search for Files
CREATE OR ALTER PROC usp_SearchForFiles(@fileExtension varchar(10))
AS
BEGIN
	SELECT
		f.Id
		, f.Name
		, CONCAT(f.[Size], 'KB') AS [Size]
	FROM
		Files f
	WHERE
		f.Name LIKE CONCAT('%', @fileExtension, '%')
END

EXEC usp_SearchForFiles 'txt';
