CREATE VIEW BasicInformation AS
    SELECT st.idnmr, st.name, st.login, st.program, sb.branch
    FROM Students st 
    LEFT OUTER JOIN StudentBranches sb ON st.idnmr = sb.student;

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
    SELECT st.idnmr AS student, mp.course
    FROM Students st
    JOIN MandatoryProgram mp ON st.program = mp.program
    UNION
    SELECT st.student, COALESCE(mb.course, 'no program mandatory courses') 
    FROM StudentBranches st
    LEFT OUTER JOIN MandatoryBranch mb ON st.branch = mb.branch AND st.program = mb.program) AS MandatoryAll
    WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses);


CREATE VIEW PathToGraduation(
    WITH Student(student) AS (
        SELECT Students.idnmr
        FROM Students
    ),
    PassedCredits AS (
        SELECT student, sum(credits)
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
    MandatoryNotPassed AS(SELECT st.idnmr AS Student, COUNT(course) AS mandatoryLeft
        FROM Students st
        LEFT OUTER JOIN MandatoryCourses mc ON mc.program = st.program
        WHERE (st.idnmr, mc.course) NOT IN (SELECT student, course
        FROM PassedCourses)
        GROUP BY st.idnmr
        ORDER BY st.idnmr
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
    )
    SELECT st.idnmr AS student, 
    COALESCE(mnp.mandatoryLeft, 0) AS mandatoryLeft, 
    COALESCE(mnp.mandatoryLeft, 0) AS mandatoryLeft, 
    COALESCE(mc.mathCredits,0) AS mathCredits, 
    COALESCE(rc.researchCredits, 0) AS researchCredits, 
    COALESCE(sc.seminarCourses,0) AS seminarCourses
    FROM Students st
    LEFT OUTER JOIN PassedCredits pc ON pc.student = st.idnmr
    LEFT OUTER JOIN MandatoryNotPassed mnp on mnp.student = st.idnmr
    LEFT OUTER JOIN MathCredits mc ON st.idnmr = mc.student
    LEFT OUTER JOIN ResearchCredits rc ON rc.student = st.idnmr
    LEFT OUTER JOIN SeminarCourses sc ON st.idnmr = sc.student;
)
