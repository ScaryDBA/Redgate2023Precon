-- Bad or missing index
CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
INCLUDE (PostalCode)
WITH (DROP_EXISTING = ON);


/*CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
WITH (DROP_EXISTING = ON);*/


--recompiles
EXEC dbo.CustomerList @CustomerID = 7920 WITH RECOMPILE;
EXEC dbo.CustomerList @CustomerID = 30118 WITH RECOMPILE;



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
