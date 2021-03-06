/*
Ethan Downer 103619438

-- Create a new database called 'DatabaseName'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'S103619438'
)
CREATE DATABASE S103619438
GO
*/


/*
SUBJECT(SUBJCODE, DESCRIPTION)
PRIMARY KEY (SUBJCODE)

TEACHER(STAFFID, SURNAME, GIVENNAME)
PRIMARY KEY (STAFFID)

STUDENT(STUDENTID, SURNAME, GIVENNAME, GENDER)
PRIMARY KEY (STUDENTID)


SUBJECTOFFERING(SUBJCODE, YEAR, SEMESTER, FEE, STAFFID)
PRIMARY KEY(SUBJCODE, YEAR, SEMESTER)
FOREIGN KEY(SUBJCODE) REFERENCES SUBJECT
FOREIGN KEY(STAFFID) REFERENCES TEACHER


ENROLMENT(STUDENTID, SUBJCODE, YEAR, SEMESTER, DATEENROLLED, GRADE)
PRIMARY KEY(STUDENTID, SUBJCODE, YEAR, SEMESTER)
FOREIGN KEY(STUDENTID) REFERENCES STUDENT
FOREIGN KEY(SUBJCODE, YEAR, SEMESTER) REFERENCING SUBJECTOFFERING
*/

USE S103619438;

DROP TABLE IF EXISTS ENROLMENT, SUBJECTOFFERING, STUDENT, TEACHER, SUBJECT; 

CREATE TABLE SUBJECT (
     SUBJCODE NVARCHAR(100)
    , DESCRIPTION NVARCHAR(500)
    , PRIMARY KEY (SUBJCODE)
)

CREATE TABLE TEACHER (
      STAFFID INT
    , SURNAME NVARCHAR(100) NOT NULL
    , GIVENNAME NVARCHAR(100) NOT NULL 
    ,PRIMARY KEY (STAFFID) 
    ,CONSTRAINT CHK_TEACHER_STAFFID CHECK(LEN(STAFFID)=8)
)

CREATE TABLE STUDENT(
      STUDENTID NVARCHAR(10)
    , SURNAME NVARCHAR(100) NOT NULL
    , GIVENNAME NVARCHAR(100) NOT NULL 
    , GENDER NVARCHAR(1)
    , PRIMARY KEY (STUDENTID)
    , CONSTRAINT CHK_STUDENT_GENDER CHECK(GENDER IN('M', 'F', 'I'))
)

CREATE TABLE SUBJECTOFFERING(
    SUBJCODE NVARCHAR(100)
    , YEAR INT
    , SEMESTER INT
    , FEE MONEY NOT NULL
    , STAFFID INT
    , PRIMARY KEY(SUBJCODE, YEAR, SEMESTER)
    , FOREIGN KEY(SUBJCODE) REFERENCES [SUBJECT]
    , FOREIGN KEY(STAFFID) REFERENCES TEACHER
    , CONSTRAINT CHK_SUBJECTOFFERING_YEAR CHECK(LEN(YEAR)=4)
    , CONSTRAINT CHK_SUBJECTOFFERING_SEMESTER CHECK(SEMESTER IN (1,2))
    , CONSTRAINT CHK_SUBJECTOFFERING_FEE CHECK(FEE > 0)
)

CREATE TABLE ENROLMENT(
      STUDENTID NVARCHAR(10)
    , SUBJCODE NVARCHAR(100)
    , YEAR INT
    , SEMESTER INT
    , DATEENROLLED DATE
    , GRADE NVARCHAR(2) DEFAULT NULL
    , PRIMARY KEY(STUDENTID, SUBJCODE, YEAR, SEMESTER)
    , FOREIGN KEY(STUDENTID) REFERENCES STUDENT
    , FOREIGN KEY(SUBJCODE, YEAR, SEMESTER) REFERENCES SUBJECTOFFERING
    , CONSTRAINT CHK_ENROLMENT_YEAR CHECK(LEN(YEAR)=4)
    , CONSTRAINT CHK_ENROLMENT_SEMESTER CHECK(SEMESTER IN (1,2))
    , CONSTRAINT CHK_ENROLMENT_GRADE CHECK(GRADE IN ('N', 'P', 'C', 'D', 'HD'))
)

SELECT NAME
FROM SYS.OBJECTS
WHERE TYPE = 'U'


INSERT INTO SUBJECT (SUBJCODE, [DESCRIPTION]) VALUES
('ICTPRG418', 'Apply SQL to extract & manipulate data'),
('ICTBSB430', 'Create Basic Databases'),
('ICTDBS205', 'Design a Database');

--SELECT * FROM SUBJECT

INSERT INTO TEACHER (STAFFID, SURNAME, GIVENNAME) VALUES
('98776655', 'YOUNG', 'ANGUS'),
('87665544', 'SCOTT', 'BON'),
('76554433', 'SLADE', 'CHRIS');

--SELECT * FROM TEACHER

INSERT INTO STUDENT (STUDENTID, SURNAME, GIVENNAME, GENDER) VALUES
('s12233445', 'Baird', 'Tim', 'M'),
('s23344556', 'Nguyen', 'Ahn', 'M'),
('s34455667', 'Hallinan', 'James', 'M'),
('103619438', 'Downer', 'Ethan', 'M');

--SELECT * FROM STUDENT

