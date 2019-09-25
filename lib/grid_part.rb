# frozen_string_literal: true

# Parent class for the column, row and subgrid classes
class GridPart
  def values
    (0...9).map { |i| cells[i].value }
  end

  def candidates
    (0...9).map { |i| cells[i].candidates }
  end
end
