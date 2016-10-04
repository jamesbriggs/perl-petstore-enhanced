#!/usr/bin/python

# Program: python_client_sample.py
# Purpose: Python language sample client program for Perl Petstore Enhanced API Server
# Copyright: James Briggs USA 2016
# Env: Python 2.6 or newer
# Returns: exit status is non-zero on failure
# Usage: ./python_client_sample.py
# Note: For Centos6 python 2.6, do: yum install python-pip
#   pip install requests
#   source ../set.sh

import json
import os
import requests
from requests.auth import HTTPBasicAuth
from pprint import pprint

scheme   = os.environ['PETS_SCHEME']
domain   = os.environ['PETS_DOMAIN']
base_url = os.environ['PETS_BASE_URL']
timeout  = float(os.environ['PETS_TIMEOUT'])
user     = os.environ['PETS_USER']
password = os.environ['PETS_PASSWORD']
admin_user     = os.environ['PETS_ADMIN_USER']
admin_password = os.environ['PETS_ADMIN_PASSWORD']

url = scheme + domain + base_url

headers   = {'Content-type': 'application/json'}

msg_json_error = 'error: decoding JSON failed ...'

def output(myResponse):
   #print (myResponse.status_code)

   # For a successful API call, response code will be 200 (OK) or 201 (Created)
   if(myResponse.ok):
     # Loads (Load String) takes a Json file and converts into python data structure (dict or list, depending on JSON)
     jData = json.loads(myResponse.content)
     #print("The response contains {0} properties".format(len(jData))) + "\n"
     for key in jData:
         print key + " : ", jData[key]
     print "\n";
   else:
     myResponse.raise_for_status()
     pprint(vars(myResponse))

try:
   print "Create a request to fetch a pet:\n";
   myResponse = requests.get(url + "/pets/1", auth=HTTPBasicAuth(user, password), headers=headers, timeout=timeout)
   output(myResponse)
except requests.exceptions.RequestException as e:
   print e
except ValueError as e:
   print msg_json_error, e

try:
   print "Create a request to add a pet:\n";
   data      = {"name" : "zebra"}
   data_json = json.dumps(data)
   myResponse = requests.put(url + "/pets", auth=HTTPBasicAuth(user, password), data=data_json, headers=headers, timeout=timeout)
   output(myResponse)
except requests.exceptions.RequestException as e:
   print e
except ValueError as e:
   print msg_json_error, e

try:
   print "Create a request to do a simple health check:\n";
   myResponse = requests.get(url+'/admin/ping', auth=HTTPBasicAuth(admin_user, admin_password), timeout=timeout)
   output(myResponse)
except requests.exceptions.RequestException as e:
   print e
except ValueError as e:
   print msg_json_error, e

try:
   print "Create a request to fetch list of pets:\n";
   myResponse = requests.get(url + "/pets", auth=HTTPBasicAuth(user, password), headers=headers, timeout=timeout)
   output(myResponse)
except requests.exceptions.RequestException as e:
   print e
except ValueError as e:
   print msg_json_error, e

exit(0)
