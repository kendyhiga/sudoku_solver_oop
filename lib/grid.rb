require 'csv'
require 'pry'

def read_from_csv
  print 'medium or done: '
  @difficulty = gets.chomp
  parsed_csv = CSV.read("lib/#{@difficulty}.csv", converters: :numeric)
  @puzzles = {game: parsed_csv}
end

def write_to_csv(grid)
  CSV.open("lib/#{@difficulty}_done.csv", "wb") do |csv|
    (0...9).each do |each_row|
      arr = []
      (0...9).each do |each_cell|
        arr << grid.rows[each_row].cells[each_cell].value
      end
      csv << arr
    end
  end
end

def sudoku_solver(grid)
  #coming soon
  grid
end

def missing_numbers(known_numbers_array)
  [1,2,3,4,5,6,7,8,9] - known_numbers_array
end

class Grid
  attr_reader :cells, :rows, :columns, :subgrids

  def initialize(matrix)
    @grid = matrix
    @rows = []
    @columns = []
    @subgrids = []
    @cells = []
    parse_rows
    parse_columns
    parse_subgrid
  end

  def parse_rows
    @grid.each do |row|
      @rows << Row.new(row)
    end
  end

  def parse_columns
    (0...9).each do |index|
      temp_column = []
      @rows.each do |row|
        temp_column << row.cells[index]
      end
      @columns << Column.new(temp_column)
    end
  end

  def parse_subgrid
    (0..8).step(3) do |horizontal_start, horizontal_end = (horizontal_start + 2)|
      (0..8).step(3) do |vertical_start, vertical_end = (vertical_start + 2)|
        temp_subgrid = []
        @rows[horizontal_start..horizontal_end].each do |row|
          temp_subgrid << row.cells[vertical_start..vertical_end]
        end
        @subgrids << Subgrid.new(temp_subgrid)
      end
    end
  end

end

class Row
  attr_reader :cells
  def initialize(values)
    @cells = []
    parse_cells(values)
  end

  def parse_cells(values)
    values.each do |value|
      @cells << Cell.new(value)
    end
  end
end

class Column
  attr_reader :cells
  def initialize(cells)
    @cells = cells
  end
end

class Subgrid
  attr_reader :cells
  def initialize(cells)
    @cells = cells
  end
end

class Cell
  attr_reader :rows, :value
  attr_writer :value
  def initialize(value)
    @value = value
  end
end

read_from_csv
grid = Grid.new(@puzzles[:game])

solved = sudoku_solver(grid)
write_to_csv(solved)
