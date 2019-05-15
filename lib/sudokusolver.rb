# frozen_string_literal: true

require 'csv'
require 'pry'
require_relative 'grid'

# This is the main class, still a lot of wip
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
    parsed_csv = CSV.read("lib/csvs/#{@difficulty}.csv", converters: :numeric)
    @puzzles = { game: parsed_csv }
  end

  def solve
    until done?
      puts "There are still #{remaining_zeros} zero(s) remaining"
      visual_elimination

      run_strategies
      run_advanced_strategies

      break if remaining_zeros.zero?

      break unless progressing?

      visual_elimination
    end
    puts "There are #{remaining_zeros} zero(s) remaining"
    write_to_csv if remaining_zeros.zero?
  end

  def run_strategies
    open_single('columns')
    open_single('rows')
    open_single('subgrids')

    hidden_single('columns')
    hidden_single('rows')
    hidden_single('subgrids')

    naked_pairs('columns')
    naked_pairs('rows')
    naked_pairs('subgrids')
  end

  def run_advanced_strategies
    naked_triple_quadruple('columns')
    naked_triple_quadruple('rows')
    naked_triple_quadruple('subgrids')

    # xwing_strategy_rows
    # xwing_strategy_columns
  end

  def open_single(group)
    (0...9).each do |each_group|
      array = eval("convert_#{group}_to_array(each_group)")
      array_zeroes = find_all_zeroes(array)
      array_zeroes.each do |zero|
        if missing_numbers(array).size == 1 &&
          a_valid_option?(eval("missing_numbers(array)[0]"), eval("grid.#{group}[each_group].cells[zero]"))

          eval("grid.#{group}[each_group].cells[zero].value = missing_numbers(array)[0]")
          eval("grid.#{group}[each_group].cells[zero].candidates = []")
        end
      end
    end
  end

  def lone_single(cell)
    if cell.candidates.size == 1 && cell.candidates[0] != 0 && a_valid_option?(cell.candidates[0], cell)
      cell.value = cell.candidates[0]
      cell.candidates = []
    end
  end

  def visual_elimination
    (0...9).each do |row_index|
      (0...9).each do |cell_index|
        cell = @grid.rows[row_index].cells[cell_index]
        cell.candidates = cell.candidates - convert_rows_to_array(cell.row)
        cell.candidates = cell.candidates - convert_columns_to_array(cell.column)
        cell.candidates = cell.candidates - convert_subgrids_to_array(cell.subgrid)
        lone_single(cell)
      end
    end
  end

  def hidden_single(group)
    (0...9).each do |group_index|
      array = []
      (0...9).each do |cell_index|
        array << eval("grid.#{group}[group_index].cells[cell_index].candidates")
      end
      array.flatten!
      certain_candidate = array.detect{ |unique| array.count(unique) == 1 }
      if !certain_candidate.nil?
        (0...9).each do |cell|
          if eval("grid.#{group}[group_index].cells[cell].candidates.find { |each| each == certain_candidate}") &&
            eval("grid.#{group}[group_index].cells[cell].candidates.size != 9") &&
            a_valid_option?(certain_candidate, eval("grid.#{group}[group_index].cells[cell]"))

            eval("grid.#{group}[group_index].cells[cell].value = certain_candidate")
            eval("grid.#{group}[group_index].cells[cell].candidates = []")
          end
        end
      end
    end
  end

  def naked_pairs(group)
    (0...9).each do |group_index|
      group_candidates = []
      (0...9).each do |cell_index|
        group_candidates << eval("grid.#{group}[group_index].cells[cell_index].candidates")
      end
      to_remove = group_candidates.detect{ |repeated| group_candidates.count(repeated) == repeated.size }
      if !to_remove.nil?
        (0...9).each do |cell_index|
          to_remove.each do |each_item_to_remove|
            if to_remove != eval("grid.#{group}[group_index].cells[cell_index].candidates")
              eval("grid.#{group}[group_index].cells[cell_index].candidates.delete(each_item_to_remove)")
            end
          end
        end
      end
    end
  end

  def naked_triple_quadruple(group)
    (0...9).each do |group_index|
      group_candidates = []
      (0...9).each do |cell_index|
        group_candidates << eval("grid.#{group}[group_index].cells[cell_index].candidates")
      end

      group_candidates.each do |each_candidate|
        next if each_candidate == [] || each_candidate.size < 3

        each_candidate.sort!
        combinations = (2..each_candidate.size).map { |i| each_candidate.combination(i).to_a }.flatten(1)

        candidates_indexes = []
        group_candidates.each_with_index do |candidate, index|
          next if candidate == []
          candidates_indexes << index if combinations.include?(candidate)
        end

        if candidates_indexes.size == each_candidate.size
          each_candidate.flatten.uniq.each do |each_item_to_remove|
            (0...9).each do |cell_index|
              next if candidates_indexes.include?(cell_index)
              eval("grid.#{group}[group_index].cells[cell_index].candidates.delete(each_item_to_remove)")
            end
          end
        end
      end
    end
  end

  def xwing_strategy_rows
    (0...9).each do |each_row|
      row_candidates = []

      (0...9).each do |each_cell|
        row_candidates << grid.rows[each_row].cells[each_cell].candidates
      end

      row_candidates.flatten.each do |value|
        if row_candidates.flatten.count(value) == 2
          xwing_possibility = value
          xwing_indexes = []
          xwing_indexes_compare = []

          row_candidates.each_with_index do |value, index|
            if value.include?(xwing_possibility)
              xwing_indexes << index
            end
          end

          (0...9).each do |each|
            if grid.columns[xwing_indexes.first].cells[each].candidates.include?(xwing_possibility)
              next if each_row == each

              second_row_candidates = []

              (0...9).each do |each_cell|
                second_row_candidates << grid.rows[each].cells[each_cell].candidates
              end

              if second_row_candidates.flatten.count(xwing_possibility) == 2
                second_row_candidates.each_with_index do |value, index|
                  if value.include?(xwing_possibility)
                    xwing_indexes_compare << index
                  end
                end
              end

              if xwing_indexes == xwing_indexes_compare
                (0...9).each do |cell|
                  next if cell == each_row || cell == each

                  grid.columns[xwing_indexes.first].cells[cell].candidates.delete(xwing_possibility)
                  grid.columns[xwing_indexes.last].cells[cell].candidates.delete(xwing_possibility)
                end
              end
            end
          end
        end
      end
    end
  end

  def xwing_strategy_columns
    (0...9).each do |each_column|
      column_candidates = []

      (0...9).each do |each_cell|
        column_candidates << grid.columns[each_column].cells[each_cell].candidates
      end

      column_candidates.flatten.each do |value|
        if column_candidates.flatten.count(value) == 2
          xwing_possibility = value
          xwing_indexes = []
          xwing_indexes_compare = []

          column_candidates.each_with_index do |value, index|
            if value.include?(xwing_possibility)
              xwing_indexes << index
            end
          end

          (0...9).each do |each|
            if grid.rows[xwing_indexes.first].cells[each].candidates.include?(xwing_possibility)
              next if each_column == each

              second_column_candidates = []

              (0...9).each do |each_cell|
                second_column_candidates << grid.columns[each].cells[each_cell].candidates
              end

              if second_column_candidates.flatten.count(xwing_possibility) == 2
                second_column_candidates.each_with_index do |value, index|
                  if value.include?(xwing_possibility)
                    xwing_indexes_compare << index
                  end
                end
              end

              if xwing_indexes == xwing_indexes_compare
                (0...9).each do |cell|
                  next if cell == each_column || cell == each

                  grid.rows[xwing_indexes.first].cells[cell].candidates.delete(xwing_possibility)
                  grid.rows[xwing_indexes.last].cells[cell].candidates.delete(xwing_possibility)
                end
              end
            end
          end
        end
      end
    end
  end

  def a_valid_option?(certain_candidate, cell)
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

  def progressing?
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
    array.each_index.select { |index| array[index].zero? }
  end

  def missing_numbers(known_numbers_array)
    [1, 2, 3, 4, 5, 6, 7, 8, 9] - known_numbers_array
  end

  def remaining_zeros
    zero = 0
    (0...9).each do |each_row|
      (0...9).each do |each_cell|
        zero += 1 if @grid.rows[each_row].cells[each_cell].value.zero?
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
    false
  end

  def write_to_csv
    CSV.open("lib/csvs/#{@difficulty}_done.csv", 'wb') do |csv|
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

solved = SudokuSolver.new
