-- SELECTED TABLES TO USE LATER
-- a table with a single-column primary key and no foreign key
-- AnimationTechnic (PK)

-- a table with a single-column primary key and at least one foreign key;
-- Mascot (PK, FK - references studioID)

-- a table with a multicolumn primary key,
-- StudioTechnic (PK formed from two FK from studioID and technicID)


-- CREATING SOME VIEWS
-- 3 views 
-- view with a SELECT statement operating on one table

CREATE OR ALTER VIEW viewMascot
AS
    SELECT *
    FROM Mascot
GO

SELECT *
From viewMascot
GO

-- view with a SELECT statement that operates on at least 2 different tables 
-- and contains at least one JOIN operator

CREATE OR ALTER VIEW viewTechnic
AS
    SELECT S.stduioName, AniT.tecnicName, AniT.technicType
    FROM StudioTechnic ST 
    INNER JOIN AnimationTechnic AniT ON ST.technicID = AniT.techID
    INNER JOIN Studio S ON St.studioID = s.studioID
GO

SELECT *
From viewTechnic
GO

-- view with a SELECT statement that has a GROUP BY clause,
-- operates on at least 2 different tables and contains at least one JOIN operator.

CREATE OR ALTER VIEW viewMacsotPerStudio
AS
    SELECT S.studioID, COUNT(*) AS 'Nr of Mascots per studio'
    FROM Mascot M
    LEFT JOIN  Studio S ON M.studioID = s.studioID
    GROUP BY S.studioID
GO

SELECT *
From viewMacsotPerStudio
GO


-- Insert into the tables needed for the testing
DELETE FROM Tables
INSERT INTO Tables (Name)
VALUES ('Mascot'), ('AnimationTechnic'), ('StudioTechnic')

DELETE FROM Views
INSERT INTO Views (Name)
VALUES ('viewMascot'), ('viewTechnic'), ('viewMacsotPerStudio')

DELETE FROM Tests
INSERT INTO Tests (Name)
VALUES ('Test_1'), ('Test_2'), ('Test_3')

DELETE FROM TestTables
INSERT INTO TestTables VALUES (1011, 1011, 100, 1)
INSERT INTO TestTables VALUES (1012, 1013, 100, 1)
INSERT INTO TestTables VALUES (1012, 1012, 100, 2)
INSERT INTO TestTables VALUES (1013, 1011, 100, 3)
INSERT INTO TestTables VALUES (1013, 1013, 100, 1)
INSERT INTO TestTables VALUES (1013, 1012, 100, 2)

DELETE FROM TestViews
INSERT INTO TestViews VALUES (1011, 1011)
INSERT INTO TestViews VALUES (1013, 1012)
INSERT INTO TestViews VALUES (1013, 1013)
GO


-- Inserting into specific tables we have
-- CREATE OR ALTER PROC insertIntoMascot (@nrRows INT)
-- AS
--     DECLARE @check INT = 1
--     DECLARE @mascotName VARCHAR(20)
--     WHILE @check <= @nrRows
--     BEGIN
--         SET @mascotName = 'mascot ex.' + CAST(@check AS varchar(5)) 
--         INSERT INTO Mascot VALUES
--         (11 + @check, @mascotName, '1990-01-10', 100)
--         SET @check = @check + 1
--     END
-- GO


-- CREATE OR ALTER PROC insertIntoAnimationTechnic (@nrRows INT)
-- AS
--     DECLARE @check INT = 1
--     WHILE @check <= @nrRows
--     BEGIN
--         INSERT INTO AnimationTechnic VALUES
--         (14 + @check, 'technic name ex.', 'electronic')
--         SET @check = @check + 1
--     END
-- GO


-- CREATE OR ALTER PROC insertIntoStudioTechnic (@nrRows INT)
-- AS
--     DECLARE @check INT = 1
--     WHILE @check <= @nrRows
--     BEGIN
--         INSERT INTO StudioTechnic VALUES
--         (100, 14 + @check)
--         SET @check = @check + 1
--     END
-- GO

CREATE OR ALTER PROC InsertIntoTable(@tableName varchar(50), @nrRows INT)
AS
    DECLARE @check INT = 1

    IF @tableName = 'StudioTechnic'
        WHILE @check <= @nrRows
        BEGIN
            INSERT INTO StudioTechnic VALUES
            (100, 14 + @check)
            SET @check = @check + 1
        END
    
    IF @tableName = 'AnimationTechnic'
        WHILE @check <= @nrRows
        BEGIN
            INSERT INTO AnimationTechnic VALUES
            (14 + @check, 'technic name ex.', 'electronic')
            SET @check = @check + 1
        END

    IF @tableName = 'Mascot'
        DECLARE @mascotName VARCHAR(20)
        WHILE @check <= @nrRows
        BEGIN
            SET @mascotName = 'mascot ex.' + CAST(@check AS varchar(5)) 
            INSERT INTO Mascot VALUES
            (11 + @check, @mascotName, '1990-01-10', 100)
            SET @check = @check + 1
        END
GO



-- General procedures needed for testing

-- View views depending on their name
CREATE OR ALTER PROC SelectView (@viewName VARCHAR(50), @runTimeId INT)
AS
    DECLARE @startTime DATETIME
    DECLARE @endTime DATETIME

    SET @startTime = GETDATE()
    DECLARE @viewQuery NVARCHAR(100) = N'SELECT * FROM '  + @viewName
	EXEC sp_executesql @viewQuery
    SET @endTime = GETDATE()

    PRINT @viewQuery
    DECLARE @viewId INT = (
        SELECT ViewID
        FROM Views
        WHERE Name = @viewName
    )
    INSERT INTO TestRunViews VALUES (@runTimeId, @viewId, @startTime, @endTime)
