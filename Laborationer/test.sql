-- Test file for triggers

-- TEST #1: Register for an unlimited course
-- Expected outcome: Student has been registered.

INSERT INTO Registrations VALUES ('5555555555', 'CCC111');

-- TEST #2: Register an already registered student.
-- Expected outcome: ERROR:  Student already registered..
INSERT INTO Registrations VALUES ('1111111111', 'CCC111');

-- TEST #3: Register on full course.
-- Expected output: NOTICE:  Course full, student put in waitinglist.

INSERT INTO Registrations VALUES('4444444444', 'CCC222');


-- TEST #4: Unregister from a unlimited course
-- Expected output: NOTICE:  Student has been removed from course.
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC111';

-- TEST #6: DELETE student from limited course with waitingline
-- Expected output: NOTICE:  Student has been removed from course. Student has been registered.'
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';


-- Test #7: Register course with fulfilled prerequisite
-- Expected output:  Student has been registered.
INSERT INTO Registrations VALUES ('5555555555', 'CCC111');

-- Test #8: Register course with missing prerequisite
-- Expected output: Student missing prerequisites.
INSERT INTO Registrations VALUES ('1111111111', 'CCC444');

-- Test #8: DELETE from overfull course
DELETE FROM Registrations WHERE student = '4444444444' AND course = 'CCC222';

INSERT INTO Registrations VALUES ('4444444444', 'CCC222');