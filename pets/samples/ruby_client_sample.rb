#!/usr/bin/ruby

# Program: ruby_client_sample.pl
# Usage: ./ruby_client_sample.pl
# Purpose: ruby language sample client program for Perl Petstore Enhanced API Server
# Copyright: James Briggs USA 2016
# Env: Ruby 2
# Notes: sudo gem install httparty
#  source ../set.sh

require 'rubygems'
require 'httparty'

user=ENV['PETS_USER']
pass=ENV['PETS_PASSWORD']

admin_user=ENV['PETS_ADMIN_USER']
admin_pass=ENV['PETS_ADMIN_PASSWORD']

class Pets
  include HTTParty
# see http://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/ClassMethods
  format :json
  base_uri ENV['PETS_SCHEME']+ENV['PETS_DOMAIN']+ENV['PETS_BASE_URL']
  default_timeout ENV['PETS_TIMEOUT'].to_f
  headers 'Content-Type' => 'application/json'

  def initialize(user, pass)
    self.class.basic_auth user, pass
  end

  def get(url)
    self.class.get(url)
  end

  def post(url, text)
    self.class.post(url, :body => text.to_json)
  end

  def put(url, text)
    self.class.put(url, :body => text.to_json)
  end

  def delete(url, text)
    self.class.delete(url, :body => text.to_json)
  end
end

begin
   puts "Get one pet:"
   url='/pets/1'
   response = Pets.new(user, pass).get(url)
   if response.code == 200
      puts response.body, "\n"
   else
      puts response.inspect, "\n"
   end
rescue => e
  puts "Rescued: #{e.inspect}", "\n"
end

begin
   puts "Update one pet:"
   data = {
      'name' => 'zebra'
   }
   url='/pets'
   response = Pets.new(user, pass).put(url, data)
   if response.code == 201
      puts response.body, "\n"
   else
      puts response.inspect, "\n"
   end
rescue => e
  puts "Rescued: #{e.inspect}", "\n"
end

begin
   puts "Get list of pets:"
   url='/pets'
   response = Pets.new(user, pass).get(url)
   if response.code == 200
      puts response.body, "\n"
   else
      puts response.inspect, "\n"
   end
rescue => e
  puts "Rescued: #{e.inspect}", "\n"
end

begin
   puts "Basic healthcheck:"
   url='/admin/ping'
   response = Pets.new(admin_user, admin_pass).get(url)
   if response.code == 200
      puts response.body, "\n"
   else
      puts response.inspect, "\n"
   end
rescue => e
  puts "Rescued: #{e.inspect}", "\n"
end

exit 0
