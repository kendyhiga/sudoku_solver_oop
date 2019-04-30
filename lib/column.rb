require_relative 'cell'

class Column
  attr_reader :cells
  def initialize(cells, column_index_number)
    @cells = cells
    @cells.each_index do |index|
      @cells[index].position[:column] = column_index_number
    end
  end
end
