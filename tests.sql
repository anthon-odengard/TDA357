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

--Delete from registered (limited course) and add from waitinglist:
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC555';
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC555';
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC555';

--Delete from registration unlimited course






