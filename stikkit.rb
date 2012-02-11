#! /usr/bin/env ruby

# == Synopsis
# 
# Query stikkit from the commandline.
# 
# == Usage
#   ruby stikkit.rb [ -h | --help ] [ -l | --list type parameters ] [ -t | --todos ] [ -c | --create text ]
#   type::
#     The type of stikkit to return (todos, calendar, etc.)
#   parameters::
#     Specify restrictions on the stikkits returned (e.g. 'dates=this+week')
#   text::
#     Content of the new stikkit
# 
# So, we can get today's events with:
#   ruby stikkit.rb -l calendar dates=today
# 
# --todos is a convenience method to get undone todos
# which is equivalent to:
#   ruby stikkit.rb -l todos done=0
# 
# Create a new stikkit:
#   ruby stikkit.rb -c 'Remember this text.'
# 
# == Installation
# Your username and password are stored in ~/.stikkit as a YAML file
#     ---
#     username: me@domain.org
#     password: superSecret
# 
# == Author
# Matthew Routley
# mailto:matt@routleynet.org http://matt.routleynet.org

#--
# TODO: Clean up the output of the create method
#++

require 'optparse' 
require 'rdoc/usage'
require 'net/http'
require 'cgi'
require 'yaml'
require 'rubygems'
require 'atom'

class Stikkit
  
  # The return type, make sure it matches the to_s method
  Format = 'atom'
  
  def initialize
    config = YAML.load_file(".stikkit")
    @username = config["username"]
    @password = config["password"]
  end
  
  def request(req)
    Net::HTTP.start('api.stikkit.com') { |http|
        req.basic_auth(@username, @password)
        http.request(req)
      }
  end
  
  # Returns a list of stikkits that match the type given 
  # with the supplied parameters
  # As examples, type = 'todos' & parameters = 'done=0'
  # returns all undone todos while type = 'calendar'
  # & parameters = 'dates=this+week' returns this week's events
  def list(type, parameters)
    @type = type  # Keep this around to structure the output
    @response = self.request(Net::HTTP::Get.new(
      "/#{type}.#{Format}?#{parameters}"
    ))
    self.to_s
  end

  # Creates a new stikkit with the inputted text
  def create(input)
    @response = self.request(Net::HTTP::Post.new(
        "/stikkits.atom?raw_text=#{CGI.escape(input)}"
      ))
    #-- TODO: This should be processed and useful output presented
    #++
    puts @response.body
  end
  
  # Structures the request for output.
  # Re-write this method for different return types
  # For example, if Format = 'json'
  #   require 'json'
  #   @body_array = JSON.parse(@response.body)
  #   @body_array.each {|item|
  #     puts item["name"]
  #   }
  def to_s
    puts @type.upcase
    10.times { print '=' }
    puts
    feed = Atom::Feed.new(@response.body)
    feed.entries.each { |entry|
        puts "#{entry.title}"
        }
    puts
  end
end

opts = OptionParser.new 
opts.on("-h", "--help") { RDoc::usage("Usage") }
opts.on("-l", "--list TYPE PARAMETERS") { Stikkit.new.list(ARGV[1], ARGV[2]) }
opts.on("-t", "--todos") { Stikkit.new.list('todos', 'done=0') }
opts.on("-c", "--create TEXT") { Stikkit.new.create(ARGV[1]) }
opts.parse(ARGV) rescue RDoc::usage()