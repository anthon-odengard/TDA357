-- Triggers for lab3 -- 

CREATE OR REPLACE FUNCTION courseRegistration () RETURNS TRIGGER AS $$
BEGIN
    -- Check if student already registered
    IF (NEW.course IN (SELECT course FROM Registrations WHERE(NEW.student = student) UNION ALL 
    SELECT course FROM WaitingList WHERE(NEW.student = student)))
    THEN RAISE EXCEPTION 'Already registered.';
    ELSIF()
    -- If not registered, add either in Reistered or WaitingList
    -- isCourseFull returns boolean on course satus, for readablility.
    ELSIF (SELECT CourseFull(NEW.course))
    THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
    ELSE INSERT INTO Registered VALUES (NEW.student, NEW.course);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CourseFull(course CHAR(6)) RETURNS BOOLEAN AS $$
BEGIN
    -- Create view containing if course is full or not
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
    -- Conditioning on if course is full or not, true or false return.
    IF(course IN (SELECT code FROM courseStatus) AND (SELECT isfull FROM courseStatus WHERE (code = course)) = TRUE)
    THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
    -- Drop view
    DROP VIEW courseStatus;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prereqCheck(course CHAR(6)) RETURNS BOOLEAN AS $$
BEGIN

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS insertTrigger
ON Registrations;

CREATE TRIGGER insertTrigger
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION courseRegistration ();

