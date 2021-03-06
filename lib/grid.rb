# frozen_string_literal: true

require_relative 'row'
require_relative 'column'
require_relative 'subgrid'

# The grid represents the complete sudoku game table
# it has 9 rows, 9 columns and 9 subgrids
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
    @grid.each_with_index do |row, index|
      @rows << Row.new(row, index)
    end
  end

  def parse_columns
    (0..8).each do |index|
      temp_column = @rows.map { |row| row.cells[index] }
      @columns << Column.new(temp_column, index)
    end
  end

  def parse_subgrid
    subgrid_index_number = 0
    (0..8).step(3) do |horizontal_start, horizontal_end = (horizontal_start + 2)|
      (0..8).step(3) do |vertical_start, vertical_end = (vertical_start + 2)|
        temp_subgrid = @rows[horizontal_start..horizontal_end].map do |row|
          row.cells[vertical_start..vertical_end]
        end
        @subgrids << Subgrid.new(temp_subgrid.flatten, subgrid_index_number)
        subgrid_index_number += 1
      end
    end
  end
end
