import org.json.JSONObject;
import java.sql.*;
import java.util.*;
import com.fasterxml.jackson.databind.*;


/**
 * Class that establishes connection and handles quieries to a given DB
 */

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

    /**
     *
     * @param db URL for database
     * @param user DB user
     * @param pwd DB password
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        //Establish connection to local DB using URL and props
        conn = DriverManager.getConnection(db, props);
    }

    /**
     * This method register students to a program provided
     * by the user.
     *
     * @param student Student to register
     * @param courseCode code of course to register to
     * @return JSON document (as a String)
     */
    public String register(String student, String courseCode){
        // Prepare a statment to be excecuted on DB connection
      try(PreparedStatement ps = conn.prepareStatement("INSERT INTO Registrations VALUES(?,?)");){
          // Using wildcards we need to initate its values
          ps.setString(1, student);
          ps.setString(2, courseCode);
          // Triggers prepared statement
          ps.executeUpdate();
      // returnt true if no error generated
      return "{\"success\":true}";
      // Here's a bit of useful code, use it or delete it 
     } catch (SQLException e) {
         return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
    }

    /**
     * This method unregister students to a program provided
     * by the user.
     *
     * @param student Student to unregister
     * @param courseCode code of course to register to
     * @return JSON document (as a String)
     */
    public String unregister(String student, String courseCode){
        try(PreparedStatement ps = conn.prepareStatement("DELETE FROM Registrations WHERE student = ? AND course = ?");){
            ps.setString(1, student);
            ps.setString(2, courseCode);
            // Triggers prepared statement
            ps.executeUpdate();
            return "{\"success\":true}";
            // Here's a bit of useful code, use it or delete it
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException {

        try (PreparedStatement ps = conn.prepareStatement("SELECT json_build_object(" +
                "    'student', (SELECT idnr from BasicInformation WHERE idnr= st.idnr)," +
                "    'name', (SELECT name FROM BasicInformation WHERE idnr = st.idnr)," +
                "    'login', (SELECT login FROM BasicInformation where idnr = st.idnr)," +
                "    'program', (SELECT program FROM BasicInformation WHERE idnr = st.idnr)," +
                "    'branch', (SELECT branch FROM BasicInformation WHERE idnr = st.idnr)," +
                "    'finished', (SELECT json_agg(fc) FROM (SELECT cs.name, fc.course, cs.code, fc.credits, fc.grade" +
                "                FROM FinishedCourses fc" +
                "                LEFT JOIN Courses cs ON (fc.course = cs.code) WHERE (fc.student = st.idnr )) fc)," +
                "    'registered', (SELECT json_agg(rg) FROM (SELECT cs.name AS course, cs.code, rs.status, cqp.position" +
                "    FROM Registrations rs" +
                "    LEFT JOIN Courses cs ON cs.code = rs.course" +
                "    FULL JOIN CourseQueuePositions cqp ON (rs.course = cqp.course) AND " +
                "                    (cqp.student = cqp.student) WHERE (rs.student = st.idnr)) rg)," +
                "    'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student = st.idnr)," +
                "    'mathCredits', (SELECT mathCredits FROM PathToGraduation WHERe student = st.idnr)," +
                "    'researchCredits', (SELECT researchCredits FROM PathToGraduation WHERe student = st.idnr)," +
                "    'totalCredits',(SELECT totalCredits FROM PathToGraduation WHERe student = st.idnr)," +
                "    'canGraduate',(SELECT qualified FROM PathToGraduation WHERe student = st.idnr) " +
                "    ) AS jsondata FROM Students st WHERE st.idnr= ?");) {


            ps.setString(1, student);

            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getString("jsondata");
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