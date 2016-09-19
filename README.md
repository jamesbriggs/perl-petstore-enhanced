Perl Petstore Enhanced REST API Framework
=========================================

**Summary**

This is a much enhanced, yet still minimal, version of the Swagger Petstore sample code using Perl Mojolicious/Swagger2.

Using this sample code and installation guide as a framework, an experienced programmer can write a feature-rich REST API server in about an hour.

**Overview**

Anybody can hand-roll a REST API server, but the tricky part is generating and maintaining 100% accurate validation and documentation for end-users.

Perl Swagger2 lets you define your API spec in YAML or JSON, then automatically generates the following:

- input and output validation
- controller (aka dispatcher or router) to map URLs to function calls
- display of HTML documentation for end-users
- automatic content negotiation for JSON, XML and text.
- display of routes for debugging:

```

  +/               GET  "infoPets"

  +/doc            GET  "docPets"

  +/pets           GET  "listPets"

  +/pets           PUT  "createPets"

  +/admin/ping     GET  "pingPets"

  +/admin/menu     GET  "menuPets"

  +/pets/(:petId)  GET  "showPetById"


```

**API Consumer Features**

- GET / shows HTML route summary (instead of only being available on error pages)
- GET /doc shows API spec in HTML format
- paging with offset and limit in /pets
- Content negotiation with ?format=json and ?format=xml to automatically select output format for non-documentation routes
- method override for clients to use POST with X-HTTP-Method-Override: {PATCH, PUT, DELETE}
- Param and Basic Authentication. Default is username=Perl, password=Bender.     

**Developer Features**

- sets common options like mode=production, secrets and title
- /admin route with separate admin username and password
- has complete set of typical development directories, including public/, samples/, t/, and templates/
- shows how to correctly version the API in the format v1.0
- stores sample pet data in an array to avoid database dependencies.
- command line examples of various Mojo and Swagger2 features in make.sh
- up-to-date api.spec swagger properties in JSON and YAML
- shows how to override automatic rendering by the Swagger2 controller using render()
- good test coverage.

**Operations Features**

- built-in process health-check endpoint: /admin/ping => pong
- my_throttle skeleton function
- mod_perl compatible - just add your functions to Pet.pm
- minimal dependencies - likely works with your existing version of Perl.

**Getting Started**

```

git clone git@github.com:jamesbriggs/perl-petstore-enhanced.git

su

cpan Mojolicious Mojolicious::Plugin::MethodOverride Swagger2 XML::Simple Test::Mojo JSON

chown -R root:root perl-petstore-enhanced/pets

cd perl-petstore-enhanced/pets

vi api.spec # configure 'host', 'basePath' and 'contact' properties near top of file

vi cgi-bin/pets.cgi set.sh # configure the install path, username, password, domain, schema  and base_url

source set.sh

prove

```

- decide where you want to install the pets/ folder for your web server
- configuration can be as simple as this:
`Alias /api /home/<myuser>/public_html/pets/cgi-bin/pets.cgi/api`
- verify Authorization header is being passed along by httpd if you want auth:
HTTP_AUTHORIZATION='Basic XXXXXXXXXXX'
For more info, see: http://stackoverflow.com/questions/26475885/authorization-header-missing-in-php-post-request
- Point your browser at http://www.example.com/api/v1.0/

**Getting Finished**

- now you can finish writing your own API with customized module and endpoint names
- change "Pets" to your module name, then "Pet" to your module name
- run the `prove` test command
- download Postman to easier do REST API development

**Convert Spec**

- Paste api.spec into http://editor.swagger.io/#/ to convert swagger spec from YAML to JSON (and back)

**Privacy and Security**

The point of an API server is to, well, serve.

But you can take the following security precautions before deploying on a web server:

- it's mandatory to use SSL in production or over the Internet because of payload injection or credentials sniffing
- non-SSL connections should be rejected outright, not redirected
- move the Controller module to some place outside DocumentRoot, like /perllib
- put configuration settings and passwords some place outside DocumentRoot, like /perllib
- remove the development templates, which display your environment settings.
- the Petstore files and directories should be owned by root and not writable by anybody else
- if you use a database, ensure your queries that allow user input use placeholders like ?.

Some more general web server security tips:

- httpd should run as a non-privileged user like `httpd, UID=510, GID=510`
- if it is a restricted access server, use an iptables rule or TCP wrappers to only allow VPN access

**Todo**

- cleanup /doc and 404 page content
- role auth?

**Links**

Some things to think about:

- http://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
- https://github.com/adnan-kamili/rest-api-response-format
- http://www.berenddeboer.net/rest/authentication.html

![cass_top screenshot](perl-petstore-enhanced-info.png?raw=true "Perl Petstore Enhanced Info screenshot")
![cass_top screenshot](perl-petstore-enhanced-prove.png?raw=true "Perl Petstore Enhanced Prove screenshot")

