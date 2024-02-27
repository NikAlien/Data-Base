-- a) change type of coloumn
CREATE OR ALTER PROCEDURE alterTypeColumn
AS
BEGIN
    ALTER TABLE Studio
    ALTER COLUMN nrEmployees VARCHAR(20)
    PRINT 'Altered coloumn nr employes, table studio, from INT to VARCHAR'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE undoAlterType
AS
BEGIN
    ALTER TABLE Studio
    ALTER COLUMN nrEmployees INT
    PRINT 'Altered coloumn nr employes, table studio, from VARCHAR to INT'
END
GO


-- b) add a coloumn
CREATE OR ALTER PROCEDURE addColumnToStudio
AS
BEGIN
    ALTER TABLE Studio
    ADD TestColumn INT
    PRINT 'Added new column as TestColumn INT'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE removeColumnToStudio
AS
BEGIN
    ALTER TABLE Studio
    DROP COLUMN TestColumn
    PRINT 'Removed the column TestColumn'
END
GO


-- c) add a DEFAULT constraint
CREATE OR ALTER PROCEDURE addDefaultConstraint
AS
BEGIN
    ALTER TABLE Studio
    ADD CONSTRAINT defaultNrEmploy DEFAULT 'lol' FOR nrEmployees
    PRINT 'Added DEFAULT constraint for nrEmployees'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE removeDefaultConstraint
AS
BEGIN
    ALTER TABLE Studio
    DROP CONSTRAINT defaultNrEmploy
    PRINT 'Removed DEFAULT constraint from nrEmployees'
END
GO


-- d) remove a PRIMARY key
CREATE OR ALTER PROCEDURE removePK
AS
BEGIN
    ALTER TABLE ProjectPlatform
    DROP PK_ProjectP
    PRINT 'Remove PRIMARY key of ProjectPlatform'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE addPK
AS
BEGIN
    ALTER TABLE ProjectPlatform
    ADD CONSTRAINT PK_ProjectP PRIMARY KEY (platformID, projectID)
    PRINT 'Add PRIMARY key to ProjectPlatform'
END
GO


-- e) add a CANDIDATE key
CREATE OR ALTER PROCEDURE addCandidateKey
AS
BEGIN
    ALTER TABLE Studio
    ADD CONSTRAINT UniqueStudioName UNIQUE(stduioName)
    PRINT 'Made column studioName unique'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE removeCandidateKey
AS
BEGIN
    ALTER TABLE Studio
    DROP CONSTRAINT UniqueStudioName
    PRINT 'Removed constraint column studioName unique'
END
GO


-- f) remove a FOREIGN key
CREATE OR ALTER PROCEDURE removeFK
AS
BEGIN
    ALTER TABLE Director
    DROP FK__studioID
    PRINT 'Removed FK studioID from Director'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE addFK
AS
BEGIN
    ALTER TABLE Director
    ADD CONSTRAINT FK__studioID FOREIGN KEY(studioID) REFERENCES Studio(studioID)
    PRINT 'Added FK studioID to Director'
END
GO


-- g) create a new table
CREATE OR ALTER PROCEDURE createNewTable
AS
BEGIN
    CREATE TABLE TestTable(
        testID INT PRIMARY KEY,
        testName VARCHAR(20),
        testType VARCHAR(50)
    )
    PRINT 'Created a new table'
END
GO

-- undo 
CREATE OR ALTER PROCEDURE dropTheNewTable
AS
BEGIN
    DROP TABLE TestTable
    PRINT 'Dropped TABLE TestTable'
END
GO



-- Tables necessary for going through each version
-- CurrentStatus - keeps an integer that represents the current version of our data base
-- StoredProcedure - keeps all the necessary procedures to go back and forth through the versions

DROP TABLE CurrentStatus
CREATE TABLE CurrentStatus(
    currentVersion INT
)

INSERT INTO CurrentStatus (currentVersion) VALUES (0)

DROP TABLE StoredProcedure
CREATE TABLE StoredProcedure(
    ToDoFunction VARCHAR(50) UNIQUE,
    ToUndoFunction VARCHAR(50) UNIQUE,
    versionNr INT
)
GO


-- Procedure that could be used to insert further procedures to create more version of our data base

CREATE OR ALTER PROCEDURE insertProcedures(@toDo VARCHAR(50), @toUndo VARCHAR(50))
AS
BEGIN
    DECLARE @nrOfProcedure INT = 0
    SELECT @nrOfProcedure = COUNT(*)
    FROM StoredProcedure

    SET @nrOfProcedure = @nrOfProcedure + 1

    INSERT INTO StoredProcedure (ToDoFunction, ToUndoFunction, versionNr) VALUES (@toDo, @toUndo, @nrOfProcedure)

END
GO

EXEC insertProcedures 'alterTypeColumn', 'undoAlterType'
EXEC insertProcedures 'addColumnToStudio', 'removeColumnToStudio'
EXEC insertProcedures 'addDefaultConstraint', 'removeDefaultConstraint'
EXEC insertProcedures 'removePK', 'addPK'
EXEC insertProcedures 'addCandidateKey', 'removeCandidateKey'
EXEC insertProcedures 'removeFK', 'addFK'
EXEC insertProcedures 'createNewTable', 'dropTheNewTable'

SELECT *
FROM StoredProcedure
GO


-- Procedure that goes through the versions depending what int we wanted 

CREATE OR ALTER PROCEDURE goToVersion(@version  INT)
AS
BEGIN
    
    -- Find out how many procedures we have 
    DECLARE @nrOfProcedure INT = 0
    SELECT @nrOfProcedure = COUNT(*)
    FROM StoredProcedure

    IF @version < 0 OR @version > @nrOfProcedure
        BEGIN
            PRINT('Error, version nr given does not satisfy the constraints')
            RETURN
        END
    ELSE
        BEGIN
            DECLARE @procedureToDo VARCHAR(50)
            DECLARE @currentVersion INT
            SET @currentVersion = (SELECT currentVersion FROM CurrentStatus)

            WHILE @version < @currentVersion 
                BEGIN
                    SET @procedureToDo = (
                        SELECT ToUndoFunction
                        FROM StoredProcedure
                        WHERE versionNr = @currentVersion
                    )
                    EXEC @procedureToDo
                    SET @currentVersion = @currentVersion - 1
                END

            WHILE @version > @currentVersion
                BEGIN
                    SET @procedureToDo = (
                        SELECT ToDoFunction
                        FROM StoredProcedure
                        WHERE versionNr = @currentVersion + 1
                    )
                    EXEC @procedureToDo
                    SET @currentVersion = @currentVersion + 1
                END

            UPDATE CurrentStatus
            SET currentVersion = @currentVersion

            PRINT '--- Updated the current version ---'
		    PRINT 'Version: ' + CAST(@currentVersion as NVARCHAR(10))
        END
        
END
GO


EXEC goToVersion 0
EXEC goToVersion 3
EXEC goToVersion -1
EXEC goToVersion 2
EXEC goToVersion 5
EXEC goToVersion 7
EXEC goToVersion 0