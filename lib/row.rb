require_relative 'cell'

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
