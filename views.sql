CREATE VIEW BasicInformation AS
    SELECT st.idnmr, st.name, st.login, st.program, sb.branch
    FROM Students st 
    LEFT OUTER JOIN StudentBranches sb ON st.idnmr = sb.student;

CREATE VIEW FinishedCourses AS
    SELECT tk.student, tk.course, tk.grade, c.credits
    FROM Taken tk 
    LEFT OUTER JOIN Courses c ON tk.course = c.code;

CREATE VIEW PassedCourses AS
  SELECT tk.student, tk.course, c.credits
    FROM Taken tk 
    LEFT OUTER JOIN Courses c ON tk.course = c.code 
    WHERE tk.grade IN ('3','4','5');

CREATE VIEW Registrations AS
    SELECT *
    FROM
  (SELECT *
    FROM Registered
    UNION
    SELECT student, course
    FROM WaitingList) r
    LEFT OUTER JOIN WaitingList wl ON (r.student = wl.student AND r.course = wl.course);


-- Work in progress