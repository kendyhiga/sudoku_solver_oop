# frozen_string_literal: true

require 'sudoku_solver'
require 'byebug'

describe SudokuSolver do
  it 'has access to its rows, columns and subgrids values' do
    output = SudokuSolver.new('medium')

    expect(output.grid.rows[0].values).to eq([7, 0, 0, 0, 0, 0, 0, 5, 0])
    expect(output.grid.columns[0].values).to eq([7,
                                                 0,
                                                 3,
                                                 0,
                                                 8,
                                                 2,
                                                 0,
                                                 0,
                                                 1])
    expect(output.grid.subgrids[0].values).to eq([7, 0, 0,
                                                  0, 0, 2,
                                                  3, 0, 0])
  end

  it 'has all possible candidates where the value is 0' do
    output = SudokuSolver.new('medium')

    expect(output.grid.rows[0].candidates).to eq(
      [[],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [],
       [1, 2, 3, 4, 5, 6, 7, 8, 9]]
    )
    expect(output.grid.columns[0].candidates).to eq(
      [[],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [],
       [],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       []]
    )
    expect(output.grid.subgrids[0].candidates).to eq(
      [[],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [],
       [],
       [1, 2, 3, 4, 5, 6, 7, 8, 9],
       [1, 2, 3, 4, 5, 6, 7, 8, 9]]
    )
  end
end
