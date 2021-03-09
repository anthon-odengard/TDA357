public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();

         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)
         System.out.println("======== 1. List info for a student ========");
         prettyPrint(c.getInfo("4444444444"));
         System.out.println(" ");
         pause();

         System.out.println("======== 2. Register a student for an unrestricted course, and check that he/she ends " +
                 "up registered. ========");
         System.out.println(c.getRegistrations());
         System.out.println(c.register("1111111111", "CCC111"));
         System.out.println(c.getRegistrations());
         System.out.println(" ");
         pause();

         System.out.println("======== 3. Register the same student for the same course again, and check that you get " +
                 "an error response. ========");
         System.out.println(c.register("1111111111", "CCC111"));
         System.out.println(" ");
         pause();

         System.out.println("======== 4. Unregister the student from the course, and then unregister him/her again " +
                 "from the same course. Check that the student is no longer registered and that the second " +
                 "unregistration gives an error response. ========");
         System.out.println(c.getRegistrations());
         System.out.println(c.unregister("1111111111", "CCC111"));
         System.out.println(c.getRegistrations());
         System.out.println(c.unregister("1111111111", "CCC111"));
         System.out.println(" ");
         pause();

         System.out.println("======== 5. Register the student for a course that he/she doesn't have the " +
                 "prerequisites for, and check that an error is generated.   ========");
         System.out.println(c.register("5555555555", "CCC222"));
         System.out.println(" ");
         pause();

         System.out.println("======== 6. Unregister a student from a restricted course that he/she is registered to, " +
                 "and which has at least two students in the queue. Register again to the same course and check that " +
                 "the student gets the correct (last) position in the waiting list. ========");
         System.out.println(c.getQueue("CCC555"));
         System.out.println(c.unregister("6666666666", "CCC555"));
         System.out.println(c.register("6666666666", "CCC555"));
         System.out.println(c.getQueue("CCC555"));
         System.out.println(" ");
         pause();

         System.out.println("======== 7. Unregister and re-register the same student for the same restricted course, " +
                 "and check that the student is first removed and then ends up in the same position as before (last). " +
                 "========");
         System.out.println(c.unregister("6666666666", "CCC555"));
         System.out.println(c.getQueue("CCC555"));
         System.out.println(c.register("6666666666", "CCC555"));
         System.out.println(c.getQueue("CCC555"));
         System.out.println(" ");
         pause();

         System.out.println("======== 8. Unregister a student from an overfull course. Check that no student was " +
                 "moved from the queue to being registered as a result. ========");
         System.out.println(c.getQueue("CCC777"));
         System.out.println(c.unregister("1111111111", "CCC777"));
         System.out.println(c.getQueue("CCC777"));
         System.out.println(" ");
         pause();

         System.out.println("======== 9. Unregister with the SQL injection you introduced, causing all " +
                 "(or almost all?) registrations to disappear.  ========");
         System.out.println(c.getRegistrations());
         String courseVulnerable = " '; DELETE FROM Registrations WHERE student <> 'XXX ";
         System.out.println(c.unregisterVulnerability("XXX", courseVulnerable));
         System.out.println(c.getRegistrations());
         System.out.println(" ");





/*
         System.out.println("======== 1A (pass) ========");
         System.out.println(c.register("5555555555", "CCC111"));
         System.out.println(" ");
         //pause();

         System.out.println("======== 1B (fail) ========"); //Student cannot register
         System.out.println(c.register("5555555555", "CCC222"));
         //System.out.println(" ");
         pause();

         System.out.println("======== 2 (pass) ========");
         System.out.println(c.unregister("5555555555", "CCC111"));
         //System.out.println(" ");
         pause();

         System.out.println("======== 3A (fail) ========"); //Student is not registered/waiting
         System.out.println(c.unregister("5555555555", "CCC111"));
         System.out.println(" ");
         //pause();

         System.out.println("======== 3B (fail) ========"); //Student doesn't exist
         System.out.println(c.unregister("7777777777", "CCC111"));
         System.out.println(" ");
         //pause();

         System.out.println("======== 3C (fail) ========"); //Course doesn't exist
         System.out.println(c.unregister("5555555555", "CCC999"));
         //System.out.println(" ");
         pause();

         System.out.println("======== 4 ========");
         prettyPrint(c.getInfo("2222222222"));
         System.out.println(" ");
         pause();

         System.out.println("======== 5 ========");
         prettyPrint(c.getInfo("4444444444"));
         System.out.println(" ");
         pause();

         System.out.println("======== 6 ========");
         String courseVulnerable = " '; DELETE FROM Registrations WHERE student <> 'XXX ";
         System.out.println(c.unregisterVulnerability("XXX", courseVulnerable));

*/


      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}