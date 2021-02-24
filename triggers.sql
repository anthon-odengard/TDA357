----------------------------------------------------------------------------------------
--------------------------------------- TRIGGERS ---------------------------------------
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-------------------------------- STUDENT REGISTRATIONS ---------------------------------


CREATE OR REPLACE FUNCTION course_reg() RETURNS trigger AS $$
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
		
		--Check course not full and if it is insert into WaitingList
		ELSEIF EXISTS(SELECT code FROM LimitedCourses WHERE code = NEW.course)
		AND ((SELECT COALESCE(COUNT(student),0) FROM Registered WHERE course = NEW.course)
			>= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course)) THEN
			
			newPos := (SELECT COALESCE(MAX(position),0) FROM WaitingList WHERE course = NEW.course);
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
	FOR EACH ROW EXECUTE FUNCTION course_reg();



----------------------------------------------------------------------------------------
-------------------------------- STUDENT REGISTRATIONS ---------------------------------


--DROP FUNCTION course_unreg() CASCADE;

/*
1. Student is on waiting list

	1.1 Remove without anything else


2. Student is registered

	2.1 Remove

	2.2 Check if open slot on course

		2.2.1 If yes -> Register student first in course

		2.2.2 If no -> Do nothing
*/


SELECT student FROM WaitingList WHERE student = '1111111111' AND course = 'CCC555'


CREATE OR REPLACE FUNCTION course_unreg() RETURNS trigger AS $$
	DECLARE
		queuePos INT;
	BEGIN
		
		--If student in on WaitingList then remove
		IF EXISTS(SELECT student FROM WaitingList
			WHERE student = OLD.student AND course = OLD.course) THEN
			
			queuePos := (SELECT position FROM WaitingList
					WHERE student = OLD.student AND course = OLD.course);
			
			DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
			
			IF (queuePos < (SELECT COALESCE(MAX(position),0) FROM WaitingList WHERE course = OLD.course))
			THEN
				UPDATE WaitingList
				SET position = position - 1
				WHERE position >= queuePos AND course = OLD.course;
			
			RAISE NOTICE 'Student has been removed from waitinglist';
			
			END IF;
		
		--If student is registered then remove from Registered
		
		
		END IF;
		
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER student_unreg_course
INSTEAD OF DELETE ON Registrations
	FOR EACH ROW EXECUTE FUNCTION course_unreg();



