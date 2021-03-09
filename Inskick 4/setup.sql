----------------------------------------------------------------------------------------
---------------------------------------- SETUP -----------------------------------------
----------------------------------------------------------------------------------------

/*
\set QUIET true
SET client_min_messages TO WARNING;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
SET client_min_messages TO NOTICE;
\set QUIET false
*/


----------------------------------------------------------------------------------------
--------------------------------------- TABLES -----------------------------------------
----------------------------------------------------------------------------------------

CREATE TABLE Departments(
	name TEXT,
	abbreviation TEXT NOT NULL UNIQUE,
	PRIMARY KEY(name)
	);

CREATE TABLE Programs(
	name TEXT,
	abbreviation TEXT NOT NULL,
	PRIMARY KEY(name)
	);

CREATE TABLE ProgramDepartments(
	program TEXT,
	department TEXT,
	PRIMARY KEY (program, department),
	FOREIGN KEY (program) REFERENCES Programs,
	FOREIGN KEY (department) REFERENCES Departments
	);

CREATE TABLE Students(
	idnr CHAR(10) NOT NULL,
	name TEXT NOT NULL,
	login TEXT NOT NULL UNIQUE,
	program TEXT NOT NULL,
	PRIMARY KEY(idnr),
	FOREIGN KEY (program) REFERENCES Programs,
	CONSTRAINT studentProg UNIQUE (idnr, program)
	);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(name, program),
	FOREIGN KEY (program) REFERENCES Programs
	);

CREATE TABLE Courses(
	code CHAR(6) NOT NULL,
	name TEXT NOT NULL,
	credits DECIMAL(3,1) NOT NULL CHECK (credits >= 0), --3 nummer, 1 decimal
	department TEXT NOT NULL,
	PRIMARY KEY(code),
	FOREIGN KEY (department) REFERENCES Departments
	);

CREATE TABLE LimitedCourses(
	code CHAR(6) NOT NULL,
	capacity INT NOT NULL CHECK (capacity >= 0),
	PRIMARY KEY(code),
	FOREIGN KEY (code) REFERENCES Courses
	);

CREATE TABLE Prerequisites(
	course CHAR(6) NOT NULL,
	prerequisite CHAR(6) NOT NULL,
	PRIMARY KEY (course, prerequisite),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (prerequisite) REFERENCES Courses
	);

CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(student),
	FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
	FOREIGN KEY (branch, program) REFERENCES Branches
	);

CREATE TABLE Classifications(
	name TEXT NOT NULL,
	PRIMARY KEY(name)
	);

CREATE TABLE Classified(
	course CHAR(6) NOT NULL,
	classification TEXT NOT NULL,
	PRIMARY KEY(course, classification),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (classification) REFERENCES Classifications
	);

CREATE TABLE MandatoryProgram(
	course CHAR(6) NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (program) REFERENCES Programs
	);

CREATE TABLE MandatoryBranch(
	course CHAR(6) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches
	);

CREATE TABLE RecommendedBranch(
	course CHAR(6) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches
	);

CREATE TABLE Registered(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
	);

CREATE TABLE Taken(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	grade CHAR(1) NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
	);

CREATE TABLE WaitingList(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	position SERIAL,
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES LimitedCourses,
	CONSTRAINT queue UNIQUE (course, position)
	);


----------------------------------------------------------------------------------------
---------------------------------------- INSERT ----------------------------------------
----------------------------------------------------------------------------------------

INSERT INTO Departments VALUES ('Dep1', 'D1');
INSERT INTO Departments VALUES ('Dep2', 'D2');
INSERT INTO Departments VALUES ('Dep3', 'D3');

INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs VALUES ('Prog2', 'P2');
INSERT INTO Programs VALUES ('Prog3', 'P3');

INSERT INTO ProgramDepartments VALUES('Prog1', 'Dep1');
INSERT INTO ProgramDepartments VALUES('Prog1', 'Dep2');
INSERT INTO ProgramDepartments VALUES('Prog2', 'Dep3');

INSERT INTO Branches VALUES ('B1', 'Prog1');
INSERT INTO Branches VALUES ('B2', 'Prog1');
INSERT INTO Branches VALUES ('B1', 'Prog2');

