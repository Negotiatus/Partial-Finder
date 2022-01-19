RSpec.describe PartialFinder::Link do
  it 'can be compared' do
    l1 = described_class.new('foo','bar')
    l2 = described_class.new('foo','bar')
    l3 = described_class.new('one','two')
    expect(l1).to eq l2
    expect(l1).to_not eq l3
    expect([l1,l2,l3].uniq).to match_array [l1,l3]
  end
end
