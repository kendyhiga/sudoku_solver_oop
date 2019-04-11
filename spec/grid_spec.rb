require 'grid'

describe Grid do
  grid = Grid.new(PUZZLES[:done])
  # grid = Grid.new(PUZZLES[:medium])
  it 'has 9 rows' do
    expect(grid.rows.size).to eq(9)
  end

  it 'has 9 columns' do
    expect(grid.columns.size).to eq(9)
  end

  it 'has 9 subgrids' do
    expect(grid.subgrids.size).to eq(9)
  end

  it 'only have valid numbers' do
    (0...9).each do |each_row|
      (0...9).each do |each_cell|
        expect(grid.rows[each_row].cells[each_cell].value).to be_between(1, 9)
      end
    end
  end

  it "doesn't have a line with a repeated number" do
    (0...9).each do |each_row|
      arr = []
      (0...9).each do |each_cell|
        arr << grid.rows[each_row].cells[each_cell].value
      end
      expect(arr.uniq.size).to eq(arr.size)
    end
  end
end
