-- Bad or missing index
CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
INCLUDE (PostalCode)
WITH (DROP_EXISTING = ON);

EXEC dbo.AddressByCity @City = N'New York' -- nvarchar(30)



/*CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
WITH (DROP_EXISTING = ON);*/


--recompiles
EXEC dbo.CustomerList @CustomerID = 7920 WITH RECOMPILE;
EXEC dbo.CustomerList @CustomerID = 30118 WITH RECOMPILE;
GO 100



CREATE OR ALTER PROCEDURE dbo.CustomerList @CustomerID INT
AS
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= @CustomerID;
--OPTION (OPTIMIZE FOR (@CustomerID = 1));





--parameter sniffing
SELECT COUNT(*) refcount,
       th.ReferenceOrderID
FROM Production.TransactionHistory AS th
GROUP BY th.ReferenceOrderID
ORDER BY refcount DESC;


EXEC dbo.ProductTransactionHistoryByReference
    @referenceorderid = 53465;


DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO
EXEC dbo.ProductTransactionHistoryByReference
    @referenceorderid = 53465;


EXEC dbo.ProductTransactionHistoryByReference
    @ReferenceOrderID = 48603;


--columnstore
SELECT bp.NAME AS ProductName,
       COUNT(bth.ProductID),
       SUM(bth.Quantity),
       AVG(bth.ActualCost)
FROM dbo.bigProduct AS bp
    JOIN dbo.bigTransactionHistory AS bth
        ON bth.ProductID = bp.ProductID
GROUP BY bp.NAME;





CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON dbo.bigTransactionHistory (
                                 ProductID,
                                 Quantity,
                                 ActualCost
                             );




DROP INDEX dbo.bigTransactionHistory.ix_csTest;


GO
--JSON
USE AdventureWorksJSON
GO
EXEC Sales.SalesOrderSearchByCustomer_json 'Joe Rana'
EXEC Person.PersonSearchByEmail_json 'ken0@adventure-works.com'
EXEC Sales.SalesOrderSearchByReason_json 'Price'


CREATE INDEX idx_SalesOrder_json_CustomerName
	ON Sales.SalesOrder_json(vCustomerName)
go







-- Blocking
--First connection, executed first
BEGIN TRAN User1;
UPDATE dbo.BlockTest
SET C3 = GETDATE();
--rollback transaction

--Second connection, executed second
BEGIN TRAN User2;
SELECT C2
FROM dbo.BlockTest
WHERE C1 = 11;
COMMIT;


EXEC sp_who2




BEGIN TRAN
UPDATE Person.Address
SET AddressLine2 = '1313 Mockingbird Lane'
WHERE AddressID = 42;

UPDATE Person.AddressType
SET Name = 'Seattle'
WHERE AddressTypeID = 1;
ROLLBACK TRAN
