DROP TABLE Ta
CREATE TABLE Ta(
    aid INT PRIMARY KEY,
    a2 INT UNIQUE,
    a3 INT
);

CREATE TABLE Tb(
    bid INT PRIMARY KEY,
    b2 INT
);

DROP TABLE Tc
CREATE TABLE Tc(
    cid INT PRIMARY KEY,
    aidF INT FOREIGN KEY REFERENCES Ta(aid),
    bidF INT FOREIGN KEY REFERENCES Tb(bid)
);
GO

--- Inserting into table TA
CREATE OR ALTER PROC insertIntoTa (@nrRows INT)
AS
    DECLARE @check INT = 1
    WHILE @check <= @nrRows
    BEGIN
        INSERT INTO Ta VALUES
        (10 + @check, @check, @check + 3)
        SET @check = @check + 1
    END
GO

EXEC insertIntoTa 1000

SELECT * FROM Ta
GO

--- Inserting into table TB
CREATE OR ALTER PROC insertIntoTb (@nrRows INT)
AS
    DECLARE @check INT = 1
    WHILE @check <= @nrRows
    BEGIN
        INSERT INTO Tb VALUES
        (@check, @check + 5)
        SET @check = @check + 1
    END
GO

EXEC insertIntoTb 1000

SELECT * FROM Tb
GO

--- Inserting into table TC
CREATE OR ALTER PROC insertIntoTC (@nrRows INT)
AS
    DECLARE @check INT = 1
    WHILE @check <= @nrRows
    BEGIN
        INSERT INTO Tc VALUES
        (100 + @check, 10 + @check, @check)
        SET @check = @check + 1
    END
GO

EXEC insertIntoTc 1000

SELECT * FROM Tc


-- a) Write queries on Ta such that their execution plans contain the following operators:
-- clustered index scan
SELECT *
FROM Ta
ORDER BY aid DESC

-- clustered index seek
SELECT *
FROM Ta
WHERE aid > 50 and aid < 100


-- nonclustered index scan
SELECT a2 
FROM Ta

-- nonclustered index seek
SELECT a2
FROM Ta
WHERE a2 < 5

-- key lookup
SELECT aid, a3
FROM Ta
WHERE a2 = 100

-- b)
GO 
DROP INDEX Idx_NC_b2 ON Tb
GO

SELECT *
FROM Tb
WHERE b2 = 25

CREATE NONCLUSTERED INDEX Idx_NC_b2 ON Tb(b2)
GO

-- c)
CREATE OR ALTER VIEW TbTc
AS
    SELECT Tb.b2, Tc.cid
    FROM Tb INNER JOIN Tc ON Tb.bid = Tc.bidf
    where b2 > 500
GO

SELECT * FROM TbTc

