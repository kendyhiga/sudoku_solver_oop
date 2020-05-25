# frozen_string_literal: true

require_relative 'cell'
require_relative 'grid_part'

# Each Row have 9 cells
class Row < GridPart
  attr_reader :cells

  def initialize(values, row_index_number)
    @cells = values.map do |value|
      Cell.new(value, row_index_number)
    end
  end
end
