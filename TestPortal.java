public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
   
         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)
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
         prettyPrint(c.getInfo("2222222222"));



      
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