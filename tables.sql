----------------------------------------------------------------------------------------
--------------------------------------- TABLES -----------------------------------------
----------------------------------------------------------------------------------------

CREATE TABLE Students(
	idnr CHAR(10) NOT NULL,
	name TEXT NOT NULL,
	login TEXT NOT NULL, --osäker på typ här
	program TEXT NOT NULL,
	PRIMARY KEY(idnr)
	);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(name, program)
	);

CREATE TABLE Courses(
	code CHAR(6) NOT NULL,
	name TEXT NOT NULL,
	credits DECIMAL(3,1) NOT NULL CHECK (credits >= 0), --3 nummer, 1 decimal
	department TEXT NOT NULL,
	PRIMARY KEY(code)
	);

CREATE TABLE LimitedCourses(
	code CHAR(6) NOT NULL,
	capacity INT NOT NULL CHECK (capacity >= 0),
	PRIMARY KEY(code),
	FOREIGN KEY (code) REFERENCES Courses
	);

CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(student),
	FOREIGN KEY (student) REFERENCES Students,
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
	FOREIGN KEY (course) REFERENCES Courses
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
	FOREIGN KEY (course) REFERENCES LimitedCourses
	);

