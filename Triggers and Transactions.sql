--03. Deposit Money
CREATE or ALTER PROC usp_DepositMoney(@AccountId int, @MoneyAmount money)
AS
BEGIN
BEGIN TRANSACTION
        UPDATE Accounts
           SET Balance += @MoneyAmount
         WHERE Id = @AccountId
         IF (@@ROWCOUNT <> 1)
         BEGIN
         	ROLLBACK
         	RAISERROR ('Invalid account!', 16, 1)
         	RETURN
         END
    COMMIT
END


--04. Withdraw Money Procedure
CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN 
	BEGIN TRANSACTION 
	UPDATE Accounts SET Balance -= @MoneyAmount
	WHERE Id  = @AccountId
	IF @@ROWCOUNT <> 1
	BEGIN
		ROLLBACK 
		RAISERROR ('Invalid account', 1, 1)
		RETURN 
	END
	COMMIT 
END


exec usp_WithdrawMoney 5, 25;

select * from Accounts a ;



--05. Money Transfer
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS 
BEGIN 
	BEGIN TRANSACTION 
	IF @Amount <= 0
	BEGIN 
		ROLLBACK 
		RAISERROR ('INVALID AMOUNT', 16, 1)
		RETURN
	END
	EXEC usp_DepositMoney @ReceiverId, @Amount
	EXEC usp_WithdrawMoney @SenderId, @Amount
	COMMIT 
END


-- == [Part II - Queries for Diablo Database] == --
USE Diablo;

--06. Trigger

--07. *Massive Shopping


-- == [Part III - Queries for SoftUni Database] == --
USE SoftUni


--08. Employees with Three Projects
CREATE OR ALTER PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS 
BEGIN 
	BEGIN TRANSACTION
    DECLARE @EmployeeProjects INT
    SET @EmployeeProjects = (SELECT COUNT(ep.ProjectID)
                               FROM EmployeesProjects ep
                              WHERE ep.EmployeeID = @emloyeeId)
    IF (@EmployeeProjects >= 3)
    BEGIN
        RAISERROR('The employee has too many projects!', 16, 1)
        ROLLBACK
        RETURN
    END
    INSERT INTO EmployeesProjects
          VALUES (@emloyeeId, @projectID)
    COMMIT
END



-- 09. Delete Employees
CREATE TABLE Deleted_Employees(
    EmployeeId INT IDENTITY PRIMARY KEY
    , FirstName NVARCHAR(50)
    , LastName NVARCHAR(50)
    , MiddleName NVARCHAR(50)
    , JobTitle NVARCHAR(50)
    , DepartmentId INT
    , Salary MONEY
);

CREATE OR ALTER TRIGGER tr_OnDeletedEmployee
ON Employees FOR DELETE
AS
    INSERT INTO Deleted_Employees
    SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary
    FROM deleted;




