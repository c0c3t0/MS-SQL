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
