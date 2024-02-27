-- 2 queries with the union operation
-- UNION [ALL] and OR

-- Select projects that are adventure (genre) or Imdb rating >= 8.00
SELECT projectName
FROM Project
WHERE genre LIKE 'adventure'
UNION
SELECT projectName
FROM Project
WHERE imdbRating >= 8.00;

-- Select projects that start with letter 'M' ot the series that are horror
SELECT projectName
FROM Project
WHERE (projectName LIKE 'M%') OR (projectType = 'series' and genre = 'horror')
ORDER by projectName;



-- 2 queries with the intersection operation
-- INTERSECT and IN

-- Select studios from USA with > 2500 employess, and see a possibility for an employee increase with 10%
SELECT stduioName, nrEmployees = nrEmployees + nrEmployees * 0.1
FROM Studio
WHERE studioLocation = 'USA'
INTERSECT
SELECT stduioName, nrEmployees = nrEmployees + nrEmployees * 0.1
FROM Studio
WHERE nrEmployees < 2500;

-- Select series that can be viewed online and ordered by their rating
SELECT projectName, genre, rottenTomatoRating
FROM Project
WHERE projectType = 'series' and projectID IN (
    SELECT PP.projectID
    FROM ProjectPlatform PP, StreamingPlatform S
    WHERE PP.platformID = S.platformID and S.platformType = 'online'
)
ORDER BY rottenTomatoRating desc;



-- 2 queries with the difference operation
-- EXCEPT and NOT IN;

-- Select top 3 platforms that are online with > 1 000 000 users, and see what would happen if half where to unsubscribe
SELECT TOP 3 platformName, nrUsers = nrUsers - nrUsers / 2
FROM StreamingPlatform
WHERE platformType = 'online'
EXCEPT
SELECT platformName, nrUsers = nrUsers - nrUsers / 2
FROM StreamingPlatform
WHERE nrUsers < 1000000
ORDER BY nrUsers DESC;

-- Select top 3 series by average rating without the superhero genre
SELECT TOP 3 projectName, (rottenTomatoRating  + imdbRating) / 2 AS 'Rating'
FROM Project
WHERE projectType = 'series' and genre NOT IN ('superhero')
ORDER BY Rating desc;



-- 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator)
-- one query will join at least 3 tables, while another one will join at least two many-to-many relationships

-- Select platforms on which we have award winning projects, and see what they won 
SELECT distinct SP.platformName, P.projectName, A.awardName
FROM StreamingPlatform SP
INNER JOIN ProjectPlatform PP ON SP.platformID = PP.platformID
INNER JOIN Project P ON P.projectID = PP.projectID
INNER JOIN WinningAwards WA ON WA.projectID = P.projectID
INNER JOIN Award A ON WA.awardID = A.awardID;

-- See which studio which project they have
SELECT S.stduioName, P.projectName
FROM Studio S
LEFT JOIN Director D ON D.studioID = S.studioID
LEFT JOIN Project P ON D.directorID = P.directorID;

-- See which technic where it's used
SELECT S.stduioName, A.tecnicName
FROM Studio S
RIGHT JOIN StudioTechnic ST ON ST.studioID = S.studioID
RIGHT JOIN AnimationTechnic A ON A.technicID = ST.technicID;

-- Studios that created series
SELECT Distinct S.stduioName
FROM Studio S 
FULL JOIN Director D ON S.studioID = D.studioID
FULL JOIN Project P ON P.directorID = D.directorID
WHERE P.projectType = 'series';



-- 2 queries with the IN operator and a subquery in the WHERE clause
-- in at least one case, the subquery must include a subquery in its own WHERE clause

-- Select platform that has movies on it
SELECT platformName
FROM StreamingPlatform
WHERE platformID IN (
    SELECT PP.platformID
    FROM Project P, ProjectPlatform PP
    WHERE P.projectType = 'movie' and P.projectID = PP.projectID
)

-- Select directors that have won awards for their projects after year 2000
SELECT directorName
FROM Director
WHERE directorID IN (
    SELECT directorID
    FROM Project
    WHERE projectID IN (
        SELECT projectID
        FROM WinningAwards
        WHERE winningYear LIKE '20%'
    )
);



-- 2 queries with the EXISTS operator and a subquery in the WHERE clause

-- Select studios that have mascots
SELECT S.stduioName
FROM Studio S
WHERE EXISTS (
    SELECT M.studioID
    FROM Mascot M
    WHERE M.studioID = S.studioID
);

-- Select studios that use 3DCG or Motion Capture
SELECT s.stduioName
FROM Studio S
WHERE EXISTS (
    SELECT ST.studioID
    FROM AnimationTechnic A, StudioTechnic ST 
    WHERE (A.technicID = ST.technicID and (A.tecnicName = '3DCG' OR A.tecnicName = 'Motion Capture')) and ST.studioID = S.studioID
);