INSERT INTO SUBJECTOFFERING (SUBJCODE, [YEAR], SEMESTER, FEE, STAFFID) VALUES
('ICTPRG418', 2019, 1, 200, 98776655),
('ICTPRG418', 2020, 1, 225, 98776655),
('ICTBSB430', 2020, 1, 200, 87665544),
('ICTBSB430', 2020, 2, 200, 76554433),
('ICTDBS205', 2019, 2, 225, 87665544);

--SELECT * FROM SUBJECTOFFERING

DELETE FROM ENROLMENT
INSERT INTO ENROLMENT (STUDENTID, SUBJCODE, [YEAR], SEMESTER, GRADE, DATEENROLLED) VALUES
('s12233445', 'ICTPRG418', 2019, 1, 'D', '02/25/2019'),
('s23344556', 'ICTPRG418', 2019, 1, 'P', '02/15/2019'),
('s12233445', 'ICTPRG418', 2020, 1, 'C', '01/30/2020'),
('s23344556', 'ICTPRG418', 2020, 1, 'HD', '02/26/2020'),
('s34455667', 'ICTPRG418', 2020, 1, 'P', '01/28/2020'),
('s12233445', 'ICTBSB430', 2020, 1, 'C', '02/08/2020'),
('s23344556', 'ICTBSB430', 2020, 2, null, '06/30/2020'),
('s34455667', 'ICTBSB430', 2020, 2, null, '07/03/2020'),
('s23344556', 'ICTDBS205', 2019, 2, 'P', '07/01/2019'),
('s34455667', 'ICTDBS205', 2019, 2, 'N', '07/13/2019');

--SELECT * FROM ENROLMENT


-- QUERY 1

SELECT ST.GIVENNAME, ST.SURNAME, S.SUBJCODE, SU.[DESCRIPTION], S.[YEAR], S.SEMESTER, S.FEE, T.GIVENNAME, T.SURNAME
FROM ENROLMENT E
INNER JOIN
SUBJECTOFFERING S
ON E.SUBJCODE = S.SUBJCODE AND E.YEAR=S.[YEAR] AND E.SEMESTER = S.SEMESTER
INNER JOIN TEACHER T
ON S.STAFFID = T.STAFFID
INNER JOIN STUDENT ST
ON E.STUDENTID = ST.STUDENTID
INNER JOIN SUBJECT SU
ON S.SUBJCODE = SU.SUBJCODE


-- QUERY 2
SELECT YEAR, SEMESTER, COUNT(*) AS 'Num Enrollments'
FROM ENROLMENT
GROUP BY YEAR, SEMESTER;

-- QUERY 3
SELECT E.*
FROM ENROLMENT E
INNER JOIN SUBJECTOFFERING S
ON E.SUBJCODE = S.SUBJCODE AND E.YEAR=S.[YEAR] AND E.SEMESTER = S.SEMESTER
WHERE S.FEE IN (SELECT MAX(FEE) FROM SUBJECTOFFERING);



CREATE VIEW TASK5 AS

SELECT ST.GIVENNAME AS STUDENT_FIRST_NAME, ST.SURNAME AS STUDENT_SURNAME, S.SUBJCODE, SU.[DESCRIPTION], S.[YEAR], S.SEMESTER, S.FEE, T.GIVENNAME, T.SURNAME
FROM ENROLMENT E
INNER JOIN
SUBJECTOFFERING S
ON E.SUBJCODE = S.SUBJCODE AND E.YEAR=S.[YEAR] AND E.SEMESTER = S.SEMESTER
INNER JOIN TEACHER T
ON S.STAFFID = T.STAFFID
INNER JOIN STUDENT ST
ON E.STUDENTID = ST.STUDENTID
INNER JOIN SUBJECT SU
ON S.SUBJCODE = SU.SUBJCODE

-- SELECT * FROM TASK5


-- QUERY 1 RETURNS 10 ROWS
-- THIS CAN BE CHECKED BY LOOKING AT NUMBER OF ENROLMENTS

SELECT COUNT(*) FROM ENROLMENT;

-- THIS RETURNS 10, THEREFORE QUERY 1 IS SENSIBLE


-- QUERY 2 - IF ALL THE ENROLLEMNTS ARE ADDED TOGETHER (2 + 4 + 2 + 2) FOR ALL YEARS & SEMESTERS, YOU GET 10
-- THIS IS VERIFED BY CHECKING THE NUMBER OF ENROLMENTS IN THE DATABASE. 

SELECT COUNT(*) FROM ENROLMENT;

-- THIS RETURNS 10, THEREFOR QUERY 2 IS SENSIBLE

-- QUERY 3 SHOULD RETURN 5 ROWS. WE CAN CHECK THIS BY FINDING THE MAXIMUM FEE

SELECT MAX(FEE) FROM SUBJECTOFFERING;

-- IN THIS DATABASE IT IS 225, THEN WE CHECK HOW MANY ENROLMENTS THERE ARE WITH IN SUBJECT OFFERING
-- WITH A FEE OF 225

SELECT S.FEE, COUNT(*)
FROM ENROLMENT E
INNER JOIN
SUBJECTOFFERING S
ON E.SUBJCODE = S.SUBJCODE AND E.YEAR=S.[YEAR] AND E.SEMESTER = S.SEMESTER
WHERE S.FEE = 225
GROUP BY S.FEE

-- THIS QUERY SHOWS THAT THERE ARE 5 ENROLLMENTS IN SUBJECTS WITH A FEE OF 225
