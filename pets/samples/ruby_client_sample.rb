#!/usr/bin/ruby

# Program: ruby_client_sample.pl
# Usage: ./ruby_client_sample.pl
# Purpose: ruby language sample client program for Perl Petstore Enhanced API Server
# Copyright: James Briggs USA 2016
# Env: Ruby 2
# Returns:

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
  base_uri ENV['PETS_DOMAIN']+ENV['PETS_BASE_URL']
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

puts "Get one pet:"
url='/pets/1'
puts Pets.new(user, pass).get(url).inspect, "\n"

puts "Update one pet:"
data = {
   'name' => 'zebra'
}
url='/pets'
puts Pets.new(user, pass).put(url, data).inspect, "\n"

#puts "Get list of pets:"
#url='/pets'
#puts Pets.new(user, pass).get(url).inspect, "\n"

