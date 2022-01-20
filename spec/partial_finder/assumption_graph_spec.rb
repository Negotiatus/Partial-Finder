RSpec.describe PartialFinder::AssumptionGraph do
  ::Link = PartialFinder::Link

  describe 'initialization' do
    context 'with a graph' do
      it 'is valid' do
        gr = PartialFinder::Graph.from('app/views/orders/_foo.html.erb', 'spec/dummy_app/')
        expect{ described_class.new(gr) }.to_not raise_exception
      end
    end

    context 'with something else' do
      it 'is invalid' do
        expect{ described_class.new('not a graph') }.to raise_exception PartialFinder::NonGraphArgument
      end
    end
  end

  describe 'building the structure' do
    context 'with no files' do
      it 'has an empty graph' do
        gr = PartialFinder::Graph.from('app/views/orders/_dne.html.erb', 'spec/dummy_app/')
        expect(described_class.new(gr).structure).to eq []
      end
    end

    context 'with a file that exists but is not rendered' do
      it 'has a built graph' do
        gr = PartialFinder::Graph.from('app/views/orders/_foo.html.erb', 'spec/dummy_app/')
        expect(described_class.new(gr).structure).to eq []
      end
    end

    context 'full render chains' do
      it 'has a built graph' do
        gr = PartialFinder::Graph.from('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
        allow(PartialFinder::Router).to receive(:routes).and_return <<-ROUT
orders GET      /orders/:id(.:format)      orders#show
orders GET      /orders(.:format)          orders#new
orders PATCH    /update_my_order(.:format) orders#update
orders GET      /orders/:id/edit(.:format) orders#edit
ROUT

        expect(described_class.new(gr).structure).to eq(
          [
            Link.new("app/views/orders/_sidebar.html.erb", [
              Link.new("app/views/orders/_popup.html.erb", [
                Link.new("app/controllers/orders_controller.rb", [
                  Link.new("Rendered by orders#update".colorize(:green), "Routes to /update_my_order".colorize(:green))
                ])
              ]),
              Link.new("app/views/orders/_popup.html.erb", [
                Link.new("app/views/orders/_main.html.erb", [
                  Link.new("app/controllers/orders_controller.rb", [
                    Link.new("Rendered by orders#edit".colorize(:green), "Routes to /orders/:id/edit".colorize(:green))
                  ])
                ]),
                Link.new("app/views/orders/_main.html.erb", [
                  Link.new("app/views/orders/show.html.erb", [
                    Link.new("Rendered by orders#show".colorize(:green), "Routes to /orders/:id".colorize(:green))
                  ])
                ])
              ]),
            ]),
            Link.new("app/views/orders/_sidebar.html.erb", [
              Link.new("app/views/orders/new.html.erb", [
                Link.new("Rendered by orders#new".colorize(:green), "Routes to /orders".colorize(:green))
              ])
            ])
          ]
        )
      end
    end

    it 'can determine when routing lookup fails' do
      expect(true).to be false
    end

    it 'can determine when controller method lookup fails' do
      expect(true).to be false
    end

    it 'can determine when a particular render chain is unused' do
      expect(true).to be false
    end

    it 'can determine if an unknown file type is part of the render chain' do
      expect(true).to be false
    end
  end
end
