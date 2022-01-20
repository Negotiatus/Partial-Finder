RSpec.describe PartialFinder::Formatter do
  describe '#path_to_ref' do
    it 'can take an arbitrary view path and convert it to a partial reference' do
      examples = {
        'app/views/_foo.html.erb'    => 'foo',
        'views/orders/_bar.html.erb' => 'orders/bar',
        'orders/_foobar.html.erb'    => 'orders/foobar'
      }

      examples.each do |given,expected|
        expect(described_class.path_to_ref(given)).to eq expected
      end
    end
  end

  describe '#is_partial?' do
    it 'can determine if a path is for a partial or not' do
      examples = {
        'app/views/_foo.html.erb'    => true,
        'views/orders/_bar.html.erb' => true,
        '_foobar.html.erb'           => true,
        'orders/foobar.html.erb'     => false
      }

      examples.each do |given,expected|
        expect(described_class.is_partial?(given)).to eq expected
      end
    end
  end

  describe '#is_view?' do
    it 'can determine if a path is for a view or not' do
      examples = {
        'app/views/_foo.html.erb' => false,
        '_foobar.html.erb'        => false,
        'foobar.html.erb'         => true,
        'orders/foobar.html.erb'  => true
      }

      examples.each do |given,expected|
        expect(described_class.is_view?(given)).to eq expected
      end
    end
  end

  describe '#is_controller?' do
    it 'can determine if a path is for a view or not' do
      examples = {
        'app/controllers/admin/orders_controller.rb' => true,
        'users_controller.rb'                        => true,
        'app/models/user.rb'                         => false
      }

      examples.each do |given,expected|
        expect(described_class.is_controller?(given)).to eq expected
      end
    end
  end

  describe '#fix_path' do
    it 'can make a full view path given a incomplete or complete path' do
      examples = {
        'foo.html.erb'              => 'app/views/foo.html.erb',
        './views/foo.html.erb'      => 'app/views/foo.html.erb',
        'app/views/foobar.html.erb' => 'app/views/foobar.html.erb',
        'views/foobar.html.erb'     => 'app/views/foobar.html.erb',
        'test_controller.rb'        => 'app/controllers/test_controller.rb'
      }

      examples.each do |given,expected|
        expect(described_class.fix_path(given)).to eq expected
      end
    end
  end

  describe '#type_of' do
    context 'with a partial' do
      it 'is type partial' do
        expect(described_class.type_of('app/views/_foo.html.erb')).to eq :partial
      end
    end

    context 'with a view' do
      it 'is type view' do
        expect(described_class.type_of('app/views/foo.html.erb')).to eq :view
      end
    end

    context 'with a controller' do
      it 'is type controller' do
        expect(described_class.type_of(
          'app/controllers/orders_controller.rb'
        )).to eq :controller
      end
    end

    context 'with an unknown type' do
      it 'is unknown' do
        expect(described_class.type_of('foo')).to eq :unknown
      end
    end
  end

  describe '#controller_signature_from_view' do
    context 'with a view' do
      it 'can generate a controller name+method given a view' do
        expect(
          described_class.controller_signature_from_view(
            'app/views/admin/orders/show.html.erb'
          )
        ).to eq 'admin/orders#show'
      end
    end

    context 'with something else' do
      it 'returns a blank string' do
        expect(
          described_class.controller_signature_from_view(
            'app/views/orders/_partial.html.erb'
          )
        ).to eq ''
      end
    end
  end

  describe '#controller_signature' do
    context 'with a controller path' do
      it 'can generate a controller name+method given a controller+method' do
        expect(
          described_class.controller_signature(
            'app/controllers/admin/orders_controller.rb',
            'show'
          )
        ).to eq 'admin/orders#show'
      end
    end

    context 'with something else' do
      it 'returns a blank string' do
        expect(
          described_class.controller_signature(
            'foo',
            'show'
          )
        ).to eq ""
      end
    end
  end

  it "can search through a controller and determine which method renders a partial" do
    expect(
      described_class.methods_that_render(
        'app/views/users/_main_menu.html.erb',
        'app/controllers/users_controller.rb',
        'spec/dummy_app/'
      )
    ).to eq ['new','show']
  end
end
