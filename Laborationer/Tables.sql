DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE Department(
    name VARCHAR PRIMARY KEY,
    abbreviation VARCHAR UNIQUE
    );

CREATE TABLE Program(
    name VARCHAR PRIMARY KEY,
    abbreviation VARCHAR  NOT NULL
);

CREATE TABLE ProgramHost(
    program VARCHAR REFERENCES Program(name),
    department VARCHAR REFERENCES Department(name),
    PRIMARY KEY(program, department)
);

CREATE TABLE Students(
    idnr CHAR(10) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    login VARCHAR UNIQUE,
    program VARCHAR NOT NULL REFERENCES Program(name),
    UNIQUE(idnr, program)
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY key(name, program)
);

CREATE TABLE Courses(
    code CHAR(6) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits NUMERIC NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code) PRIMARY KEY,
    capacity CHAR(10) NOT NULL
);

CREATE TABLE StudentBranches(
    student CHAR(10) PRIMARY KEY,
    branch VARCHAR NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(branch, program) REFERENCES Branches,
    FOREIGN KEY(student, program) REFERENCES Students(idnr, program)
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL REFERENCES Courses(code),
    program TEXT NOT NULL,
    PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL REFERENCES Courses(code),
    branch VARCHAR NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches
);

CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL REFERENCES Courses(code),
    branch VARCHAR NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches
);

CREATE TABLE Registered(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK(grade IN ('U', '3', '4', '5') ),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    position SERIAL,
    PRIMARY KEY(student, course),
    UNIQUE(position)

);

CREATE TABLE Prerequisites(
	course CHAR(6) NOT NULL,
	prerequisites CHAR(6) NOT NULL,
	PRIMARY KEY (course, prerequisites),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (prerequisites) REFERENCES Courses
	);

\i /Users/anthonodengard/TDA357/Laborationer/inserts.sql