-- 2 queries with a subquery in the FROM clause

-- Select  which directors created series with any of the ratings >= 9.00
SELECT directorName
FROM Director D INNER JOIN (
    SELECT *
    FROM Project
    WHERE projectType = 'series' and (rottenTomatoRating >= 9.00 OR imdbRating >= 9.00)
) P
ON D.directorID = P.directorID;

-- Select studios with mascots
SELECT stduioName, mascotName
FROM Studio S INNER JOIN (
    SELECT *
    FROM Mascot
    WHERE creationYear LIKE '19%'
) M
ON S.studioID = M.studioID;



-- 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause
-- 2 of the latter will also have a subquery in the HAVING clause
-- use the aggregation operators: COUNT, SUM, AVG, MIN, MAX

-- How many directors from each contry
SELECT S.studioLocation, COUNT(*) AS 'NrDirectorsPerCountry'
FROM Studio S, Director D
WHERE D.studioID = S.studioID
GROUP BY S.studioLocation;

-- How many people have access to each project based on the platform they stream on
SELECT P.projectID, SUM(SP.nrUsers) AS 'NrWAtchers'
FROM Project P, ProjectPlatform PP, StreamingPlatform SP
WHERE PP.platformID = SP.platformID and P.projectID = PP.projectID
GROUP BY P.projectID
HAVING COUNT(*) > 1;

-- Select the PROJECTS that are on more than 2 streaming platform
SELECT projectName
FROM Project
WHERE projectID IN(
    SELECT P.projectID       
    FROM Project P
    GROUP BY P.projectID
    HAVING 2 < (
        SELECT COUNT(*)
        FROM ProjectPlatform PP 
        WHERE P.projectID = PP.projectID
));

-- Select directors that have more than 1 project
SELECT directorName
FROM Director 
WHERE directorID IN(
    SELECT D.directorID
    FROM Director D
    GROUP BY D.directorID 
    HAVING 1 < (
        SELECT COUNT(*)
        FROM Project P 
        WHERE P.directorID = D.directorID
));



-- 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator)
-- rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.

-- Select projects that have IMDBrating higher than the smallest IMDBrating for an family project
SELECT P.projectName, P.imdbRating
FROM Project P
WHERE P.imdbRating > ANY (
    SELECT imdbRating
    FROM Project P2
    WHERE P2.genre = 'family'
)
ORDER BY P.imdbRating DESC;

-- VS

SELECT P.projectName, P.imdbRating
FROM Project P
WHERE P.imdbRating > (
    SELECT MIN(P2.imdbRating)
    FROM Project P2
    WHERE P2.genre = 'family'
)
ORDER BY P.imdbRating DESC;

-- Select projects that are adventure and are series
SELECT P.projectName
FROM project P
WHERE P.projectType = 'series' and P.projectID = ANY (
    SELECT P2.projectID
    FROM Project P2
    WHERE P2.genre = 'adventure'
);

-- VS

SELECT P.projectName
FROM project P
WHERE P.projectType = 'series' and P.projectID IN (
    SELECT P2.projectID
    FROM Project P2
    WHERE P2.genre = 'adventure'
);


-- Select studios that have RT rating for their projects higher than Ghibli studio's
SELECT stduioName
FROM Studio
WHERE studioID IN (
    SELECT S.studioID
    FROM Studio S 
    INNER JOIN Director D ON S.studioID = D.studioID
    INNER JOIN Project P ON P.directorID = D.directorID
    WHERE P.rottenTomatoRating > ALL (
        SELECT P.rottenTomatoRating
        FROM Studio S 
        INNER JOIN Director D ON S.studioID = D.studioID
        INNER JOIN Project P ON P.directorID = D.directorID
        WHERE S.stduioName = 'Ghibli'
));

-- VS

SELECT stduioName
FROM Studio
WHERE studioID IN (
    SELECT S.studioID
    FROM Studio S 
    INNER JOIN Director D ON S.studioID = D.studioID
    INNER JOIN Project P ON P.directorID = D.directorID
    WHERE P.rottenTomatoRating > (
        SELECT MAX(P.rottenTomatoRating)
        FROM Studio S 
        INNER JOIN Director D ON S.studioID = D.studioID
        INNER JOIN Project P ON P.directorID = D.directorID
        WHERE S.stduioName = 'Ghibli'
));

-- Select projects that are not made by Hayao Miyazaki
SELECT projectName
FROM Project 
WHERE projectID != ALL(
    SELECT p.projectID
    FROM Project P INNER JOIN Director D ON P.directorID = D.directorID
    WHERE D.directorName = 'Hayao Miyazaki'
);

-- VS

SELECT projectName
FROM Project 
WHERE projectID NOT IN(
    SELECT p.projectID
    FROM Project P INNER JOIN Director D ON P.directorID = D.directorID
    WHERE D.directorName = 'Hayao Miyazaki'
);