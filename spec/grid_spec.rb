require 'spec_helper'
require 'grid'

describe Grid do
  grid = Grid.new(PUZZLES[:medium])

  it 'has 9 rows' do
    expect(grid.rows.size).to eq(9)
  end

  it 'has 9 columns' do
    expect(grid.columns.size).to eq(9)
  end

  it 'has 9 subgrids' do
    expect(grid.subgrids.size).to eq(9)
  end

  it 'does not have a line with a repeated number' do
    grid = Grid.new(PUZZLES[:done])
#   grid = Grid.new(PUZZLES[:medium])
    (0...9).each do |each_row|
      arr = []
      (0...9).each do |each_cell|
        arr << grid.rows[each_row].cells[each_cell].value
      end
      expect(arr.uniq.size).to eq(arr.size)
    end
  end
end
