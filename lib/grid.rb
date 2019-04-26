require 'csv'
require 'pry'

class SudokuSolver
  attr_reader :grid
  def initialize
    read_from_csv
    @grid = Grid.new(@puzzles[:game])
    @last_remaining_zeros = nil
    solve
  end

  def read_from_csv
    print 'easy, medium, hard or expert: '
    @difficulty = gets.chomp
    parsed_csv = CSV.read("lib/#{@difficulty}.csv", converters: :numeric)
    @puzzles = {game: parsed_csv}
  end

  def solve
    while not done?
      puts "There are still #{remaining_zeros} zero(s) remaining"
      check_candidates

      insert_number_if_theres_only_one_option('rows')
      insert_number_if_theres_only_one_option('columns')
      insert_number_if_theres_only_one_option('subgrids')

      insert_candidate_if_its_the_only_occurrence('rows')
      insert_candidate_if_its_the_only_occurrence('columns')
      insert_candidate_if_its_the_only_occurrence('subgrids')

      remove_known_candidates_from_group('rows')
      remove_known_candidates_from_group('columns')
      remove_known_candidates_from_group('subgrids')

      break unless is_progressing?
      check_candidates
    end
    puts "There are #{remaining_zeros} zero(s) remaining"
    write_to_csv if remaining_zeros == 0
  end

  def check_candidates
    (0...9).each do |row_index|
      (0...9).each do |cell_index|
        cell = @grid.rows[row_index].cells[cell_index]
        cell.candidates = cell.candidates - convert_rows_to_array(cell.row)
        cell.candidates = cell.candidates - convert_columns_to_array(cell.column)
        cell.candidates = cell.candidates - convert_subgrids_to_array(cell.subgrid)
        insert_number_if_theres_only_one_candidate(cell)
      end
    end
  end

  def remove_known_candidates_from_group(group)
    (0...9).each do |group_index|
      array = []
      (0...9).each do |cell_index|
        eval("array << grid.#{group}[group_index].cells[cell_index].candidates")
      end
      to_remove = array.detect{ |repeated| array.count(repeated) == repeated.size }
      if to_remove != nil
        (0...9).each do |cell_index|
          to_remove.each do |each_item_to_remove|
            eval("if to_remove != grid.#{group}[group_index].cells[cell_index].candidates
              grid.#{group}[group_index].cells[cell_index].candidates.delete(each_item_to_remove)
            end")
          end
        end
      end
    end
  end

  def insert_number_if_theres_only_one_candidate(cell)
    if cell.candidates.size == 1 && cell.candidates[0] != 0
      cell.value = cell.candidates[0]
      cell.candidates = []
    end
  end

  def insert_candidate_if_its_the_only_occurrence(group)
    (0...9).each do |group_index|
      array = []
      (0...9).each do |cell_index|
        eval("array << grid.#{group}[group_index].cells[cell_index].candidates")
      end
      array.flatten!
      certain_candidate = array.detect{ |unique| array.count(unique) == 1 }
      if certain_candidate != nil
        (0...9).each do |cell|
          if eval("grid.#{group}[group_index].cells[cell].candidates.find { |each| each == certain_candidate}") &&
            eval("grid.#{group}[group_index].cells[cell].candidates.size != 9") &&
            is_a_valid_option?(certain_candidate, eval("grid.#{group}[group_index].cells[cell]"))

            eval("grid.#{group}[group_index].cells[cell].value = certain_candidate")
            eval("grid.#{group}[group_index].cells[cell].candidates = []")
          end
        end
      end
    end
  end

  def insert_number_if_theres_only_one_option(group)
    (0...9).each do |each_group|
      array = eval("convert_#{group}_to_array(each_group)")
      array_zeroes = find_all_zeroes(array)
      array_zeroes.each do |zero|
        if missing_numbers(array).size == 1
          eval("grid.#{group}[each_group].cells[zero].value = missing_numbers(array)[0]")
          eval("grid.#{group}[each_group].cells[zero].candidates = []")
        end
      end
    end
  end

  def is_a_valid_option?(certain_candidate, cell)
    arr = []
    (0...9).each do |each_cell|
      arr << grid.rows[cell.row].cells[each_cell].value
    end
    arr.delete_if { |x| x == 0 }
    return false if arr.include?(certain_candidate)

    arr = []
    (0...9).each do |each_cell|
      arr << grid.columns[cell.column].cells[each_cell].value
    end
    arr.delete_if { |x| x == 0 }
    return false if arr.include?(certain_candidate)

    arr = []
    (0...9).each do |each_cell|
      arr << grid.subgrids[cell.subgrid].cells[each_cell].value
    end
    arr.delete_if { |x| x == 0 }
    return false if arr.include?(certain_candidate)

    true
  end

  def is_progressing?
    if @last_remaining_zeros == remaining_zeros && remaining_zeros != 0
      puts 'Unable to solve YET'
      return false
    end
    @last_remaining_zeros = remaining_zeros
    true
  end

  def convert_rows_to_array(index)
    row_values_in_array = []
    grid.rows[index].cells.each do |cell|
      row_values_in_array << cell.value
    end
    row_values_in_array
  end

  def convert_columns_to_array(index)
    columns_values_in_array = []
    grid.columns[index].cells.each do |cell|
      columns_values_in_array << cell.value
    end
    columns_values_in_array
  end

  def convert_subgrids_to_array(index)
    subgrid_values_in_array = []
    grid.subgrids[index].cells.each do |cell|
      subgrid_values_in_array << cell.value
    end
    subgrid_values_in_array
  end

  def find_all_zeroes(array)
    array.each_index.select { |index| array[index] == 0 }
  end

  def missing_numbers(known_numbers_array)
    [1,2,3,4,5,6,7,8,9] - known_numbers_array
  end

  def remaining_zeros
    zero = 0
    (0...9).each do |each_row|
      (0...9).each do |each_cell|
        zero += 1 if @grid.rows[each_row].cells[each_cell].value == 0
      end
    end
    zero
  end

  def done?
    (0...9).each do |each_row|
      array = convert_rows_to_array(each_row)
      return false if (array.uniq.size != array.size) && (array.sum != 45)
    end
    (0...9).each do |each_column|
      array = convert_columns_to_array(each_column)
      return false if array.uniq.size != array.size && (array.sum != 45)
    end
    (0...9).each do |each_subgrid|
      array = convert_subgrids_to_array(each_subgrid)
      return false if array.uniq.size != array.size && (array.sum != 45)
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
    row_index_number = 0
    @grid.each do |row|
      @rows << Row.new(row, row_index_number)
      row_index_number += 1
    end
  end

  def parse_columns
    column_index_number = 0
    (0...9).each do |index|
      temp_column = []
      @rows.each do |row|
        temp_column << row.cells[index]
      end
      @columns << Column.new(temp_column, column_index_number)
      column_index_number += 1
    end
  end

  def parse_subgrid
    subgrid_index_number = 0
    (0..8).step(3) do |horizontal_start, horizontal_end = (horizontal_start + 2)|
      (0..8).step(3) do |vertical_start, vertical_end = (vertical_start + 2)|
        temp_subgrid = []
        @rows[horizontal_start..horizontal_end].each do |row|
          temp_subgrid << row.cells[vertical_start..vertical_end]
        end
        @subgrids << Subgrid.new(temp_subgrid.flatten, subgrid_index_number)
        subgrid_index_number += 1
      end
    end
  end

end

class Row
  attr_reader :cells
  def initialize(values, row_index_number)
    @cells = []
    parse_cells(values, row_index_number)
  end

  def parse_cells(values, row_index_number)
    values.each do |value|
      @cells << Cell.new(value, row_index_number)
    end
  end
end

class Column
  attr_reader :cells
  def initialize(cells, column_index_number)
    @cells = cells
    @cells.each_index do |index|
      @cells[index].position[:column] = column_index_number
    end
  end
end

class Subgrid
  attr_reader :cells
  def initialize(cells, subgrid_index_number)
    @cells = cells
    cells.each_index do |index|
      cells[index].position[:subgrid] = subgrid_index_number
    end
  end
end

class Cell
  attr_accessor :value, :position, :candidates
  def initialize(value, row_index_number)
    @value = value
    @position = {row: row_index_number}
    @candidates = @value == 0 ? [1,2,3,4,5,6,7,8,9] : []
  end

  def row
    @position[:row]
  end

  def column
    @position[:column]
  end

  def subgrid
    @position[:subgrid]
  end
end

solved = SudokuSolver.new
