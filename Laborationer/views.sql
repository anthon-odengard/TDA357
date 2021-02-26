CREATE VIEW BasicInformation AS
    SELECT st.idnr, st.name, st.login, st.program, sb.branch
    FROM Students st 
    LEFT OUTER JOIN StudentBranches sb ON st.idnr = sb.student;

CREATE VIEW FinishedCourses AS
    SELECT tk.student, tk.course, tk.grade, c.credits
    FROM Taken tk 
    JOIN Courses c ON tk.course = c.code;

CREATE VIEW PassedCourses AS
  SELECT tk.student, tk.course, c.credits
    FROM Taken tk 
    JOIN Courses c ON tk.course = c.code 
    WHERE tk.grade IN ('3','4','5');

CREATE VIEW Registrations AS
    SELECT student, course, 'waiting' AS status
    FROM WaitingList
    UNION
    SELECT student, course, 'registered' AS status
    FROM Registered;


CREATE View UnreadMandatory AS
    SELECT *
    FROM(
    SELECT st.idnr AS student, mp.course
    FROM Students st
    JOIN MandatoryProgram mp ON st.program = mp.program
    UNION
    SELECT st.student, COALESCE(mb.course, 'no program mandatory courses') 
    FROM StudentBranches st
    LEFT OUTER JOIN MandatoryBranch mb ON st.branch = mb.branch AND st.program = mb.program) AS MandatoryAll
    WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses);


CREATE VIEW PathToGraduation AS(
    WITH Student(student) AS (
        SELECT st.idnr
        FROM Students st
    ),
    PassedCredits AS (
        SELECT student, sum(credits) AS totalCredits
        FROM PassedCourses
        GROUP BY student
    ),
    MandatoryCourses(course, program) AS(
        (SELECT * 
        FROM MandatoryProgram)
        UNION
        (SELECT course, program
        FROM MandatoryBranch)),
    -- Joining student with mandatory course 
    -- thats not in passed course
    MandatoryNotPassed AS(SELECT st.idnr AS Student, COUNT(course) AS mandatoryLeft
        FROM Students st
        LEFT OUTER JOIN MandatoryCourses mc ON mc.program = st.program
        WHERE (st.idnr, mc.course) NOT IN (SELECT student, course
        FROM PassedCourses)
        GROUP BY st.idnr
        ORDER BY st.idnr
    ),
    PassedClassified AS (
        SELECT * 
        FROM PassedCourses pc 
        JOIN Classified cf 
        ON (pc.course = cf.course)
    ),
    MathCredits AS (
        SELECT student, SUM(credits) AS mathCredits, classification
        FROM PassedClassified 
        WHERE (classification = 'math')
        GROUP BY student, classification
    ),
    ResearchCredits AS (
        SELECT student, SUM(credits) AS researchCredits, classification
        FROM PassedClassified 
        WHERE (classification = 'research')
        GROUP BY student, classification
    ),
    SeminarCourses AS (SELECT student, COUNT(credits) AS seminarCourses, classification
        FROM PassedClassified 
        WHERE (classification = 'seminar')
        GROUP BY student, classification
    ),
    RecommendedCredits AS (SELECT sb.student, rb.branch, SUM(cs.credits) AS recommendedCredits
    FROM StudentBranches sb
    LEFT OUTER JOIN RecommendedBranch rb ON sb.branch = rb.branch
    AND sb.program = rb.program
    LEFT OUTER JOIN Courses cs ON cs.code = rb.course
    GROUP BY sb.student, rb.branch
    ),
    Qualified AS (SELECT Student.student,
    CASE
        WHEN Student.student NOT IN(SELECT student FROM MandatoryNotPassed)
        AND Student.student IN(
            SELECT student 
            FROM RecommendedCredits 
            WHERE recommendedcredits >=10
            )
        AND Student.student IN(
            SELECT student 
            FROM MathCredits 
            WHERE mathCredits >=20
            )
        AND Student.student IN(
            SELECT student 
            FROM ResearchCredits 
            WHERE researchCredits >=10
            )
        AND Student.student IN(
            SELECT student 
            FROM SeminarCourses 
            WHERE seminarCourses >=1
            )
        THEN TRUE
        ELSE FALSE
        END
        AS qualified
    FROM Student
        )
    SELECT st.idnr AS student, 
    COALESCE(pc.totalCredits, 0) AS totalCredits, 
    COALESCE(mnp.mandatoryLeft, 0) AS mandatoryLeft, 
    COALESCE(mc.mathCredits,0) AS mathCredits, 
    COALESCE(rc.researchCredits, 0) AS researchCredits, 
    COALESCE(sc.seminarCourses,0) AS seminarCourses,
    COALESCE(qf.qualified, FALSE) AS qualified
    FROM Students st
    LEFT OUTER JOIN PassedCredits pc ON pc.student = st.idnr
    LEFT OUTER JOIN MandatoryNotPassed mnp on mnp.student = st.idnr
    LEFT OUTER JOIN MathCredits mc ON st.idnr = mc.student
    LEFT OUTER JOIN ResearchCredits rc ON rc.student = st.idnr
    LEFT OUTER JOIN SeminarCourses sc ON st.idnr = sc.student
    LEFT OUTER JOIN Qualified qf ON st.idnr = qf.student

);

CREATE VIEW CourseQueuePositions AS
    SELECT * 
    FROM WaitingList 
    ORDER BY course;


\i /Users/anthonodengard/TDA357/Laborationer/triggers.sql