GO


-- Insert into some general table
CREATE OR ALTER PROC InsertGeneral(@tableID INT, @testID INT, @runTimeId INT)
AS
    DECLARE @startTime DATETIME
    DECLARE @endTime DATETIME

    SET @startTime = GETDATE()
    DECLARE @tableName VARCHAR(50)
    SET @tableName = 
    (
        SELECT Name
        FROM Tables
        WHERE TableID = @tableID
    )

    DECLARE @nrRows INT
    SET @nrRows = 
    (
        SELECT NoOfRows
        FROM TestTables
        WHERE TableID = @tableID AND TestID = @testID
    )
    EXEC InsertIntoTable @tableName, @nrRows
    SET @endTime = GETDATE() 
    DECLARE @function NVARCHAR(200)
    SET @function = N'insert into ' + @tableName + ' ' + CAST(@nrRows as NVARCHAR(10))
    PRINT @function
    INSERT INTO TestRunTables VALUES (@runTimeId, @tableID, @startTime, @endTime)
GO


-- Delete from some general table
CREATE OR ALTER PROC DeleteGeneral(@tableID INT, @runTimeId INT)
AS
    DECLARE @tableName VARCHAR(50)
    SET @tableName = 
    (
        SELECT Name
        FROM Tables
        WHERE TableID = @tableID
    )
    DECLARE @function NVARCHAR(200)
    SET @function = N'DELETE FROM ' + @tableName
    EXEC sp_executesql @function
    PRINT @function
GO




-- 1. function that selects from created views (any, gets view name as parameter) v
-- 2. for now create function of insert and delete for the 3 tables i have v
-- 3. make a big function RunTest that gets send a testId and runs it 
-- 4. function that runs all tests as well would be good
-- 5. find out what it means to make it able to extend to new tables/views (views work, tables questionable) ?


CREATE OR ALTER PROC RunTest(@testID INT)
AS
    SET NOCOUNT ON
    PRINT N'Doing test with id ' + CAST(@testID as NVARCHAR(10))

    DECLARE @startTime DATETIME
    DECLARE @endTime DATETIME
    INSERT INTO TestRuns VALUES (NULL, NULL, NULL)
    DECLARE @runTimeId INT = @@IDENTITY

    SET @startTime = GETDATE()
    PRINT 'Deleting from table'
    DECLARE @tableID INT
    DECLARE cursorForDelete cursor local FOR
        SELECT TableID
        FROM TestTables 
        WHERE TestID = @testID
        ORDER BY [Position] ASC

    OPEN cursorForDelete
    FETCH cursorForDelete INTO @tableID
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC DeleteGeneral @tableID, @runTimeId
        FETCH NEXT FROM cursorForDelete INTO @tableID
    END
    CLOSE cursorForDelete

    PRINT 'Inserting into table'
    DECLARE cursorForInsert cursor local FOR
        SELECT TableID
        FROM TestTables 
        WHERE TestID = @testID
        ORDER BY [Position] DESC

    OPEN cursorForInsert
    FETCH cursorForInsert INTO @tableID
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC InsertGeneral @tableID, @testID, @runTimeId
        FETCH NEXT FROM cursorForInsert INTO @tableID
    END
    CLOSE cursorForInsert


    PRINT 'Selecting from views'
    DECLARE @viewName VARCHAR(50)
    DECLARE cursorForViews cursor local FOR
        SELECT V.Name
        FROM TestViews TV INNER JOIN Views V ON TV.ViewID = V.ViewID
        WHERE TestID = @testID

    OPEN cursorForViews
    FETCH cursorForViews INTO @viewName
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SelectView @viewName, @runTimeId
        FETCH NEXT FROM cursorForViews INTO @viewName
    END
    CLOSE cursorForViews
    SET @endTime = GETDATE()

    UPDATE TestRuns
    SET [Description] = N'Gone through test with id ' + CAST(@testID AS nvarchar(20))
    WHERE TestRunID = @runTimeId

    UPDATE TestRuns
    SET [StartAt] = @startTime
    WHERE TestRunID = @runTimeId

    UPDATE TestRuns
    SET [EndAt] = @endTime
    WHERE TestRunID = @runTimeId
GO


EXEC RunTest 1013
SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews

DELETE FROM TestRuns
DELETE FROM TestRunTables
DELETE FROM TestRunViews



SELECT *
FROM AnimationTechnic
SELECT *
FROM StudioTechnic

SELECT * FROM Tables
SELECT * FROM Tests
SELECT * FROM Views
SELECT * FROM TestViews
SELECT * FROM TestTables



















------------------

SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE table_catalog = 'master'
   AND table_name = 'Studio'


SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'StudioTechnic'


-- check for primary key ??? (mostly make all int unique in the tables)
-- check for uniqueness (&& constraints ???)
-- check for foreign key
SELECT name
From sys.tables
where object_id IN (
    select referenced_object_id from sys.foreign_keys
    where parent_object_id = OBJECT_ID('Mascot')
 )

-- slected all unique columns
SELECT K.name, C.name 
FROM sys.key_constraints K INNER JOIN sys.columns C ON K.parent_object_id = C.object_id
where type = 'UQ' 

select *
from sys.check_constraints