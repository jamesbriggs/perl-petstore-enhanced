// Program: JavaClientSample.java
// Purpose: Java language sample client program for Perl Petstore Enhanced API Server
// Copyright: James Briggs USA 2016
// Env: Java 1.8
// Returns: exit status is non-zero on failure
// Usage: java JavaClientSample
// Note: source ../set.sh

import java.util.List;
import java.util.Arrays;
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

      HttpURLConnection.setFollowRedirects(true);
      System.setProperty("http.maxRedirects", "3");

      // response Map with HTTP response headers, response code and content body
      Map<String, List<String>> r;

      try {
         System.out.println("1. Get list of pets");
         r = obj.send(url + "/pets", username, password, timeout, "", "GET");
         System.out.println(r.get("body").get(0));
      }
      catch (IOException e) {
         System.out.println(e);
      }

      try {
         System.out.println("2. Get one pet");
         r = obj.send(url + "/pets/1", username, password, timeout, "", "GET");
         System.out.println(r.get("body").get(0));
      }
      catch (IOException e) {
         System.out.println(e);
      }

      String location = "";
      int rc = 0;

      try {
         System.out.println("3. Add one pet");

         // Xlint gripes because json-simple relies on raw Map
         @SuppressWarnings("unchecked")
         Map<String, String> json = new JSONObject();
         json.put("name", "zebra");

         String data = new String(json.toString());
         r = obj.send(url + "/pets", username, password, timeout, data, "PUT");
         System.out.println(r.get("body").get(0));

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
            System.out.println(r.get("body").get(0));
         }
         catch (IOException e) {
            System.out.println(e);
         }
      }

      try {
         System.out.println("5. Do health check");
         r = obj.send(url + "/admin/ping", admin_username, admin_password, timeout, "", "GET");
         System.out.println(r.get("body").get(0));
      }
      catch (IOException e) {
         System.out.println(e);
      }
   }

   // HTTP request
   private Map<String, List<String>> send(String url, String username, String password, int timeout, String data, String method) throws Exception {

      URL obj = new URL(url);
      HttpURLConnection con = (HttpURLConnection) obj.openConnection();
      BufferedReader in = null;
      DataOutputStream wr = null;

      try {
         // Set request headers
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
            wr = new DataOutputStream(con.getOutputStream());
            wr.writeBytes(data);
            wr.flush();
         }

         // Get response headers
         int responseCode = con.getResponseCode();

         String inputLine;
         StringBuffer response = new StringBuffer();

         in = new BufferedReader(new InputStreamReader(con.getInputStream()));
         while ((inputLine = in.readLine()) != null) {
            response.append(inputLine).append("\n");
         }

         // getHeaderFields() returns an unmodifiable Map of the header fields so ...
         // Make a writable copy of headers to add body and response code
         Map<String, List<String>> h = new HashMap<String, List<String>>(con.getHeaderFields());

         h.put("body", Arrays.asList(response.toString()));
         h.put("response-code", Arrays.asList(String.valueOf(responseCode)));

         return h;
     } finally {
         if (con != null) con.disconnect();
         if (wr != null) wr.close();
         if (in != null) in.close();
     }
   }
}
