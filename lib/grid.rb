require 'csv'
require 'pry'

class SudokuSolver
  attr_reader :grid
  def initialize
    read_from_csv
    @grid = Grid.new(@puzzles[:game])
    solve
    write_to_csv
  end

  def read_from_csv
    print 'easy, medium or done: '
    @difficulty = gets.chomp
    parsed_csv = CSV.read("lib/#{@difficulty}.csv", converters: :numeric)
    @puzzles = {game: parsed_csv}
  end

  def solve
    while not done?
      (0...9).each do |each_row|
        array = convert_row_to_array(each_row)
        array_zeroes = find_all_zeroes(array)
        array_zeroes.each do |zero|
          self.grid.rows[each_row].cells[zero].value = missing_numbers(array)[0] if missing_numbers(array).size == 1
          # only_one_valid_option
        end
      end
      (0...9).each do |each_column|
        array = convert_column_to_array(each_column)
        array_zeroes = find_all_zeroes(array)
        array_zeroes.each do |zero|
          self.grid.lines[each_column].cells[zero].value = missing_numbers(array)[0] if missing_numbers(array).size == 1
        end
      end
      (0...9).each do |each_subgrid|
        array = convert_subgrid_to_array(each_subgrid)
        array_zeroes = find_all_zeroes(array)
        array_zeroes.each do |zero|
          self.grid.lines[each_subgrid].cells[zero].value = missing_numbers(array)[0] if missing_numbers(array).size == 1
        end
      end
    end
  end

  def convert_row_to_array(index)
    row_values_in_array = []
    self.grid.rows[index].cells.each do |cell|
      row_values_in_array << cell.value
    end
    row_values_in_array
  end

  def convert_column_to_array(index)
    columns_values_in_array = []
    self.grid.columns[index].cells.each do |cell|
      columns_values_in_array << cell.value
    end
    columns_values_in_array
  end

  def convert_subgrid_to_array(index)
    subgrid_values_in_array = []
    self.grid.subgrids[index].cells.each do |cell|
      subgrid_values_in_array << cell.value
    end
    subgrid_values_in_array
  end

  def find_all_zeroes(array)
    array.each_index.select { |index| array[index]==0 }
  end

  def missing_numbers(known_numbers_array)
    [1,2,3,4,5,6,7,8,9] - known_numbers_array
  end

  def done?
    (0...9).each do |each_row|
      array = convert_row_to_array(each_row)
      return false if (array.uniq.size != array.size) || (array.sum != 45)
    end
    (0...9).each do |each_column|
      array = convert_column_to_array(each_column)
      return false if array.uniq.size != array.size || (array.sum != 45)
    end
    (0...9).each do |each_subgrid|
      array = convert_subgrid_to_array(each_subgrid)
      return false if array.uniq.size != array.size || (array.sum != 45)
    end
    true
  end

  def write_to_csv
    CSV.open("lib/#{@difficulty}_done.csv", "wb") do |csv|
      (0...9).each do |each_row|
        arr = []
        (0...9).each do |each_cell|
          arr << @grid.rows[each_row].cells[each_cell].value
        end
        csv << arr
      end
    end
  end
end

class Grid
  attr_reader :cells, :rows, :columns, :subgrids

  def initialize(matrix)
    @grid = matrix
    @rows = []
    @columns = []
    @subgrids = []
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
        @subgrids << Subgrid.new(temp_subgrid.flatten)
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

solved = SudokuSolver.new

#binding.pry
