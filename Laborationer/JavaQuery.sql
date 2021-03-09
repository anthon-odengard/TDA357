SELECT json_build_object(
    
    'student', (SELECT idnr from BasicInformation WHERE idnr= st.idnr),
    'name', (SELECT name FROM BasicInformation WHERE idnr = st.idnr),
    'login', (SELECT login FROM BasicInformation where idnr = st.idnr),
    'program', (SELECT program FROM BasicInformation WHERE idnr = st.idnr),
    'branch', (SELECT branch FROM BasicInformation WHERE idnr = st.idnr),
    'finished', (SELECT json_agg(fc) FROM (SELECT cs.name, fc.course, cs.code, fc.credits, fc.grade
                FROM FinishedCourses fc
                LEFT JOIN Courses cs ON (fc.course = cs.code) WHERE (fc.student = st.idnr )) fc),
    'registered', (SELECT json_agg(rg) FROM (SELECT cs.name AS course, cs.code, rs.status, cqp.position
    FROM Registrations rs
    LEFT JOIN Courses cs ON cs.code = rs.course
    FULL JOIN CourseQueuePositions cqp ON (rs.course = cqp.course) AND 
                    (cqp.student = cqp.student) WHERE (rs.student = st.idnr)) rg),
    'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student = st.idnr),
    'mathCredits', (SELECT mathCredits FROM PathToGraduation WHERE student = st.idnr),
    'researchCredits', (SELECT researchCredits FROM PathToGraduation WHERE student = st.idnr),
    'totalCredits',(SELECT totalCredits FROM PathToGraduation WHERe student = st.idnr),
    'canGraduate',(SELECT qualified FROM PathToGraduation WHERE student = st.idnr) 
    ) AS jsondata FROM Students st WHERE st.idnr= '2222222222';


