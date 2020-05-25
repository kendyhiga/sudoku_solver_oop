# frozen_string_literal: true

# Each cell represents one of the 81 fields on the sudoku
class Cell
  attr_accessor :value, :position, :candidates
  def initialize(value, row_index_number)
    @value = value
    @position = { row: row_index_number }
    @candidates = @value.zero? ? (1..9).to_a : []
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
