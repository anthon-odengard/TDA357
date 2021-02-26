----------------------------------------------------------------------------------------
------------------------------- INSERTS TESTING TRIGGERS -------------------------------


--------------------------------- REGISTER FOR COURSE ----------------------------------

-- TEST #1: Register to unlimited courses
-- EXPECTED OUTPUT: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC111', 'registered');

-- TEST #2: Register to limited course
-- EXPECTED OUTPUT: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC555', 'registered');

-- TEST #3: Already waiting
-- EXPECTED OUTPUT: Fail
INSERT INTO Registrations VALUES ('3333333333', 'CCC222', 'registered');

-- TEST #4: Already registered
-- EXPECTED OUTPUT: Fail
INSERT INTO Registrations VALUES ('1111111111', 'CCC111', 'registered');

-- TEST #5: Not necessary prerequisites: (student has not taken CCC111 needed for CCC222)
-- EXPECTED OUTPUT: Fail
INSERT INTO Registrations VALUES ('5555555555', 'CCC222', 'registered');

-- TEST #6: Register but put on waitinglist
-- EXPECTED OUTPUT: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC555', 'registered');


-------------------------------- UNREGISTER FOR COURSE ---------------------------------

-- TEST #7: Unregister from a limited course with a waiting list, when the student is in the middle of the waiting list
-- EXPECTED OUTPUT: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC555';

-- TEST #8: Unregister from a limited course with a waiting list, when the student is registered
-- EXPECTED OUTPUT: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';

-- TEST #9: Unregister from an unlimited course
-- EXPECTED OUTPUT: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

-- TEST #10: Unregister from a limited course without a waiting list
-- EXPECTED OUTPUT: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';

-- TEST #11: Unregister from an overfull course with a waiting list.
-- EXPECTED OUTPUT: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC777';



