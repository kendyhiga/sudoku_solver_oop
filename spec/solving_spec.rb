# frozen_string_literal: true

require 'sudokusolver'

describe Grid do
  test_cases = %w[ easy
                   medium
                   hard2
                   hard3
                   np
                   easy_sudoku_grid
                   medium_sudoku_grid
                   hard_sudoku_grid
                   expert_sudoku_grid ]
  test_cases.each do |test|
    solved = SudokuSolver.new(test)
    it 'has 9 rows' do
      expect(solved.grid.rows.size).to eq(9)
    end

    it 'has 9 columns' do
      expect(solved.grid.columns.size).to eq(9)
    end

    it 'has 9 subgrids' do
      expect(solved.grid.subgrids.size).to eq(9)
    end

    it 'only have valid numbers' do
      (0...9).each do |each_row|
        (0...9).each do |each_cell|
          expect(solved.grid.rows[each_row].cells[each_cell].value).to be_between(1, 9)
        end
      end
    end

    it "doesn't have a row with a repeated number" do
      (0...9).each do |each_row|
        arr = []
        (0...9).each do |each_cell|
          arr << solved.grid.rows[each_row].cells[each_cell].value
        end
        expect(arr.uniq.size).to eq(arr.size)
      end
    end

    it "doesn't have a column with a repeated number" do
      (0...9).each do |each_column|
        arr = []
        (0...9).each do |each_cell|
          arr << solved.grid.columns[each_column].cells[each_cell].value
        end
        expect(arr.uniq.size).to eq(arr.size)
      end
    end

    it "doesn't have a subgrid with a repeated number" do
      (0...9).each do |each_subgrid|
        arr = []
        (0...9).each do |each_cell|
          arr << solved.grid.subgrids[each_subgrid].cells[each_cell].value
        end
        expect(arr.uniq.size).to eq(arr.size)
      end
    end
  end
end