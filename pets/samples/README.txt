Petstore Enhanced Sample Client Programs

After the server is listening, you can send it REST API requests using the included client programs.

Steps:

1. source ../set.sh
2. ./curl_client_sample.sh
3. ./JavaClientSample.java
4. ./perl_client_sample.pl
5. ./php_client_sample.php
6. ./python_client_sample.py
7. ./ruby_client_sample.rb
8. ./wget_client_sample.sh (curl is more REST API-friendly, so use curl if possible)

These are short but non-trivial programs with features such as:

- GET, PUT, DELETE methods
- HTTP basic authentication
- connection timeout
- error handling based on HTTP response codes
- separate user and admin credentials.

Take a look at the source code to see how to write your own programs.

