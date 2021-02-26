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


