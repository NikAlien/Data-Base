CREATE TABLE Studio(
    studioID INT PRIMARY KEY,
    stduioName VARCHAR(20),
    studioLocation VARCHAR(50),
    startActivity DATE,
    nrEmployees INT
);

CREATE TABLE Director(
    directorID INT PRIMARY KEY,
    directorName VARCHAR(30),
    startActivity DATE,
    studioID INT FOREIGN KEY REFERENCES Studio(studioID)
);

CREATE TABLE Project(
    projectID INT PRIMARY KEY,
    projectName VARCHAR(30),
    projectType VARCHAR(10) CHECK (projectType in ('movie', 'series')),
    genre VARCHAR(15),
    rottenTomatoRating DECIMAL(3,2),
    imdbRating DECIMAL(3,2),
    directorID INT FOREIGN KEY REFERENCES Director(directorID)
);

CREATE TABLE Mascot(
    mascotID INT PRIMARY KEY,
    mascotName VARCHAR(20) UNIQUE,  
    creationYear DATE,
    studioID INT FOREIGN KEY REFERENCES Studio(studioID)
);

CREATE TABLE Award(
    awardID INT PRIMARY KEY,
    awardName VARCHAR(30),
    startYear DATE,
    nrCategories INT,
    awardingCeremonyDate DATE UNIQUE
);

CREATE TABLE WinningAwards (
    projectID INT FOREIGN KEY REFERENCES Project(projectID),
    awardID INT FOREIGN KEY REFERENCES Award(awardID),
    PRIMARY KEY(projectID, awardID),
    categoryName VARCHAR(30),
    winningYear DATE
);

CREATE TABLE StreamingPlatform(
    platformID INT PRIMARY KEY,
    platformName VARCHAR(30),
    platformType VARCHAR(14) CHECK (platformType in ('online', 'tv station')),
    nrUsers INT
);

CREATE TABLE ProjectPlatform(
    platformID INT FOREIGN KEY REFERENCES StreamingPlatform(platformID),
    projectID INT FOREIGN KEY REFERENCES Project(projectID),
    PRIMARY KEY (platformID, projectID),
    startDate DATE
);

CREATE TABLE AnimationTechnic(
    techID INT PRIMARY KEY,
    tecnicName VARCHAR(30),
    technicType VARCHAR(15) CHECK (technicType in ('electronic', 'traditional'))
);

CREATE TABLE StudioTechnic(
    studioID INT FOREIGN KEY REFERENCES Studio(studioID),
    technicID INT FOREIGN KEY REFERENCES AnimationTechnic(techID),
    PRIMARY KEY (studioID, technicID)
);
