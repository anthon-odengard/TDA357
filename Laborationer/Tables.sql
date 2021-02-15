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
    idnr BIGINT NOT NULL PRIMARY KEY CHECK(idnr BETWEEN 0 AND 9999999999),
    name TEXT NOT NULL,
    login VARCHAR UNIQUE,
    program VARCHAR NOT NULL REFERENCES Program(name)
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY key(name, program)
);

CREATE TABLE Courses(
    code CHAR(6) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits BIGINT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code) PRIMARY KEY,
    capacity BIGINT NOT NULL
);

CREATE TABLE StudentBranches(
    student BIGINT PRIMARY KEY,
    branch VARCHAR NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(branch, program) REFERENCES Branches,
    FOREIGN KEY(student, program) REFERENCES Students(idnr,program)
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
    student BIGINT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student BIGINT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK(grade IN ('U', '3', '4', '5') ),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList(
    student BIGINT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    position SERIAL,
    PRIMARY KEY(student, course),
    UNIQUE(course, position)
);

