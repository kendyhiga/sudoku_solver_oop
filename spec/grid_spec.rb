require 'grid'

RSpec.describe Grid do
  describe '#parse_rows'
    it 'has 9 rows' do
      expect(grid.rows.size).to eq(9)
    end
end
