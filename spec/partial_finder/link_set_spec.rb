RSpec.describe PartialFinder::LinkSet do
  ::Link = PartialFinder::Link

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
            'app/views/orders/_main.html.erb',
            'app/controllers/orders_controller.rb'
          ]
        )
    end
  end

  describe 'building a list of links' do
    context 'with no found files' do
      it 'has no links' do
        partial = 'app/views/orders/_sidebar.html.erb'
        root = 'spec/dummy_app/controllers'
        expect(described_class.new(partial, root).values).to eq []
      end
    end

    context 'with found files' do
      it 'has links' do
        partial = 'app/views/orders/_sidebar.html.erb'
        root = 'spec/dummy_app/'
        expect(described_class.new(partial, root).values).to eq(
          [
            Link.new(partial, 'app/views/orders/_popup.html.erb'),
            Link.new('app/views/orders/_popup.html.erb', 'app/controllers/orders_controller.rb'),
            Link.new('app/views/orders/_popup.html.erb', 'app/views/orders/_main.html.erb'),
            Link.new('app/views/orders/_main.html.erb', 'app/controllers/orders_controller.rb'),
            Link.new('app/views/orders/_main.html.erb', 'app/views/orders/show.html.erb'),
            Link.new(partial, 'app/views/orders/new.html.erb')
          ]
        )
      end

      it 'does not include duplicate links' do
        pending "need to write test"
        expect(true).to be false
      end
    end
  end
end
