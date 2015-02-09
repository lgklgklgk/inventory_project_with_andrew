# Class: Location
#
# Creates new Location objects
#
# Attributes:
# @id       - Integer: Primary key for the locations table.
# @name     - String : The name of the Location object.
# @capacity - Integer: The capacity of the Location object.
# All attributes are values in the options hash.

class Location
  
  include Insert_Save
  extend Seek
  attr_accessor :name, :capacity, :id
  
  def initialize(options)
    @id        = options["id"]
    @name      = options["name"]
    @capacity  = options["capacity"]
  end
  
end