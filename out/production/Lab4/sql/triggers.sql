
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

		-- Check student not passed already	
		ELSEIF EXISTS(SELECT student, course FROM Taken
		WHERE student = NEW.student AND course = NEW.course AND grade NOT IN ('U'))
		THEN 
			RAISE EXCEPTION 'Student have already passed this course';

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


/*
1. Student is on waiting list

	1.1 Remove without anything else


2. Student is registered

	2.1 Remove

	2.2 Check if open slot on course

		2.2.1 If yes -> Register first student to course and normalise queue

		2.2.2 If no -> Do nothing
*/




CREATE OR REPLACE FUNCTION course_unreg() RETURNS trigger AS $$
	DECLARE
		queuePos INT;
		nextStudent CHAR(10);
	BEGIN

		RAISE NOTICE 'yoyoyo';

		--If student in on WaitingList then remove
		IF EXISTS(SELECT student FROM WaitingList
		WHERE student = OLD.student AND course = OLD.course) THEN
			
			queuePos := (SELECT position FROM WaitingList
					WHERE student = OLD.student AND course = OLD.course);
			
			DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
			
			RAISE NOTICE 'Student has been removed from waitinglist';
			
		--If student is registered
		ELSEIF EXISTS(SELECT student FROM Registered
		WHERE student = OLD.student AND course = OLD.course) THEN
			
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			
			RAISE NOTICE 'Student has been removed from registration to course.';
			
			IF EXISTS(SELECT course FROM WaitingList WHERE course = OLD.course)
			AND ((SELECT capacity FROM LimitedCourses WHERE code = OLD.course)
			> (SELECT COUNT(student) FROM Registered WHERE course = OLD.course)) THEN
			
				nextStudent := (SELECT student FROM WaitingList
				WHERE course = OLD.course ORDER BY position LIMIT 1);
				
				INSERT INTO Registered VALUES (nextStudent, OLD.course);
				
				DELETE FROM WaitingList WHERE student = nextStudent AND course = OLD.course;
				
				RAISE NOTICE 'Student has been removed from waitinglist and registered to the course.';
			
			END IF;

		--If student is not in Registered or on WaitingList
		ELSE
			
			RAISE EXCEPTION 'Student is not registered and not on waitingList';

		END IF;

	RETURN OLD;
	END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER student_unreg_course
INSTEAD OF DELETE ON Registrations
	FOR EACH ROW EXECUTE FUNCTION course_unreg();



