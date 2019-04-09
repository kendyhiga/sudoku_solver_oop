require 'pry'

PUZZLES = {
  medium: [
    [6, 0, 9, 0, 0, 8, 3, 0, 2],
    [0, 5, 0, 6, 2, 0, 7, 0, 0],
    [0, 0, 7, 9, 0, 0, 0, 0, 0],
    [5, 0, 0, 0, 1, 0, 2, 6, 0],
    [0, 6, 0, 0, 0, 5, 0, 0, 0],
    [7, 0, 0, 0, 0, 2, 0, 0, 0],
    [9, 7, 6, 0, 0, 0, 0, 0, 1],
    [4, 1, 5, 0, 0, 0, 6, 3, 7],
    [2, 0, 0, 0, 0, 0, 5, 9, 4]
  ]
}

class Grid
  attr_reader :cells, :rows, :columns, :subgrids

  def initialize(matrix)
    @grid = matrix
    @rows = []
    @columns = []
    @subgrids = []
    @cells = []
    parse_rows
    parse_columns
    parse_subgrid
  end

  def parse_rows
    @grid.each do |row|
      @rows << Row.new(row)
    end
  end

  def parse_columns
    (0...9).each do |index|
      temp_column = []
      @rows.each do |row|
        temp_column << row.cells[index]
      end
      @columns << Column.new(temp_column)
    end
  end

  def parse_subgrid
    start = 0
    limit = 2
    3.times do |index|
      temp_subgrid1 = []
      temp_subgrid2 = []
      temp_subgrid3 = []
      @rows[start..limit].each do |row|
        temp_subgrid1 << row.cells[0..2]
        temp_subgrid2 << row.cells[3..5]
        temp_subgrid3 << row.cells[6..8]
      end
      @subgrids << Subgrid.new(temp_subgrid1)
      @subgrids << Subgrid.new(temp_subgrid2)
      @subgrids << Subgrid.new(temp_subgrid3)
      start += 3
      limit += 3
    end
  end
end

class Row
  attr_reader :cells
  def initialize(values)
    @cells = []
    parse_cells(values)
  end

  def parse_cells(values)
    values.each do |value|
      @cells << Cell.new(value)
    end
  end
end

class Column
  attr_reader :cells
  def initialize(cells)
    @cells = cells
  end
end

class Subgrid
  attr_reader :cells
  def initialize(cells)
    @cells = cells
  end
end

class Cell
  attr_writer :value
  def initialize(value)
    @value = value
  end
end

grid = Grid.new(PUZZLES[:medium])
binding.pry
