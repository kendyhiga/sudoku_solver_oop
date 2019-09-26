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

  it 'visual elimination of the already taken candidates' do
    output = SudokuSolver.new('medium')

    output.visual_elimination

    expect(output.grid.rows[0].candidates).to eq(
      [[],
       [1, 4, 8, 9],
       [1, 6, 9],
       [1, 3, 4, 8],
       [4, 8],
       [1, 3, 4, 8, 9],
       [1, 2, 6],
       [],
       [1, 2]]
    )
    expect(output.grid.columns[0].candidates).to eq(
      [[],
       [5, 9],
       [],
       [5, 6, 9],
       [],
       [],
       [4, 5, 9],
       [4, 5],
       []]
    )
    expect(output.grid.subgrids[0].candidates).to eq(
      [[],
       [1, 4, 8, 9],
       [1, 6, 9],
       [5, 9],
       [1, 5, 8, 9],
       [],
       [],
       [1, 4, 5],
       [1, 5, 6]]
    )
  end
end
