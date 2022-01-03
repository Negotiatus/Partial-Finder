RSpec.describe PartialFinder::Formatter do
  describe '#controller_signature_from_view' do
    it 'can generate a controller name+method given a view' do
      expect(
        described_class.controller_signature_from_view('app/views/admin/orders/show.html.erb')
      ).to eq 'admin/orders#show'
    end
  end

  describe '#controller_signature' do
    it 'can generate a controller name+method given a controller+method' do
      expect(
        described_class.controller_signature(
          'app/controllers/admin/orders_controller.rb',
          'show'
        )
      ).to eq 'admin/orders#show'
    end
  end

  it "can search through a controller and determine which method renders a partial" do

  end
end
