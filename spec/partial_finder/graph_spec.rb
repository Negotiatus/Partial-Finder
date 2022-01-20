RSpec.describe PartialFinder::Graph do
  ::Link = PartialFinder::Link

  describe 'initialization' do
    it 'is valid with a link set' do
      links = PartialFinder::LinkSet.new('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
      expect{ described_class.new(links) }.to_not raise_exception
    end

    it 'is valid with a link set' do
      expect{ described_class.new('foo') }.to raise_exception PartialFinder::NonLinkArgument
    end
  end

  describe 'building the graph' do
    context 'with no files' do
      it 'has an empty graph' do
        links = PartialFinder::LinkSet.new('app/views/orders/_dne.html.erb', 'spec/dummy_app/')
        expect(described_class.new(links).structure).to eq([])
      end
    end

    context 'with a file that exists but is not rendered' do
      it 'has a built graph' do
        links = PartialFinder::LinkSet.new('app/views/orders/_foo.html.erb', 'spec/dummy_app/')
        expect(described_class.new(links).structure).to eq []
      end
    end

    context 'full render chains' do
      it 'has a built graph' do
        links = PartialFinder::LinkSet.new('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
        expect(described_class.new(links).structure).to eq(
          [
            Link.new("app/views/orders/_sidebar.html.erb", [
              Link.new("app/views/orders/_popup.html.erb", "app/controllers/orders_controller.rb"),
              Link.new("app/views/orders/_popup.html.erb", [
                Link.new("app/views/orders/_main.html.erb", "app/controllers/orders_controller.rb"),
                Link.new("app/views/orders/_main.html.erb", "app/views/orders/show.html.erb"),
              ]),
            ]),
            Link.new("app/views/orders/_sidebar.html.erb", "app/views/orders/new.html.erb")
          ]
        )
      end
    end
  end
end
