require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  
  def self.columns
    return @columns if @columns
    @columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL
    @columns = @columns.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    row_array = DBConnection.execute(<<-SQL)
      SELECT * FROM "#{self.table_name}"
    SQL
    self.parse_all(row_array)
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
      SELECT * FROM "#{self.table_name}"
      WHERE id = ?
    SQL
    return nil if object.empty?
    self.new(object.first)
  end

  def initialize(params = {})
    params.each do |column_name, value|
      column_names = self.class.columns
      raise "unknown attribute '#{column_name}'" unless column_names.include?(column_name.to_sym)
      setter_name = "#{column_name}=".to_sym
      self.send(setter_name, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.map { |column_name, value| value }
  end

  def insert
    col_names = self.class.columns.join(', ')
    question_marks = ['?'] * col_names.length
    DBConnection.execute(<<-SQL)
      
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
