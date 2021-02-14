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
	prerequisites CHAR(6) NOT NULL,
	PRIMARY KEY (course),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (prerequisites) REFERENCES Courses
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
	FOREIGN KEY (course) REFERENCES LimitedCourses,
	CONSTRAINT queue UNIQUE (course, position)
	);


