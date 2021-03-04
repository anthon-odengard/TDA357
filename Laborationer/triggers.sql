-- Triggers for lab3 -- 

-- Register student on course
CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
    BEGIN

        -- Check if student is already listed in refister or waitinglist.
        IF (NEW.student IN (SELECT student FROM Registrations WHERE(NEW.course = course)))
            THEN RAISE EXCEPTION 'Student already registered.';

        -- Check if prerequistite fullfilled.
        ELSIF (SELECT PreReqCheck(NEW.student, NEW.course) = FALSE)
            THEN RAISE EXCEPTION 'Student missing prerequisites.';
        ELSIF (SELECT CourseFull(NEW.course))
            THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
            RAISE NOTICE 'Course full, student put in waitinglist.';
        ELSE INSERT INTO Registered VALUES (NEW.student, NEW.course);
        RAISE NOTICE 'Student has been registered.';
        END IF;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- Unregister student from course
CREATE OR REPLACE FUNCTION unregisterCourse () RETURNS TRIGGER AS $$
    DECLARE
    nextInLine BIGINT;
    BEGIN

        -- Check if student registered in either Waiting or registered, remove if TRUE.
        IF(OLD.student IN(SELECT rg.student FROM Registered rg WHERE (rg.course = OLD.course)))
            THEN DELETE FROM Registered WHERE (student = OLD.student AND course = OLD.course);
              RAISE NOTICE 'Student has been removed from course';
        ELSIF(OLD.student IN(SELECT wl.student FROM WaitingList wl WHERE (wl.course = OLD.course)))
            THEN DELETE FROM WaitingList WHERE (student = OLD.student AND course = OLD.course );
        ELSE 
          RAISE EXCEPTION 'Student not registered';
        END IF;

        -- Check if course still full, if not add next in line from waitinglist.
        IF(SELECT CourseFull(OLD.course) = FALSE 
        AND OLD.course IN(SELECT wl.course FROM WaitingList wl))
            THEN 
            nextInLine = (SELECT student 
            FROM Waitinglist WHERE (course = OLD.course)
            ORDER BY position LIMIT 1);
            DELETE FROM WaitingList WHERE (student = nextInLine AND course = OLD.course);
            INSERT INTO Registrations VALUES(nextInLine, OLD.course);
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


-- Check if course full
CREATE OR REPLACE FUNCTION CourseFull(inputCourse CHAR(6)) RETURNS BOOLEAN AS $$
    BEGIN
     IF EXISTS(SELECT code FROM LimitedCourses WHERE code = inputCourse)
		AND ((SELECT COALESCE(COUNT(student),0) FROM Registered rg WHERE rg.course = inputCourse)
			>= (SELECT capacity FROM LimitedCourses WHERE code = inputCourse)) THEN
        RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
$$ LANGUAGE plpgsql;

-- Crosscheck student prerequisite
CREATE OR REPLACE FUNCTION PreReqCheck(studentId CHAR(10), course CHAR(6)) RETURNS BOOLEAN AS $$
    BEGIN
        IF(course NOT IN(SELECT pq.course FROM prerequisites pq))
            THEN RETURN TRUE;
        ELSIF(course IN (
            SELECT pq.course FROM prerequisites pq) AND course IN
            (SELECT tk.course FROM Taken tk WHERE (tk.student = studentId)))
            THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER registerTrigger
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();

CREATE TRIGGER unregisterTrigger
INSTEAD OF DELETE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unregisterCourse ();
