--#1
SELECT test.tPerson.name, test.tOrg.name
FROM test.tPerson LEFT OUTER JOIN test.tOrg
ON test.tOrg.oid = test.tPerson.oid
GO

--#2
SELECT test.tOrg.name, test.tOrg.oid
FROM test.tPerson RIGHT OUTER JOIN test.tOrg
ON test.tOrg.oid = test.tPerson.oid
WHERE test.tPerson.name is NULL
GO

--#3.1
SELECT test.tOrg.name, COUNT(*)
FROM test.tPerson JOIN test.tOrg
ON test.tOrg.oid = test.tPerson.oid
GROUP BY test.tOrg.oid, test.tOrg.name
GO
--#3.2
SELECT test.tOrg.name, COUNT(test.tPerson.oid)
FROM test.tPerson RIGHT OUTER JOIN test.tOrg
ON test.tOrg.oid = test.tPerson.oid
GROUP BY test.tPerson.oid, test.tOrg.name
GO

--#4
DROP FUNCTION [dbo].[getFullOrgName]
GO

CREATE FUNCTION getFullOrgName(@oid AS INT) 
RETURNS NVARCHAR(MAX) 
AS 
BEGIN
    DECLARE @FullOrgName NVARCHAR(MAX);
    DECLARE @ParentOrgName NVARCHAR(MAX);
    DECLARE @Poid AS INT;
    SELECT @FullOrgName = '/' + test.tOrg.name FROM test.tOrg WHERE test.tOrg.oid = @oid;
    SELECT @Poid = test.tOrg.poid FROM test.tOrg WHERE test.tOrg.oid = @oid;
    WHILE @Poid IS NOT NULL
    BEGIN
        SELECT @ParentOrgName = '/' + test.tOrg.name FROM test.tOrg WHERE test.tOrg.oid = @Poid;
        SELECT @FullOrgName = @ParentOrgName + @FullOrgName;
        SELECT @Poid = test.tOrg.poid FROM test.tOrg WHERE test.tOrg.oid = @Poid;
    END
    RETURN @FullOrgName;
END;
GO

SELECT TestDB.dbo.getFullOrgName(9) -- TestDB - название БД 
GO

-- #5 
-- 1-вариант форматировать excel файл в формат csv и воспользоваться BULK INSERT 
-- 2-вариант использовать SQL Server Integration Services (SSIS), который использует для потока данных источник Excel и назначение SQL Server 
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

BULK INSERT test.tAccountRest  
FROM '/home/abiba/WorckSpace/sql/test1/№5.csv'
   WITH (
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n'
);
GO
SELECT * FROM test.tAccountRest;
GO

-- #6
SELECT test.tAccount.accNumber, test.tAccountRest.stDate, test.tAccountRest.balance
FROM test.tAccount FULL OUTER JOIN test.tAccountRest
ON test.tAccount.aid = test.tAccountRest.aid 
WHERE test.tAccountRest.stDate IN 
    (SELECT MAX(test.tAccountRest.stDate) 
    FROM test.tAccount FULL OUTER JOIN test.tAccountRest
    ON test.tAccount.aid = test.tAccountRest.aid 
    GROUP BY test.tAccount.aid) 
OR test.tAccountRest.stDate IS NULL
GO

-- #7
DROP TABLE test.PDCL
GO
CREATE TABLE test.PDCL (
    pdDate	datetime,
    cid int,
    did int,
    Currency nvarchar(20),
    pdSum int,
    PRIMARY KEY(did, pdDate) 
)
GO

INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('12.12.2009', 111110, 111111, 'RUR', 12000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('25.12.2009', 111110, 111111, 'RUR', 5000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('12.12.2009', 111110, 122222, 'RUR', 10000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('12.01.2010', 111110, 111111, 'RUR', -10100);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('20.11.2009', 220000, 222221, 'RUR', 25000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('20.12.2009', 220000, 222221, 'RUR', 20000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('21.12.2009', 220000, 222221, 'RUR', -25000);
INSERT INTO test.PDCL (pdDate,cid,did,Currency,pdSum) VALUES ('29.12.2009', 111110, 122222, 'RUR', -10000);
GO


SELECT 
    did, 
    SUM(pdSum) AS sum, 
    MIN(pdDate) AS startDate, 
    DATEDIFF(dayofyear, MIN(pdDate), MAX(pdDate)) AS delayDays
FROM test.PDCL
GROUP BY did
HAVING SUM(test.PDCL.pdSum) > 0
GO
