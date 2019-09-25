# frozen_string_literal: true

require 'row'

describe Row do
  it 'has access to its values' do
    row = Row.new([5, 9, 4, 6, 1, 7, 8, 3, 2], 0)

    expect(row.values).to eq([5, 9, 4, 6, 1, 7, 8, 3, 2])
  end
end
