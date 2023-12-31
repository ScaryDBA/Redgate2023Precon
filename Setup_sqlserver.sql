DROP DATABASE IF EXISTS AdventureWorks;


--restore AWS RDS database
EXEC msdb.dbo.rds_restore_database @restore_db_name = 'AdventureWorks',
                                   @s3_arn_to_restore_from = 'arn:aws:s3:::summitprecon/AdventureWorks2019.bak';


--EXEC msdb.dbo.rds_restore_database @restore_db_name = 'AdventureWorksJSON',
--                                   @s3_arn_to_restore_from = 'arn:aws:s3:::summitprecon/AdventureWorksDW2016_EXT.bak';

EXEC msdb.dbo.rds_restore_database @restore_db_name = 'AdventureWorksJSON',
                                   @s3_arn_to_restore_from = 'arn:aws:s3:::summitprecon/AdventureWorks2016_EXT.bak';


USE AdventureWorks;
Go

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


CREATE OR ALTER PROCEDURE dbo.AddressIdByCity @City NVARCHAR(30)
AS
SELECT a.AddressID
FROM Person.Address AS a
WHERE City = @City;
GO



CREATE OR ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
AS
SELECT a.AddressID,
       a.AddressLine1,
       a.AddressLine2,
       a.City,
       sp.Name AS StateProvinceName,
       a.PostalCode
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE a.City = @City;
go



ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
go


CREATE OR ALTER PROCEDURE dbo.CustomerList @CustomerID INT
AS
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= @CustomerID
OPTION (OPTIMIZE FOR (@CustomerID = 1));
GO


DROP TABLE IF EXISTS dbo.BlockTest;
GO
CREATE TABLE dbo.BlockTest
(
    C1 INT,
    C2 INT,
    C3 DATETIME
);
INSERT INTO dbo.BlockTest
VALUES
(11, 12, GETDATE()),
(21, 22, GETDATE());
