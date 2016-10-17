// Program: JavaClientSample.java
// Purpose: Java language sample client program for Perl Petstore Enhanced API Server
// Copyright: James Briggs USA 2016
// Env: Java 1.8
// Returns: exit status is non-zero on failure
// Usage: java JavaClientSample
// Note: source ../set.sh

import java.util.List;
import java.util.Arrays;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Base64;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.simple.JSONObject;

// import javax.net.ssl.HttpsURLConnection;

public class JavaClientSample {

   private final String USER_AGENT = "Mozilla/5.0";

   public static void main(String[] args) throws Exception {

      int timeout = 0;

      try {
         timeout = Integer.parseInt(System.getenv("PETS_TIMEOUT")) * 1000;
      }
      catch (NumberFormatException e) {
         System.out.println("error: do source ../set.sh first");
         System.exit(1);
      }

      final String url      = System.getenv("PETS_SCHEME") + System.getenv("PETS_DOMAIN") + System.getenv("PETS_BASE_URL");

      final String username = System.getenv("PETS_USER");
      final String password = System.getenv("PETS_PASSWORD");

      final String admin_username = System.getenv("PETS_ADMIN_USER");
      final String admin_password = System.getenv("PETS_ADMIN_PASSWORD");

      JavaClientSample obj = new JavaClientSample();

      // response dictionary with HTTP response headers, response code and content body
      Map<String, List<String>> r;

      try {
         System.out.println("1. Get list of pets");
         r = obj.send(url + "/pets", username, password, timeout, "", "GET");
         System.out.println(r.get("body").get(0)+"\n");
      }
      catch (IOException e) {
         System.out.println(e);
      }

      try {
         System.out.println("2. Get one pet");
         r = obj.send(url + "/pets/1", username, password, timeout, "", "GET");
         System.out.println(r.get("body").get(0)+"\n");
      }
      catch (IOException e) {
         System.out.println(e);
      }

      String location = "";
      int rc = 0;

      try {
         System.out.println("3. Add one pet");
         JSONObject json = new JSONObject();
         json.put("name", "zebra");
         String data = new String(json.toString());
         r = obj.send(url + "/pets", username, password, timeout, data, "PUT");
         System.out.println(r.get("body").get(0)+"\n");

         location = r.get("Location").get(0);
         rc = Integer.valueOf(r.get("response-code").get(0));
      }
      catch (IOException e) {
         System.out.println(e);
      }

      if (rc == 201) {
         try {
            System.out.println("4. Delete one pet");
            r = obj.send(location, username, password, timeout, "", "DELETE");
            System.out.println(r.get("body").get(0)+"\n");
         }
         catch (IOException e) {
            System.out.println(e);
         }
      }

      try {
         System.out.println("5. Do health check");
         r = obj.send(url + "/admin/ping", admin_username, admin_password, timeout, "", "GET");
         System.out.println(r.get("body").get(0)+"\n");
      }
      catch (IOException e) {
         System.out.println(e);
      }
   }

   // HTTP request
   private Map<String, List<String>> send(String url, String username, String password, int timeout, String data, String method) throws Exception {

      URL obj = new URL(url);
      HttpURLConnection con = (HttpURLConnection) obj.openConnection();

      //add request header
      con.setRequestMethod(method);
      con.setRequestProperty("User-Agent", USER_AGENT);
      con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
      // con.setRequestProperty("Accept-Encoding", "gzip, deflate");
      con.setRequestProperty("Content-Type", "application/json");

      con.setConnectTimeout(timeout);
      con.setReadTimeout(timeout);

      String encoded = Base64.getEncoder().encodeToString((username+":"+password).getBytes("UTF-8"));
      con.setRequestProperty("Authorization", "Basic "+encoded);

      // Send request
      con.setDoOutput(true);

      if (method.equals("POST") || method.equals("PUT")) {
         DataOutputStream wr = new DataOutputStream(con.getOutputStream());
         wr.writeBytes(data);
         wr.flush();
         wr.close();
      }

      int responseCode = con.getResponseCode();

      BufferedReader in = new BufferedReader(
        new InputStreamReader(con.getInputStream()));
      String inputLine;
      StringBuffer response = new StringBuffer();

      while ((inputLine = in.readLine()) != null) {
         response.append(inputLine);
      }
      in.close();

      // get a read-only copy of headers
      Map<String, List<String>> headerFields = con.getHeaderFields();

      // get a writable copy of headers to add body and response code
      HashMap h = new HashMap();
      h.put("body", Arrays.asList(response.toString()));
      h.put("response-code", Arrays.asList(String.valueOf(responseCode)));

      // append headers
      Iterator it = headerFields.entrySet().iterator();
      while (it.hasNext()) {
        Map.Entry pair = (Map.Entry)it.next();
        // http://stackoverflow.com/questions/16070070/why-does-list-removeint-throw-java-lang-unsupportedoperationexception
        // System.out.println(pair.getKey());
        // h.put(pair.getKey(), Arrays.asList(pair.getValue()));
        h.put(pair.getKey(), pair.getValue());
      }

      return h;
   }
}
