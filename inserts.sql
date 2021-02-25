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

INSERT INTO Prerequisites VALUES('CCC222', 'CCC111');
INSERT INTO Prerequisites VALUES('CCC333', 'CCC111');
INSERT INTO Prerequisites VALUES('CCC444', 'CCC333');

INSERT INTO LimitedCourses VALUES ('CCC222', 2);
INSERT INTO LimitedCourses VALUES ('CCC333', 2);
INSERT INTO LimitedCourses VALUES ('CCC555', 1);

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

INSERT INTO Registered VALUES ('1111111111', 'CCC111');
INSERT INTO Registered VALUES ('1111111111', 'CCC222');
INSERT INTO Registered VALUES ('2222222222', 'CCC222');
INSERT INTO Registered VALUES ('5555555555', 'CCC333');
INSERT INTO Registered VALUES ('1111111111', 'CCC333');

INSERT INTO WaitingList VALUES ('3333333333', 'CCC222', 1);
INSERT INTO WaitingList VALUES ('3333333333', 'CCC333', 1);
INSERT INTO WaitingList VALUES ('2222222222', 'CCC333', 2);

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
------------------------------- INSERTS TESTING TRIGGERS -------------------------------


--------------------------------- REGISTER FOR COURSE ----------------------------------

--Should register:
INSERT INTO Registrations VALUES ('6666666666', 'CCC555', 'registered');

---Already waiting:
INSERT INTO Registrations VALUES ('3333333333', 'CCC222', 'registered');

---Already registered:
INSERT INTO Registrations VALUES ('1111111111', 'CCC111', 'registered');

---Not necessary prerequisites: (student has not taken CCC111 needed for CCC222)
INSERT INTO Registrations VALUES ('5555555555', 'CCC222', 'registered');
INSERT INTO Registrations VALUES ('5555555555', 'CCC444', 'registered');

--Put on waitinglist:
INSERT INTO Registrations VALUES ('4444444444', 'CCC444', 'registered');
INSERT INTO Registrations VALUES ('6666666666', 'CCC222', 'registered');
INSERT INTO Registrations VALUES ('1111111111', 'CCC555', 'registered');
INSERT INTO Registrations VALUES ('2222222222', 'CCC555', 'registered');



----------------------------------------------------------------------------------------
-------------------------------- UNREGISTER FOR COURSE ---------------------------------

--Delete from waitinglist:
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC555';
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC555';

--Delete from registered and add from waitinglist:
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC555';
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC555';
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC555';




