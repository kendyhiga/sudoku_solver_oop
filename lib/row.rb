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
    (0...9).map { |i| cells[i].value }
  end

  def candidates
    (0...9).map { |i| cells[i].candidates }
  end
end
