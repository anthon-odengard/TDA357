
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/postgres";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
        try(PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Registrations VALUES (?,?, 'registered')")){
            ps.setString(1,student);
            ps.setString(2, courseCode);
            ps.executeUpdate();
            return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        /*
        String upd = "INSERT INTO Registrations VALUES ('"+student+"','"+courseCode+"', 'registered')";

        try(Statement s = conn.createStatement()){
        s.executeUpdate(upd);
        return "{\"success\":true}";
        } catch (SQLException e) {
           return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
        */
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        //TODO: It won't give an error if the student is not registered/waiting or the
        // course does not exist (i.e. 0 rows deleted)
        try(PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM Registrations WHERE student = ? AND course = ?")){
            ps.setString(1,student);
            ps.setString(2, courseCode);
            int x = ps.executeUpdate();
            System.out.println(ps);
            System.out.println("x = " + Integer.toString(x));
            if(x == 0){
                return "{\"success\":false, \"error\":\" Nothing was deleted \"}";
            } else{
                return "{\"success\":true}";
            }
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        /*
        String upd = "DELETE FROM Registrations WHERE student = '"+student+"' AND course = '"+courseCode+"'";
        try(Statement s = conn.createStatement()){
            int x = s.executeUpdate(upd);
            if (x < 0){
                return "{\"success\":false, \"error\":\"nothing was deleted\"}";
            } else{
                return "{\"success\":true}";
            }
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
        */
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema
    // found in information_schema.json
    // "student", "name", "login", "program", "branch", "finished", "registered", "seminarCourses", "mathCredits",
    // "researchCredits", "totalCredits", "canGraduate"
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement stBasic = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object('student',idnr,'name',name,'login',login,'program',program,'branch',branch)" +
                    "AS jsondata FROM BasicInformation WHERE idnr=?"
            ); PreparedStatement stFinished = conn.prepareStatement(
            "SELECT jsonb_build_object('course',Courses.name,'code',Courses.code,'credits',credits,'grade',grade)"+
                    "AS jsondata FROM Taken LEFT JOIN Courses ON Taken.course = Courses.code WHERE Taken.student=?"
            ); PreparedStatement stRegistered = conn.prepareStatement(
            "SELECT jsonb_build_object('course',Courses.name,'code',Registrations.course,'status',status," +
                    "'position',place) " +
                    "AS jsondata FROM Registrations " +
                    "LEFT JOIN Courses ON Courses.code = Registrations.course " +
                    "FULL JOIN CourseQueuePositions ON Registrations.course = CourseQueuePositions.course AND " +
                    "Registrations.student = CourseQueuePositions.student " +
                    "WHERE Registrations.student=?"
            ); PreparedStatement stPathToGrad = conn.prepareStatement(
            "SELECT jsonb_build_object('seminarCourses',seminarCourses,'mathCredits',mathCredits," +
                    "'researchCredits',researchCredits,'totalCredits',totalCredits,'canGraduate',qualified) " +
                "AS jsondata FROM PathToGraduation WHERE student=?"
            );){
            
            stBasic.setString(1, student);
            stFinished.setString(1, student);
            stRegistered.setString(1, student);
            stPathToGrad.setString(1, student);

            ResultSet rsBasic = stBasic.executeQuery();
            ResultSet rsFinished = stFinished.executeQuery();
            ResultSet rsRegistered = stRegistered.executeQuery();
            ResultSet rsPathToGrad = stPathToGrad.executeQuery();

            if(rsBasic.next() && rsFinished.next() && rsRegistered.next() && rsPathToGrad.next())
              return rsBasic.getString("jsondata") + rsFinished.getString("jsondata") +
                      rsRegistered.getString("jsondata") + rsPathToGrad.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}";
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}