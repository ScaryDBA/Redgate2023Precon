--restore AWS RDS database
EXEC msdb.dbo.rds_restore_database @restore_db_name = 'AdventureWorks',
                                   @s3_arn_to_restore_from = 'arn:aws:s3:::summitprecon/AdventureWorks2019.bak';


--procedure for parameter sniffing
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END;
GO

--add a comment