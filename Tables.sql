
-- Student table
CREATE TABLE Students(
    idnmr INT NOT NULL PRIMARY KEY CHECK(idnmr BETWEEn 0 AND 9999999999),
    name TEXT NOT NULL,
    login VARCHAR NOT NULL,
    program VARCHAR NOT NULL
);
-- Test primary key and constrain
INSERT INTO Students
VALUES(1923738191231232);

-- Branches Table

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY key(name, program)
);

CREATE TABLE Courses(
    code CHAR(6) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits INT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code) PRIMARY KEY,
    capacity INT NOT NULL
);

CREATE TABLE StudentBranches(
    student INT REFERENCES Students(idnmr) PRIMARY KEY,
    branch VARCHAR NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(branch, program) REFERENCES Branches
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
    student INT REFERENCES Students(idnmr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student INT REFERENCES Students(idnmr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK(grade IN ('U', '3', '4', '5') ),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList(
    student INT REFERENCES Students(idnmr),
    course CHAR(6) REFERENCES Courses(code),
    position SERIAL NOT NULL,
    PRIMARY KEY(student, course)
);





