# Class: Product
#
# Creates new Product objects.
#
# Attributes
# @id          - Integer: Primary key for the products table
# @category_id - Integer: Foreign key represeting the Product object's category
# @location_id - Integer: Foreign key representing the Product object's location
# All attributes are the values of the options hash.

class Product
  
  include Insert_Save
  extend Seek
  attr_accessor :category_id, :location_id, :id
  
  def initialize(options)
    @id       = options["id"]
    @category_id = options["category_id"]
    @location_id = options["location_id"]
  end
  
end