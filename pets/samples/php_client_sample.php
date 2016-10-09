#!/usr/bin/php
<?php

// Program: php_client_sample.py
// Purpose: PHP language sample client program for Perl Petstore Enhanced API Server
// Copyright: James Briggs USA 2016
// Env: PHP5 or newer
// Returns: exit status is non-zero on failure
// Usage: ./php_client_sample.py
// Note: do:
//    source ../set.sh

   error_reporting(E_ALL);

   $url            = $_SERVER['PETS_SCHEME'] . $_SERVER['PETS_DOMAIN'] . $_SERVER['PETS_BASE_URL'];
   $user           = $_SERVER['PETS_USER'];
   $password       = $_SERVER['PETS_PASSWORD'];
   $admin_user     = $_SERVER['PETS_ADMIN_USER'];
   $admin_password = $_SERVER['PETS_ADMIN_PASSWORD'];
   $timeout        = $_SERVER['PETS_TIMEOUT'];

function http_parse_headers($header) {
// http://php.net/manual/it/function.http-parse-headers.php by Anon

   $retVal = array();
   $fields = explode("\r\n", preg_replace('/\x0D\x0A[\x09\x20]+/', ' ', $header));
   foreach( $fields as $field ) {
      if (preg_match('/([^:]+): (.+)/m', $field, $match)) {
         $match[1] = preg_replace('/(?<=^|[\x09\x20\x2D])./e', 'strtoupper("\0")', strtolower(trim($match[1])));
         if (isset($retVal[$match[1]]) ) {
            if (!is_array($retVal[$match[1]])) {
               $retVal[$match[1]] = array($retVal[$match[1]]);
            }
            $retVal[$match[1]][] = $match[2];
         } else {
            $retVal[$match[1]] = trim($match[2]);
         }
      }
   }
   return $retVal;
}

function do_curl($method, $endpoint, $user, $pw, $timeout, $data) {
   // echo "url=$endpoin\n";

   $headers = array(
      'Content-Type: application/json',
      'Authorization: Basic '. base64_encode("$user:$pw")
   );

   $ch = curl_init();

   curl_setopt($ch, CURLOPT_URL, $endpoint);
   curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
   curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
   curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
   curl_setopt($ch, CURLOPT_HEADER, 1);

   if ($method == 'POST' or $method == 'PUT') {
      curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);

      // for HTML form POST data:
      // curl_setopt($ch, CURLOPT_POSTFIELDS,http_build_query($data));

      // for JSON data:
      $json_data = json_encode($data);
      curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);
   }

   $response = curl_exec($ch);
   $info = curl_getinfo($ch);
   $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
   curl_close($ch);  

   $headers = substr($response, 0, $header_size);
   $body = substr($response, $header_size);

   $info['headers'] = http_parse_headers($headers);
   $info['body'] = $body;

   return $info;
}

   $ret = 0;

echo "get list of pets\n";
   $response = do_curl('GET', $url . '/pets', $user, $password, $timeout, NULL);
   $rc = $response['http_code'];
   if ($rc == '200') {
      echo "OK ($rc) - ";
   }
   else {
      echo "ERROR ($rc) - ";
      $ret++;
   }
   echo $response['body'];
   echo "\n\n";

echo "get one pet\n";
   $response = do_curl('GET', $url . '/pets/1', $user, $password, $timeout, NULL);
   $rc = $response['http_code'];
   if ($rc == '200') {
      echo "OK ($rc) - ";
   }
   else {
      echo "ERROR ($rc) - ";
      $ret++;
   }
   echo $response['body'];
   echo "\n\n";

   $data = array(
      "name" => "zebra"
   );

echo "add one pet\n";
   $response = do_curl('PUT', $url . '/pets', $user, $password, $timeout, $data);
   $rc = $response['http_code'];
   if ($rc == '201') {
      $location = $response['headers']['Location'];
      print "Location of new item is $location\n";
      echo "OK ($rc) - ";
   }
   else {
      echo "ERROR ($rc) - ";
      $ret++;
   }
   echo $response['body'];
   echo "\n\n";

//  echo var_dump($response);

echo "   get new pet (if mod_perl is running)\n";
print "location=$location\n";
   $response = do_curl('GET', $location, $user, $password, $timeout, NULL);
   $rc = $response['http_code'];
   if ($rc == '200') {
      echo "   OK ($rc) - ";
   }
   else {
      echo "   ERROR ($rc) - ";
      $ret++;
   }
   echo "\n\n";

   if ($response['http_code'] == '200') {
echo "   delete new pet (if mod_perl is running)\n";
      $response = do_curl('DELETE', $location, $user, $password, $timeout, NULL);
      $rc = $response['http_code'];
      if ($rc == '200' or $rc == '204') {
         echo "   OK ($rc) - ";
      }
      else {
         echo "   ERROR ($rc) - ";
         $ret++;
      }
      echo "\n\n";
   }

echo "do health check with admin account\n";
   $response = do_curl('GET', $url . '/admin/ping', $admin_user, $admin_password, $timeout, NULL);
   $rc = $response['http_code'];
   if ($rc == '200') {
      echo "OK ($rc) - ";
   }
   else {
      echo "ERROR ($rc) - ";
      $ret++;
   }
   echo $response['body'];
   echo "\n\n";

   exit($ret);
?>
