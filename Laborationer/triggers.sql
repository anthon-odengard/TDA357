-- Triggers for lab3 -- 

-- Register student on course
CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.course IN (SELECT course FROM Registrations WHERE(NEW.student = student) UNION ALL 
    SELECT course FROM WaitingList WHERE(NEW.student = student)))
    THEN RAISE EXCEPTION 'Already registered.';
    ELSIF (SELECT PreReqCheck(NEW.student, NEW.course = FALSE))
    THEN RAISE EXCEPTION 'Missing prerequisites';
    ELSIF (SELECT CourseFull(NEW.course))
    THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
    ELSE INSERT INTO Registered VALUES (NEW.student, NEW.course);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Unregister student from course
CREATE OR REPLACE FUNCTION unregisterCourse () RETURNS TRIGGER AS $$
BEGIN

END;
$$ LANGUAGE plpgsql;


-- Check if course full
CREATE OR REPLACE FUNCTION CourseFull(course CHAR(6)) RETURNS BOOLEAN AS $$
BEGIN
    CREATE VIEW CourseStatus AS
        SELECT lc.code, 
        CASE 
        WHEN COUNT(rg.course) >= lc.capacity
        THEN TRUE
        ELSE FALSE
        END
        AS isfull
        FROM LimitedCourses lc
        JOIN Registered rg ON (lc.code = rg.course)
        GROUP BY lc.code;
    IF(course IN (SELECT code FROM courseStatus) AND (SELECT isfull FROM courseStatus WHERE (code = course)) = TRUE)
    THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
    DROP VIEW courseStatus;
END;
$$ LANGUAGE plpgsql;

-- Crosscheck student prerequisite
CREATE OR REPLACE FUNCTION PreReqCheck(student BIGINT, course CHAR(6)) RETURNS BOOLEAN AS $$
BEGIN
    IF(NOT course IN(SELECT course FROM prerequisites))
    THEN RETURN TRUE;
    ELSIF(course IN (SELECT course FROM prerequisites) AND course IN
    (SELECT course FROM Taken.tk WHERE (tk.student = student)))
    THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS registerTrigger
ON Registrations;

CREATE TRIGGER registerTrigger
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unregisterCourse ();

CREATE TRIGGER unregisterTrigger
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();
