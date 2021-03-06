RSpec.describe PartialFinder::AssumptionGraph do
  ::Link = PartialFinder::Link

  describe 'initialization' do
    context 'with a graph' do
      it 'is valid' do
        links = PartialFinder::LinkSet.new('app/views/orders/_foo.html.erb', 'spec/dummy_app/')
        expect{ described_class.new(links) }.to_not raise_exception
      end
    end

    context 'with something else' do
      it 'is invalid' do
        expect{
          described_class.new('not a graph')
        }.to raise_exception PartialFinder::NonLinkArgument
      end
    end
  end

  describe 'building the structure' do
    context 'with no files' do
      it 'has an empty graph' do
        links = PartialFinder::LinkSet.new('app/views/orders/_dne.html.erb', 'spec/dummy_app/')
        expect(described_class.new(links).structure).to eq []
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
        links = PartialFinder::LinkSet.new(
          'app/views/orders/_sidebar.html.erb',
          'spec/dummy_app/'
        )

        allow(PartialFinder::Router).to receive(:routes).and_return <<-ROUT
orders GET      /orders/:id(.:format)      orders#show
orders GET      /orders(.:format)          orders#new
orders PATCH    /update_my_order(.:format) orders#update
orders GET      /orders/:id/edit(.:format) orders#edit
ROUT

        expect(described_class.new(links, 'spec/dummy_app/').structure).to eq(
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
      links = PartialFinder::LinkSet.new(
        'app/views/articles/_sidebar.html.erb',
        'spec/dummy_app/'
      )
      agraph = PartialFinder::AssumptionGraph.new(links)
      expect(agraph.structure).to eq [
        Link.new("app/views/articles/_sidebar.html.erb", [
          Link.new("app/views/articles/edit.html.erb", [
            Link.new(
              "Rendered by articles#edit".colorize(:green),
              "Could not find route for articles#edit".colorize(:red)
            )
          ])
        ])
      ]
    end

    it 'can determine when controller method lookup fails' do
      pending "need to write test"
      expect(true).to be false
    end

    it 'can determine when a particular render chain is unused' do
      links = PartialFinder::LinkSet.new(
        'app/views/orders/_unused.html.erb',
        'spec/dummy_app/'
      )
      agraph = PartialFinder::AssumptionGraph.new(links)
      expect(agraph.structure).to eq [
        Link.new("app/views/orders/_unused.html.erb", [
          Link.new(
            "app/views/orders/_unused_parent.html.erb",
            "This render chain appears to be unused".colorize(:yellow)
          )
        ])
      ]
    end

    it 'can determine if an unknown file type is part of the render chain' do
      links = PartialFinder::LinkSet.new(
        'app/views/orders/_unexpected.html.erb',
        'spec/dummy_app/'
      )
      agraph = PartialFinder::AssumptionGraph.new(links)
      expect(agraph.structure).to eq [
        Link.new("app/views/orders/_unexpected.html.erb", [
          Link.new(
            "unexpected_match.txt",
            "Match of unknown type found in unexpected_match.txt".colorize(:yellow)
          )
        ])
      ]
    end
  end
end
