RSpec.describe PartialFinder::Graph do
  describe 'initialization' do
    context 'with a partial path' do
      it 'is valid' do
        ['orders/_sidebar.html.erb', 'app/views/orders/_sidebar.html.erb'].each do |f|
          expect { described_class.new(f, 'spec/dummy_app/') }.to_not raise_exception
        end
      end
    end

    context 'witha non-partial path' do
      it 'raises an exception' do
        expect do
          described_class.new('app/views/notapartial.html.erb', 'spec/dummy_app/')
        end.to raise_exception { PartialFinder::NonPartialArgument }
      end
    end
  end

  describe 'finding files that reference a partial' do
    it 'can find references regardless of quote types' do
      file = 'app/views/orders/_popup.html.erb'
      root = 'spec/dummy_app/'
      expect(
        described_class.files_that_reference(file, root)).to match_array(
          [
            'app/views/orders/show.html.erb',
            'app/controllers/orders_controller.rb'
          ]
        )
    end
  end

  describe 'building a list of links' do
    context 'with no files' do
      it 'has no links' do
        partial = 'app/views/orders/_sidebar.html.erb'
        root = 'spec/dummy_app/controllers'
        expect(described_class.new(partial, root).links).to eq []
      end
    end

    context 'with files' do
      context 'without any infinite loops' do
        it 'has links' do
          partial = 'app/views/orders/_sidebar.html.erb'
          root = 'spec/dummy_app/'
          expect(described_class.new(partial, root).links).to eq(
            [
              { partial => 'app/views/orders/_popup.html.erb' },
              { 'app/views/orders/_popup.html.erb' => 'app/controllers/orders_controller.rb' },
              { 'app/views/orders/_popup.html.erb' => 'app/views/orders/show.html.erb' }
            ]
          )
        end
      end

      context 'with an infinite loop' do
        it 'has links' do
          partial = 'app/views/orders/_foo.html.erb'
          root = 'spec/dummy_app/'
          expect(described_class.new(partial, root).links).to eq(
            [
              {"app/views/orders/_foo.html.erb"=>"app/views/orders/_bar.html.erb"},
              {"app/views/orders/_bar.html.erb"=>"app/views/orders/_foo.html.erb"},
              {"app/views/orders/_foo.html.erb"=>"app/views/orders/new.html.erb"}
            ]
          )
        end
      end
    end
  end

  describe 'building the graph' do
    context 'with no files' do
      it 'has an empty graph' do
        partial = 'app/views/orders/_dne.html.erb'
        root = 'spec/dummy_app/'
        expect(described_class.new(partial, root).structure).to eq([])
      end
    end

    context 'with files' do
      context 'without an infinite loop' do
        it 'has a built graph' do
          partial = 'app/views/orders/_sidebar.html.erb'
          root = 'spec/dummy_app/'
          expect(described_class.new(partial, root).structure).to eq(
            [
              {"app/views/orders/_sidebar.html.erb"=> [
                {"app/views/orders/_popup.html.erb"=>"app/controllers/orders_controller.rb"},
                {"app/views/orders/_popup.html.erb"=>"app/views/orders/show.html.erb"}
              ]}
            ]
          )
        end
      end

      context 'with an infinite loop' do
        it 'has a built graph' do
          pending "This condition is very complicated to handle gracefully and won't appear in v1"

          partial = 'app/views/orders/_foo.html.erb'
          root = 'spec/dummy_app/'
          expect(described_class.new(partial, root).structure).to eq(
            [
              {"app/views/orders/_foo.html.erb" => [
                {"app/views/orders/_bar.html.erb" => [
                  "Loops back to app/views/orders/_foo.html.erb".colorize(:yellow)
                ]}
              ]},
              {"app/views/orders/_foo.html.erb"=>"app/views/orders/new.html.erb"}
            ]
          )
        end
      end
    end
  end
end