INSERT INTO Students VALUES ('1111111111', 'N1', 'ls1', 'Prog1');
INSERT INTO Students VALUES ('2222222222', 'N2', 'ls2', 'Prog1');
INSERT INTO Students VALUES ('3333333333', 'N3', 'ls3', 'Prog2');
INSERT INTO Students VALUES ('4444444444', 'N4', 'ls4', 'Prog1');
INSERT INTO Students VALUES ('5555555555', 'Nx', 'ls5', 'Prog2');
INSERT INTO Students VALUES ('6666666666', 'Nx', 'ls6', 'Prog2');

INSERT INTO Courses VALUES ('CCC111', 'C1', 22.5, 'Dep1');
INSERT INTO Courses VALUES ('CCC222', 'C2', 20,   'Dep1');
INSERT INTO Courses VALUES ('CCC333', 'C3', 30,   'Dep1');
INSERT INTO Courses VALUES ('CCC444', 'C4', 40,   'Dep1');
INSERT INTO Courses VALUES ('CCC555', 'C5', 50,   'Dep1');
INSERT INTO Courses VALUES ('CCC666', 'C6', 17.5,   'Dep3');
INSERT INTO Courses VALUES ('CCC777', 'C7', 27.5,   'Dep2');

INSERT INTO Prerequisites VALUES('CCC222', 'CCC111');
INSERT INTO Prerequisites VALUES('CCC333', 'CCC111');
INSERT INTO Prerequisites VALUES('CCC444', 'CCC333');

