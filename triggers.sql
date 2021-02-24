----------------------------------------------------------------------------------------
--------------------------------------- TRIGGERS ---------------------------------------
----------------------------------------------------------------------------------------


SELECT student, prerequisite FROM Prerequisites

JOIN Taken ON prerequisite = Taken.course AND student = '6666666666'

WHERE Prerequisites.course = 'CCC555' AND grade NOT IN ('U')



----------------------------------------------------------------------------------------
-------------------------------- STUDENT REGISTRATIONS ---------------------------------

DROP FUNCTION lim_course_reg() CASCADE;


CREATE FUNCTION lim_course_reg() RETURNS trigger AS $$
	DECLARE
		newPos INT;
	BEGIN
		--Check student not waiting already:
		IF EXISTS(SELECT student, course FROM WaitingList
			WHERE student = NEW.student AND course = NEW.course) THEN
			RAISE EXCEPTION 'Student is already on the waitinglist for the course.';
		
		--Check student not registered already:
		ELSEIF EXISTS(SELECT student, course FROM Registered
			WHERE student = NEW.student AND course = NEW.course) THEN
			RAISE EXCEPTION 'Student is already registered for the course.';
		
		--Check prerequisites: (if there are any prerequisites and if their fulfilled)
		ELSEIF EXISTS(SELECT course FROM Prerequisites WHERE course = NEW.course) AND
			NOT EXISTS(SELECT student, prerequisite FROM Prerequisites
			JOIN Taken ON prerequisite = Taken.course AND student = NEW.student
			WHERE Prerequisites.course = NEW.course AND grade NOT IN ('U')) THEN
			RAISE EXCEPTION 'Student does not have the necessary prerequisites to register for the course.';
		
		--Check course not full:
		ELSEIF EXISTS(SELECT code FROM LimitedCourses WHERE code = NEW.course)
		AND ((SELECT COALESCE(COUNT(student),0) FROM Registered WHERE course = NEW.course)
			>= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course)) THEN
			newPos := (SELECT MAX(position) FROM WaitingList WHERE course = NEW.course);
			INSERT INTO WaitingList VALUES (NEW.student, NEW.course, newPos + 1);
			RAISE NOTICE 'Student has been put on waitinglist';
		
		--Otherwise register student for course:
		ELSE
			INSERT INTO Registered VALUES(NEW.student, NEW.course);
			RAISE NOTICE 'Student has been registered for the course';
		
		END IF;
		
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER student_reg_course
INSTEAD OF INSERT ON Registrations
	FOR EACH ROW EXECUTE FUNCTION lim_course_reg();



----------------------------------------------------------------------------------------
-------------------------------- STUDENT REGISTRATIONS ---------------------------------










