----------------------------------------------------------------------------------------
---------------------------------------- VIEWS -----------------------------------------
----------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW BasicInformation AS(
	SELECT idnr, name, login, Students.program AS program, branch
	FROM Students
	FULL JOIN StudentBranches
	ON (Students.idnr = StudentBranches.student)
	);

CREATE OR REPLACE VIEW CourseQueuePositions AS(
	SELECT student, course, ROW_NUMBER () OVER (PARTITION BY course) AS position
	FROM WaitingList
	);

CREATE OR REPLACE VIEW FinishedCourses AS(
	SELECT student, course, grade, credits
	FROM Taken
	JOIN Courses
	ON (Taken.course = Courses.code)
	);

CREATE OR REPLACE VIEW PassedCourses AS(
	SELECT student, course, credits
	FROM Taken
	JOIN Courses
	ON (Taken.course = Courses.code)
	WHERE grade NOT IN ('U')
	);

CREATE OR REPLACE VIEW Registrations AS(
	(SELECT student, course, 'waiting' as status
	FROM WaitingList)
	UNION
	(SELECT student, course, 'registered' as status
	FROM Registered)
	);

CREATE OR REPLACE VIEW UnreadMandatory AS(
	SELECT student, course
	FROM ((	SELECT Students.idnr AS student, course -- Students.program
		FROM Students
		JOIN MandatoryProgram ON Students.program = MandatoryProgram.program)
		UNION
		(SELECT student, course
		FROM StudentBranches
		LEFT OUTER JOIN MandatoryBranch
		ON (StudentBranches.branch = MandatoryBranch.branch)
		AND (StudentBranches.program = MandatoryBranch.program))) AS mandatoryCourses
	WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses)
	);

CREATE OR REPLACE VIEW PathToGraduation AS(
	WITH pathGrad AS (
		SELECT idnr AS student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, recommendedCredits
		FROM(	SELECT *
			FROM Students

			LEFT OUTER JOIN
			
			(SELECT idnr AS student, COALESCE(SUM(credits),0) AS totalCredits
			FROM Students
			LEFT OUTER JOIN PassedCourses
			ON Students.idnr = PassedCourses.student
			GROUP BY Students.idnr) AS Total
			ON Students.idnr = Total.student
			
			LEFT OUTER JOIN
			
			(SELECT idnr AS student, COALESCE(COUNT(course),'0') AS mandatoryLeft
			FROM Students
			LEFT OUTER JOIN UnreadMandatory
			ON Students.idnr = UnreadMandatory.student
			GROUP BY Students.idnr) AS Mandatory
			ON Students.idnr = Mandatory.student

			LEFT OUTER JOIN


			(SELECT idnr AS student, SUM(COALESCE(mathCredits,'0')) AS mathCredits
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, SUM(credits) AS mathCredits
			FROM PassedCourses
			LEFT OUTER JOIN Classified
			ON PassedCourses.course = Classified.course
			WHERE classification = 'math'
			GROUP BY student, PassedCourses.course, Classified.course,
			Classified.classification) AS MathOne
			ON Students.idnr = MathOne.student
			GROUP BY Students.idnr) AS MathTwo
			ON Students.idnr = MathTwo.student


			LEFT OUTER JOIN

			(SELECT idnr AS student, SUM(COALESCE(researchCredits,'0')) AS researchCredits
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, SUM(credits) AS researchCredits
			FROM PassedCourses
			LEFT OUTER JOIN Classified
			ON PassedCourses.course = Classified.course
			WHERE classification = 'research'
			GROUP BY student, PassedCourses.course, Classified.course,
			Classified.classification) AS ResearchOne
			ON Students.idnr = ResearchOne.student
			GROUP BY Students.idnr) AS ResearchTwo
			ON Students.idnr = ResearchTwo.student

			LEFT OUTER JOIN
			
			(SELECT idnr AS student, SUM(COALESCE(seminarCourses,'0')) AS seminarCourses
			FROM Students
			LEFT OUTER JOIN
			(SELECT student, COUNT(classification) AS seminarCourses
			FROM Classified
			LEFT OUTER JOIN PassedCourses
			ON Classified.course = PassedCourses.course
			WHERE classification = 'seminar'
			GROUP BY student) AS SeminarOne
			ON Students.idnr = SeminarOne.student
			GROUP BY Students.idnr) AS SeminarTwo
			ON Students.idnr = SeminarTwo.student

			LEFT OUTER JOIN

			(SELECT SB.student, PC.credits AS recommendedCredits
			FROM StudentBranches SB
			JOIN RecommendedBranch RB
			ON (RB.branch, RB.program) = (SB.branch, SB.program)
			JOIN PassedCourses PC
			ON SB.student = PC.student
			AND PC.course = RB.course
			GROUP BY SB.student, RB.course, PC.credits) AS Recommended
			ON Students.idnr = Recommended.student
		) AS thisNameIsUnnecessaryButNeeded
	)
	
	SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses,
	CASE 	WHEN student NOT IN (SELECT student FROM UnreadMandatory)
		AND recommendedCredits >= 10
		AND mathCredits >= 20
		AND researchCredits >= 10
		AND seminarCourses >= 1
		THEN TRUE
		ELSE FALSE
		END
		AS qualified
	FROM pathGrad

	);


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
		
		END IF;
		
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER student_unreg_course
INSTEAD OF DELETE ON Registrations
	FOR EACH ROW EXECUTE FUNCTION course_unreg();



