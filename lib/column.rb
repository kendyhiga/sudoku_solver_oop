# frozen_string_literal: true

require_relative 'cell'

# Each Column have 9 cells
class Column
  attr_reader :cells
  def initialize(cells, column_index_number)
    @cells = cells
    @cells.each_index do |index|
      @cells[index].position[:column] = column_index_number
    end
  end

  def values
    (0...9).map { |i| cells[i].value }
  end

  def candidates
    (0...9).map { |i| cells[i].candidates }
  end
end
