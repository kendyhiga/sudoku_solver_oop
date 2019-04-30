require_relative 'cell'

class Subgrid
  attr_reader :cells
  def initialize(cells, subgrid_index_number)
    @cells = cells
    cells.each_index do |index|
      cells[index].position[:subgrid] = subgrid_index_number
    end
  end
end