INSERT INTO LimitedCourses VALUES ('CCC222', 2);
INSERT INTO LimitedCourses VALUES ('CCC333', 2);
INSERT INTO LimitedCourses VALUES ('CCC555', 1);
INSERT INTO LimitedCourses VALUES ('CCC444', 5);
INSERT INTO LimitedCourses VALUES ('CCC777', 1);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333', 'math');
INSERT INTO Classified VALUES ('CCC444', 'research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO StudentBranches VALUES ('2222222222', 'B1', 'Prog1');
INSERT INTO StudentBranches VALUES ('3333333333', 'B1', 'Prog2');
INSERT INTO StudentBranches VALUES ('4444444444', 'B1', 'Prog1');

INSERT INTO MandatoryProgram VALUES ('CCC111', 'Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B2', 'Prog1');

INSERT INTO Registered VALUES ('1111111111', 'CCC222');
INSERT INTO Registered VALUES ('2222222222', 'CCC222');
INSERT INTO Registered VALUES ('5555555555', 'CCC333');
INSERT INTO Registered VALUES ('1111111111', 'CCC333');
INSERT INTO Registered VALUES ('6666666666', 'CCC555');
INSERT INTO Registered VALUES ('1111111111', 'CCC777');
INSERT INTO Registered VALUES ('2222222222', 'CCC777');
INSERT INTO Registered VALUES ('3333333333', 'CCC777');

INSERT INTO WaitingList VALUES ('3333333333', 'CCC222', 1);
INSERT INTO WaitingList VALUES ('3333333333', 'CCC333', 1);
INSERT INTO WaitingList VALUES ('2222222222', 'CCC333', 2);
INSERT INTO WaitingList VALUES ('2222222222', 'CCC555', 2);
INSERT INTO WaitingList VALUES ('4444444444', 'CCC555', 3);
INSERT INTO WaitingList VALUES ('4444444444', 'CCC777', 4);

INSERT INTO Taken VALUES('2222222222', 'CCC111', 'U');
INSERT INTO Taken VALUES('2222222222', 'CCC222', 'U');
INSERT INTO Taken VALUES('2222222222', 'CCC444', 'U');

INSERT INTO Taken VALUES('4444444444', 'CCC111', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC222', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC333', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC444', '5');

INSERT INTO Taken VALUES('5555555555', 'CCC555', '4');

INSERT INTO Taken VALUES('6666666666', 'CCC111', '3');
INSERT INTO Taken VALUES('6666666666', 'CCC333', '3');

----------------------------------------------------------------------------------------
---------------------------------------- VIEWS -----------------------------------------
----------------------------------------------------------------------------------------


CREATE OR REPLACE VIEW BasicInformation AS(
	SELECT idnr, name, login, Students.program AS program, branch
	FROM Students
	FULL JOIN StudentBranches
	ON (Students.idnr = StudentBranches.student)
	);

CREATE OR REPLACE VIEW CourseQueuePositions AS(
	SELECT student, course, ROW_NUMBER () OVER (PARTITION BY course) AS place
	FROM WaitingList
	);

CREATE OR REPLACE VIEW FinishedCourses AS(
	SELECT student, course, grade, credits
	FROM Taken
	JOIN Courses
	ON (Taken.course = Courses.code)
	);

CREATE OR REPLACE VIEW PassedCourses AS(
	SELECT student, course, credits
	FROM Taken
	JOIN Courses
	ON (Taken.course = Courses.code)
	WHERE grade NOT IN ('U')
	);

CREATE OR REPLACE VIEW Registrations AS(
	(SELECT student, course, 'waiting' as status
	FROM WaitingList)
	UNION
	(SELECT student, course, 'registered' as status
	FROM Registered)
	);

CREATE OR REPLACE VIEW UnreadMandatory AS(
	SELECT student, course
	FROM ((	SELECT Students.idnr AS student, course -- Students.program
		FROM Students
		JOIN MandatoryProgram ON Students.program = MandatoryProgram.program)
		UNION
		(SELECT student, course
		FROM StudentBranches
		LEFT OUTER JOIN MandatoryBranch
		ON (StudentBranches.branch = MandatoryBranch.branch)
		AND (StudentBranches.program = MandatoryBranch.program))) AS mandatoryCourses
	WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses)
	);

CREATE OR REPLACE VIEW PathToGraduation AS(
	WITH pathGrad AS (
		SELECT idnr AS student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, recommendedCredits
		FROM(	SELECT *
			FROM Students

			LEFT OUTER JOIN
			
			(SELECT idnr AS student, COALESCE(SUM(credits),0) AS totalCredits
			FROM Students
			LEFT OUTER JOIN PassedCourses
			ON Students.idnr = PassedCourses.student
			GROUP BY Students.idnr) AS Total
			ON Students.idnr = Total.student
			
			LEFT OUTER JOIN
			
			(SELECT idnr AS student, COALESCE(COUNT(course),'0') AS mandatoryLeft
			FROM Students
			LEFT OUTER JOIN UnreadMandatory
			ON Students.idnr = UnreadMandatory.student
			GROUP BY Students.idnr) AS Mandatory
			ON Students.idnr = Mandatory.student

			LEFT OUTER JOIN


			(SELECT idnr AS student, SUM(COALESCE(mathCredits,'0')) AS mathCredits
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, SUM(credits) AS mathCredits
			FROM PassedCourses
			LEFT OUTER JOIN Classified
			ON PassedCourses.course = Classified.course
			WHERE classification = 'math'
			GROUP BY student, PassedCourses.course, Classified.course,
			Classified.classification) AS MathOne
			ON Students.idnr = MathOne.student
			GROUP BY Students.idnr) AS MathTwo
			ON Students.idnr = MathTwo.student


			LEFT OUTER JOIN

			(SELECT idnr AS student, SUM(COALESCE(researchCredits,'0')) AS researchCredits
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, SUM(credits) AS researchCredits
			FROM PassedCourses
			LEFT OUTER JOIN Classified
			ON PassedCourses.course = Classified.course
			WHERE classification = 'research'
			GROUP BY student, PassedCourses.course, Classified.course,
			Classified.classification) AS ResearchOne
			ON Students.idnr = ResearchOne.student
			GROUP BY Students.idnr) AS ResearchTwo
			ON Students.idnr = ResearchTwo.student

			LEFT OUTER JOIN
			
			(SELECT idnr AS student, SUM(COALESCE(seminarCourses,'0')) AS seminarCourses
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, COUNT(classification) AS seminarCourses
			FROM Classified
			LEFT OUTER JOIN PassedCourses
			ON Classified.course = PassedCourses.course
			WHERE classification = 'seminar'
			GROUP BY student) AS SeminarOne
			ON Students.idnr = SeminarOne.student
			GROUP BY Students.idnr) AS SeminarTwo
			ON Students.idnr = SeminarTwo.student

			LEFT OUTER JOIN

			(SELECT SB.student, PC.credits AS recommendedCredits
			FROM StudentBranches SB
			JOIN RecommendedBranch RB
			ON (RB.branch, RB.program) = (SB.branch, SB.program)
			JOIN PassedCourses PC
			ON SB.student = PC.student
			AND PC.course = RB.course
			GROUP BY SB.student, RB.course, PC.credits) AS Recommended
			ON Students.idnr = Recommended.student
		) AS thisNameIsUnnecessaryButNeeded
	)
	
	SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses,
	CASE 	WHEN student NOT IN (SELECT student FROM UnreadMandatory)
		AND recommendedCredits >= 10
		AND mathCredits >= 20
		AND researchCredits >= 10
		AND seminarCourses >= 1
		THEN TRUE
		ELSE FALSE
		END
		AS qualified
	FROM pathGrad

	);


