# frozen_string_literal: true

require_relative 'cell'

# Each Row have 9 cells
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

  def values
    values_array = []
    (0...9).each do |i|
      values_array << cells[i].value
    end
    values_array
  end

  def candidates
    candidates_array = []
    (0...9).each do |i|
      candidates_array << cells[i].candidates
    end
    candidates_array
  end
end
