# Class: Category
#
# Creates new Category objects.
#
# Attributes:
# @id         - Integer: Primary key for the categories table
# @name       - String : The name of the Category object.
# @cost       - Integer: The cost of the Category object.
# description - String : A brief description of the Category object.
# All attributes are the values of the options hash.

class Category
  
  include Insert_Save
  extend Seek
  attr_accessor :id, :name, :cost, :description
   
  
  def initialize(options)
    @id          = options["id"]
    @name        = options["name"] 
    @cost        = options["cost"]
    @description = options["description"]
  end
  
end