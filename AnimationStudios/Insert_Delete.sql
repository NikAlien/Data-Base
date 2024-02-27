-- INSERTing data in at least 4 tables
INSERT INTO Mascot(mascotID, mascotName, creationYear) VALUES (12, 'Hello Kitty', '1975-03-01');
INSERT INTO Mascot(mascotID, mascotName, creationYear, studioID) VALUES (13, 'Totoro', '1988-01-01', 100);

INSERT INTO Award(awardID, awardName, nrCategories) VALUES (13, 'Oscar', 5);

INSERT INTO Studio(studioID, stduioName, studioLocation, startActivity, nrEmployees) 
VALUES (107, 'Toei Animation', 'Japan', '1948-01-23', 840);

-- the first one violates an integrity constraint
-- 100	15
-- 100	16
-- 101	16
-- 101	19
-- 104	15
-- 104	16
-- 104	18
-- 105	16
INSERT INTO AnimationTechnic(techId, tecnicName, technicType) VALUES (15, '3DCG', 'electronic');
INSERT INTO AnimationTechnic(techID, tecnicName, technicType) VALUES (16, '2D', 'traditional');
INSERT INTO AnimationTechnic(techID, tecnicName, technicType) VALUES (17, 'Claymation', 'traditional');
INSERT INTO AnimationTechnic(techID, tecnicName, technicType) VALUES (18, 'Motion Capture', 'electronic');
INSERT INTO AnimationTechnic(techID, tecnicName) VALUES (19, 'Cel-shaded');



-- UPDATE data in at least 3 tables
UPDATE Studio
SET nrEmployees = nrEmployees + 7
WHERE nrEmployees < 100;

UPDATE Award
SET startYear = '2023-01-01'
WHERE startYear is NULL;

UPDATE StreamingPlatform
SET nrUsers = nrUsers / 10
WHERE platformName LIKE 'Disney%';



-- DELETE data from 2 tables
DELETE
FROM Award
WHERE nrCategories <= 5;

DELETE
FROM Studio
WHERE stduioName IN ('Toei Animation', 'Wit Studio');

