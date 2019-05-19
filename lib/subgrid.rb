# frozen_string_literal: true

require_relative 'cell'

# Each Subgrid have 9 cells
class Subgrid
  attr_reader :cells
  def initialize(cells, subgrid_index_number)
    @cells = cells
    cells.each_index do |index|
      cells[index].position[:subgrid] = subgrid_index_number
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
