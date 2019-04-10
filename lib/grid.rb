require 'pry'
require 'csv'

#arr_medium = CSV.read("medium.csv", converters: :numeric)
#
# PUZZLES = {
#   medium: arr_medium,
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
  ],
  done: [
    [3, 6, 7, 4, 2, 9, 1, 5, 8],
    [8, 2, 4, 5, 6, 1, 7, 9, 3],
    [5, 9, 1, 8, 3, 7, 4, 2, 6],
    [7, 3, 9, 6, 5, 8, 2, 1, 4],
    [6, 4, 8, 1, 7, 2, 9, 3, 5],
    [1, 5, 2, 3, 9, 4, 8, 6, 7],
    [4, 1, 6, 9, 8, 3, 5, 7, 2],
    [2, 8, 3, 7, 1, 5, 6, 4, 9],
    [9, 7, 5, 2, 4, 6, 3, 8, 1]
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
  attr_reader :rows, :value
  attr_writer :value
  def initialize(value)
    @value = value
  end
end

grid = Grid.new(PUZZLES[:medium])

#binding.pry
