module Insert_Save
    
# Public: insert
# Takes an object and inserts it into the SQL table.
#
# Parameters:
# table_name - String: the name of the table being operated on.
#
# State Changes:
# sets the objects @id to the last insert row of the SQL table.    
    
  def insert(table_name)
    attr_array = instance_loop(self.instance_variables)
    values_array = values_loop(self.instance_variables)
    sql_string = "INSERT INTO #{table_name} (#{attr_array.join(", ").delete("@")}) VALUES (#{values_array.join(", ")})"
    
    WAREHOUSE.execute(sql_string)
    @id = WAREHOUSE.last_insert_row_id
  end
  
# Public: save
#
# Takes any changes made to a particular object and saves them to the SQL table
#
# Parameters:
# table_name - String: The table being operated on.
  
  
  def save(table_name)
    attr_array = instance_loop(self.instance_variables)
    values_array = values_loop(self.instance_variables)
    set_array = []
    c = 0
    attr_array.each do |x|
      set_array << (x.delete("@") + " = " + values_array[c].to_s)
      c += 1
    end
    sql_string = "UPDATE #{table_name} SET #{set_array.join(", ")} WHERE id = #{self.id}"
    
    WAREHOUSE.execute(sql_string)
  end
  
# Public: cram
#
# A method that decides whether to save, insert, or delete based on an objects
# @id.
  
  
  def cram
    table_name = class_to_table
    if @id != nil and @id.is_a?(Integer)
      self.save(table_name)
    elsif @id.is_a?(String)
      self.delete
    else
      self.insert(table_name) if @id == nil
    end
    
  end
  
# Public: delete
#
# Deletes an item from the appropriate table.  
  
  def delete
    table_name = class_to_table
    sql_id = @id.delete("X")
    sql_string = "DELETE FROM #{table_name} WHERE id = #{sql_id}"
    
    WAREHOUSE.execute(sql_string)
  end
  
# Public mark_x
# Converts an objects @id attribute to a string so cram knows to delete it and
# marks the @id with xxx so the user knows it will be deleted.
#
# State Changes:
# Marks @id with xxx.  
  
  def mark_x
    @id = @id.to_s + "XXX"
  end
  
private  

# Private: class_to_table
#
# Determines the name of the table to be operated on based on the class name.
#
# Returns:
# The table name as a string. 

  def class_to_table
    class_names = {"Product" => "products", "Category" => "categories", "Location" => "locations"}
    table_name = class_names[self.class.name]
    table_name
  end
  
# Private: instance_loop
#
# Converts an objects instance variables to strings.
#
# Parameters:
# array - Array: an array of instance variables.
#
# Returns:
# a, an array of the instance variables converted to strings.   
  
  def instance_loop(array)
    a = []
    array.each do |x|
      a << x.to_s if x != :@id
    end
    a
  end
  
# Private: values_loop
# Gets the value of a specific object's instance variables.
#
# Parameters:
# array - Array: an array of instance variables.
#
# Returns:
# a, an array of the values of the instance variables. 
  
  def values_loop(array)
    a = []
    array.each do |x|
      x = x.to_s.delete("@")
      value = self.send(x) 
      value.is_a?(String) ? value = "'" + value + "'" : value
      a << value if x != "id"
    end
    a
  end
  
end