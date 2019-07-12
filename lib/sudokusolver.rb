# frozen_string_literal: true

require 'csv'
require 'pry'
require_relative 'grid'

# This is the main class, still a lot of wip
class SudokuSolver
  attr_reader :grid
  def initialize(difficulty)
    read_from_csv(difficulty)
    @grid = Grid.new(@puzzles[:game])
    @last_remaining_zeros = []
    solve
  end

  def read_from_csv(difficulty)
    # print 'easy, medium, hard or expert: '
    # @difficulty = gets.chomp
    @difficulty = difficulty
    parsed_csv = CSV.read("lib/csvs/#{@difficulty}.csv", converters: :numeric)
    @puzzles = { game: parsed_csv }
  end

  def solve
    puts "\nNow solving #{@difficulty}"
    until remaining_zeros.zero? || !progressing?
      puts "There are still #{remaining_zeros} zeros remaining"
      visual_elimination

      run_strategies
      # run_advanced_strategies

    end
    puts "There are #{remaining_zeros} zero(s) remaining"
    # write_to_csv if remaining_zeros.zero?
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


    #pointing_pair_triple
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
      array = grid.send(group.to_sym)[each_group].values
      array_zeroes = array.each_index.select { |index| array[index].zero? }
      array_zeroes.each do |zero|
        if missing_numbers(array).size == 1 &&
          a_valid_option?(missing_numbers(array)[0], grid.send(group)[each_group].cells[zero])

          grid.send(group)[each_group].cells[zero].value = missing_numbers(array)[0]
          grid.send(group)[each_group].cells[zero].candidates = []
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
    (0...9).each do |group_index|
      (0...9).each do |cell_index|
        cell = @grid.rows[group_index].cells[cell_index]
        next if cell.candidates == []
        cell.candidates = cell.candidates - grid.rows[cell.row].values
        cell.candidates = cell.candidates - grid.columns[cell.column].values
        cell.candidates = cell.candidates - grid.subgrids[cell.subgrid].values
        lone_single(cell)
      end
    end
  end

  def hidden_single(group)
    (0...9).each do |group_index|
      array = []
      array << grid.send(group.to_sym)[group_index].candidates
      array.flatten!
      certain_candidate = array.detect{ |unique| array.count(unique) == 1 }
      if !certain_candidate.nil?
        (0...9).each do |cell|
          if grid.send(group)[group_index].cells[cell].candidates.find { |each| each == certain_candidate} &&
            grid.send(group)[group_index].cells[cell].candidates.size != 9 &&
            a_valid_option?(certain_candidate, grid.send(group)[group_index].cells[cell])

            grid.send(group)[group_index].cells[cell].value = certain_candidate
            grid.send(group)[group_index].cells[cell].candidates = []
          end
        end
      end
    end
  end

  def naked_pairs(group)
    (0...9).each do |group_index|
      group_candidates = grid.send(group)[group_index].candidates
      to_remove = group_candidates.detect{ |repeated| group_candidates.count(repeated) == repeated.size }
      if !to_remove.nil?
        (0...9).each do |cell_index|
          to_remove.each do |each_item_to_remove|
            if to_remove != grid.send(group)[group_index].cells[cell_index].candidates
              next if grid.send(group)[group_index].cells[cell_index].candidates == []
              grid.send(group)[group_index].cells[cell_index].candidates.delete(each_item_to_remove)
            end
          end
        end
      end
    end
  end

  def pointing_pair_triple
    (0...9).each do |subgrid|
      subgrid_candidates = []
      (0...9).each do |cell|
        subgrid_candidates << grid.subgrids[subgrid].cells[cell].candidates
      end

      (1..9).each do |value|
        if subgrid_candidates.flatten.count(value).between?(2,3)
          pointing_indexes_rows = []
          pointing_indexes_columns = []
          (0...9).each do |index|
            if grid.subgrids[subgrid].cells[index].candidates.include?(value)
              pointing_indexes_rows << grid.subgrids[subgrid].cells[index].row
              pointing_indexes_columns << grid.subgrids[subgrid].cells[index].column
            end
          end
          if pointing_indexes_rows.uniq.size == 1
            (0...9).each do |index|
              next if pointing_indexes_columns.include?(index)
              grid.rows[pointing_indexes_rows.first].cells[index].candidates.delete(value)
            end
          end
          if pointing_indexes_columns.uniq.size == 1
            (0...9).each do |index|
              next if pointing_indexes_rows.include?(index)
              grid.columns[pointing_indexes_columns.first].cells[index].candidates.delete(value)
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
        group_candidates << grid.send(group)[group_index].cells[cell_index].candidates
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
              grid.send(group)[group_index].cells[cell_index].candidates.delete(each_item_to_remove)
            end
          end
        end
      end
    end
  end

  def xwing_strategy_rows
    (0...9).each do |each_row|
      candidates = []

      (0...9).each do |each_cell|
        candidates << grid.rows[each_row].cells[each_cell].candidates
      end

      candidates.flatten.uniq.each do |value|
        if candidates.flatten.count(value) == 2
          xwing_possibility = value
          xwing_indexes = []

          candidates.each_with_index do |value, index|
            if value.include?(xwing_possibility)
              xwing_indexes << index
            end
          end

          ((each_row + 1)...9).each do |each_compare|
            candidates_compare = []

            (0...9).each do |each_cell|
              candidates_compare << grid.rows[each_compare].cells[each_cell].candidates
            end

            if candidates_compare.flatten.count(xwing_possibility) == 2
              xwing_indexes_compare = []

              candidates_compare.each_with_index do |value, index|
                if value.include?(xwing_possibility)
                  xwing_indexes_compare << index
                end
              end

              if xwing_indexes == xwing_indexes_compare
                (0...9).each do |cell|
                  next if cell == each_row || cell == each_compare
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
    return false if grid.rows[cell.row].values.include?(certain_candidate)
    return false if grid.columns[cell.column].values.include?(certain_candidate)
    return false if grid.subgrids[cell.subgrid].values.include?(certain_candidate)
    true
  end

  def progressing?
    if @last_remaining_zeros.last == remaining_zeros &&
        @last_remaining_zeros[@last_remaining_zeros.size-2] == remaining_zeros &&
        remaining_zeros != 0
      puts 'Unable to solve YET'
      return false
    end
    @last_remaining_zeros << remaining_zeros
    true
  end

  def missing_numbers(known_numbers_array)
    [1, 2, 3, 4, 5, 6, 7, 8, 9] - known_numbers_array
  end

  def remaining_zeros
    zero = 0
    (0...9).each do |each_row|
      zero += grid.rows[each_row].values.count(0)
    end
    zero
  end

  def done?
    (0...9).each do |each_row|
      array = grid.rows[each.row].values
      return false if (array.uniq.size != array.size) && (array.sum != 45)
    end
    (0...9).each do |each_column|
      array = grid.columns[each_column].values
      return false if array.uniq.size != array.size && (array.sum != 45)
    end
    (0...9).each do |each_subgrid|
      array = grid.subgrids[each_subgrid].values
      return false if array.uniq.size != array.size && (array.sum != 45)
    end
    true
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

# solved = SudokuSolver.new('hard')
# binding.pry
