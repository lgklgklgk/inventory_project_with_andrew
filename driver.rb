require 'pry'
require 'SQLite3'
require_relative "modules.rb"
require_relative "class_modules.rb"
require_relative "product.rb"
require_relative "category.rb"
require_relative "location.rb"

WAREHOUSE = SQLite3::Database.new('warehouse.db')
# class Driver
#
# Boots all of the SQLite3 tables as well as the CLI for the program.
#
# Attributes:
# @objects - Array: An empty array.
#
# Public Methods:
# intitalize
# 
# Private Methods:
# self.boot_db
# pull
# h_line
# main_menu
# quit
# view_prod
# view_loca
# view_cate
# search_menu
# display
# second_menu
# add_menu
# delete_menu
# cram_and_menu
# entry_selector
# edit_menu
# delete_entry
# edit_entry
# foreign_keys
# cram_array
# print_objects
# print_products
# print_locations
# print_categories
class Driver
  
  def initialize
    @objects = []
    Driver.boot_db
    binding.pry
    main_menu
  end
  
  private
  
# Private: self.boot_db
# Creates the tables products, categories, and locations unless they already
# exist.

  def self.boot_db
    WAREHOUSE.results_as_hash = true
    WAREHOUSE.execute("CREATE TABLE IF NOT EXISTS products
                     (id INTEGER PRIMARY KEY,
                      category_id INTEGER,
                      location_id INTEGER)")
    WAREHOUSE.execute("CREATE TABLE IF NOT EXISTS categories
                     (id INTEGER PRIMARY KEY,
                      name TEXT,
                      description TEXT,
                      cost INTEGER)")
    WAREHOUSE.execute("CREATE TABLE IF NOT EXISTS locations
                     (id INTEGER PRIMARY KEY,
                      name TEXT,
                      capacity INTEGER)")
                      
  end
  
# Private h_line
#
# Creates a pretty dash that is easy on the eyes and makes our interface easier
# to read.

  def h_line
    puts "-" * 80
  end
  
# Private: main_menu
#
# Establishes the main menu screen and accepts valid entries which sends the 
# user to the appropriate menu.
  
  def main_menu
    system "clear"
    puts "ANDREW AND LUKE'S WAREHOUSE"
    h_line
    puts "1: VIEW ALL PRODUCTS"
    puts "2: VIEW ALL LOCATIONS"
    puts "3: VIEW ALL CATEGORIES"
    puts "4: QUIT"
    h_line
    input = nil
    loop do
      puts "Please enter a valid selection."
      input = gets.to_i
      break if input > 0 && input < 5
    end
    a = ["view_prod","view_loca","view_cate","quit"]
    send(a[input - 1])
  end
  
# Private: quit
#
# An option on the main menu, quits the program.
  
  def quit
    abort ("THANK YOU.")
  end
  
# Private: view_prod
#
# An option of the main menu. It populates the @objects array with Product 
# objects that the seek_all method creates from the SQL table. It then displays
# those objects.
#
# State Changes: Sets @objects to an array of Product objects populated from the
# SQL table.
  
  def view_prod
    system "clear"
    h_line
    puts "VIEWING ALL PRODUCTS"
    @objects = Product.seek_all
    display
  end
  
# Private: view_loca
#
# An option of the main menu. It populates the @objects array with Location 
# objects that the seek_all method creates from the SQL table. It then displays
# those objects.
#
# State Changes: Sets @objects to an array of Location objects populated from 
# the SQL table.
  
  def view_loca
    system "clear"
    h_line
    puts "VIEWING ALL LOCATIONS"
    @objects = Location.seek_all
    display
  end
  
# Private: view_cate
#
# An option of the main menu. It populates the @objects array with Category 
# objects that the seek_all method creates from the SQL table. It then displays
# those objects.
#
# State Changes: Sets @objects to an array of Category objects populated from
# the SQL table.  
  
  def view_cate
    system "clear"
    h_line
    puts "VIEWING ALL CATEGORIES"
    @objects = Category.seek_all
    display
  end
  
# Private: search_menu
# 
# Displays all the items in a specific table's specific column, which meet a 
# specific criteria specified by the user. SPECIFIC.
# 
# State Changes:
# Sets the @objects array to an array containing the object(s) in a specified 
# column with a specific value created by the seek method.  
  
  def search_menu
    class_type = @objects[0].class
    columns = @objects[0].instance_variables
    puts "WHAT DO YOU WANT TO SEARCH BY?"
    h_line
    counter = 1
    columns.each do |attribute|
      name = attribute.to_s.delete('@')
      puts "#{counter}: #{name}"
      counter +=1
    end
    selection = nil
    loop do
      puts "INPUT A VALID SELECTION:"
      selection = gets.to_i
      break if selection > 0 && selection <= columns.length
    end
    attribute_name = columns[selection - 1].to_s.delete('@')
    foreign_keys(attribute_name)
    puts "WHAT #{attribute_name.upcase} ARE YOU SEARCHING FOR?"
    value_type = @objects[0].send(columns[selection - 1].to_s.delete("@"))
    value = gets.chomp if value_type.is_a?(String)
    value = gets.to_i if value_type.is_a?(Integer)
    @objects = class_type.seek(attribute_name,value)
    display
  end
  
# Private: display
#
# A formatting method that clears the command line interface, prints the 
# current @objects array, and then boots the second_menu. 

  def display
    system "clear"
    print_objects(@objects)
    second_menu
  end
  
# Private: second_menu
#
# Prints the options of the second menu, and accepts the user's valid choice to
# proceed.
  
  def second_menu
    h_line
    classes = @objects[0].class
    puts "1: EDIT ENTRY"
    puts "2: DELETE ENTRY"
    puts "3: ADD ENTRY"
    puts "4: SEARCH IN #{classes.to_s.upcase}"
    puts "5: SAVE CHANGES AND RETURN TO MAIN MENU"
    puts "6: ABANDON CHANGES AND RETURN TO MAIN MENU"
    input = nil
    loop do
      puts "Please enter a valid selection."
      input = gets.to_i
      break if input > 0 && input < 7
    end
    a = ["edit_menu","delete_menu","add_menu","search_menu","cram_and_menu","main_menu"]
    send(a[input - 1])
  end
  
# Private: add_menu
#
# Creates a new object in a given class table and then pushes it into the 
# @objects array.
#
# State Changes:
# Adds a new object into the @objects array
  
  def add_menu
    puts ""
    class_str = @objects[0].class.to_s
    puts "ADDING NEW #{class_str.upcase}:"
    var_array = @objects[0].instance_variables
    options = {}
    var_array.each do |entry|
      attribute = entry.to_s.delete("@")
      if attribute != "id"
        foreign_keys(attribute)
        puts "INPUT NEW #{attribute}:"
        input = gets.chomp if @objects[0].send(attribute).is_a?(String)
        input = gets.to_i if @objects[0].send(attribute).is_a?(Integer)
        options[attribute] = input
      end
    end
    @objects << @objects[0].class.new(options)
    display
  end
  
# Private: delete_menu
#
# Sets the which item is to be deleted to a variable, and then passes that to 
# the delete_entry method.
  
  def delete_menu
    deleting = entry_selector("DELETE")
    delete_entry(deleting)
  end
  
# Private cram_and_menu
#
# Runs the cram array method and returns to the main menu.  

  
  def cram_and_menu
    cram_array(@objects)
    main_menu
  end
  
# Private: entry_selector
#
# A method used for both editing and deleting that ensures the user selects a 
# valid primary id to edit or delete. Works in all classes.
#
# Parameters:
# string - String: delineates whether or not the user is editing or deleting
# an object.
# 
# Returns: editing, a variable equal the counter of the user's selection.
    
  def entry_selector(string)
    puts "SELECT AN ENTRY ID TO #{string}:"
    selection = gets.to_i
    counter = 0
    editing = nil
    @objects.each do |object|
      editing = counter if selection == object.id
      counter += 1
    end
    if editing == nil
      puts "SORRY, THAT ID WAS NOT INCLUDED."
      print_objects(@objects)
      second_menu
    end
    editing
  end
  
# Private edit_menu
#
# Sets the item which is to be edited to a variable, and then passes that to the
# edit_entry method.
    
  def edit_menu
    editing = entry_selector("EDIT")
    
    edit_entry(editing)
  end
  
# Private delete_entry
#
# Marks an object in the @objects array for deletion, specified by the user.
# If the object is a Location or Category it will not allow you to delete it
# if there are still products assigned to that particular Location/Category.
#
# Parameters:
# deleting - Integer: The counter produced from the entry_selector method. Used
# to identify which object to delete.
# 
# State Changes:
# Marks an object in the @objects array for deletion.
  
  def delete_entry(deleting)
    this_id = @objects[deleting].id
    tester =[]
    class_str = @objects[deleting].class.to_s
    if class_str == "Category" || class_str == "Location"
      column_name = class_str.downcase + "_id"
      tester = Product.seek(column_name,this_id) 
    end
    if tester == []
      @objects[deleting].mark_x
    else
      puts "THERE ARE STILL PRODUCTS IN THAT " + class_str.upcase
    end
    
    display
  end
  
# Private edit_entry
#
# Prompts the user for an attribute to edit and then accepts an input to be 
# edited. Works for all classes universally, and will actually change the value
# of the instance variable of the object that the user chooses.
#
# Parameters:
# editing - Integer: Represents the counter of the object to be edited. Lets the
# method know which object is to be edited.
#
# State Changes:
# Edits a specific attribute of an object in the @objects array.
  
  def edit_entry(editing)
    var_array = @objects[editing].instance_variables
    counter = 1
    var_array.each do |variable|
      value = @objects[editing].send(variable.to_s.delete("@"))
      if variable != :@id
        puts "#{counter} - #{variable.to_s.delete("@")}: #{value}"
        counter += 1
      end
    end
    h_line
    input = nil
    loop do
      puts "SELECT A VALID FIELD TO EDIT:"
      input = gets.to_i
      break if input > 0 && input <= (var_array.length - 1)
    end
    attribute = var_array[input].to_s.delete("@")
    value = @objects[editing].send(var_array[input].to_s.delete("@"))
    puts "ORIGINAL #{attribute}: #{value}"
    puts "INPUT NEW #{attribute}:"
    foreign_keys(attribute)
    input = gets.chomp if value.is_a?(String)
    input = gets.to_i if value.is_a?(Integer)
    
    send_method = attribute + "="
    @objects[editing].send(send_method, input)
    display
  end
  
# Private: foreign_keys
#
# Determines if a @category_id or @location_id is being added or edited and if 
# so displays the appropriate table of objects. This makes it much easier for
# the user to make a selection.
#
# Paramters:
# Attribute - String: the attribute of the object being worked on.
#
# Returns:
# The objects array.  
  
  def foreign_keys(attribute)
    if attribute == "category_id" || attribute == "location_id"
      array = Category.seek_all if attribute == "category_id"
      array = Location.seek_all if attribute == "location_id"
      
      print_objects(array)
    end
  end
  
# Private: cram_array
#
# A method that performs the cram method on an array of objects.
#
# Parameters:
# array - Array: an array of objects.

  
  def cram_array(array)
    array.each do |object|
      object.cram
    end
  end
  
# Private: print_objects
#
# Takes an array of objects and determines which class they belong to.
#
# Parameters:
# array - Array: an array of objects.
  
  def print_objects(array)
    if array[0].class == Product
      print_products(array)
    elsif array[0].class == Category
      print_categories(array)
    else
      print_locations(array)
    end
  end
  
# Private print_products
#
# Prints out a formatted list of all of the Product objects.
#
# Parameters:
# array - Array: an array containing all of the Product objects.

  
  def print_products(array)
    puts "id".ljust(5)+"category".ljust(15)+"location"
    h_line
    array.each do |object|
      category_name = WAREHOUSE.execute("SELECT name FROM categories WHERE id = #{object.category_id}")[0]["name"]
      location_name = WAREHOUSE.execute("SELECT name FROM locations WHERE id = #{object.location_id}")[0]["name"]
      puts object.id.to_s.ljust(5) + category_name.ljust(15) + location_name
    end
  end
  
# Private print_locations
#
# Prints out a formatted list of all of the Location objects.
#
# Parameters:
# array - Array: an array containing all of the Location objects.  
  
  def print_locations(array)
    puts "id".ljust(5)+"name".ljust(15)+"capacity"
    h_line
    array.each do |object|
      puts object.id.to_s.ljust(5) + object.name.ljust(15) + object.capacity.to_s
    end
  end
  
# Private print_categories
#
# Prints out a formatted list of all of the Category objects.
#
# Parameters:
# array - Array: an array containing all of the Category objects.  
  
  def print_categories(array)
    puts "id".ljust(5)+"name".ljust(15)+"cost".ljust(6)+"description"
    h_line
    array.each do |object|
      puts object.id.to_s.ljust(5) + object.name.ljust(15) + object.cost.to_s.ljust(6) + object.description
    end
  end
  
end

Driver.new
