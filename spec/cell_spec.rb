# frozen_string_literal: true

require 'cell'

describe Cell do
  it 'has all 9 possible candidates if its value is zero' do
    cell = Cell.new(0, 3)

    expect(cell.candidates).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
  end

  it 'has no candidates if its value is not zero' do
    cell = Cell.new(5, 3)

    expect(cell.candidates).to eq([])
  end
end
