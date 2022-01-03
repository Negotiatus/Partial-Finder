RSpec.describe PartialFinder::Printer do
  it "can stringify a graph" do
    graph = PartialFinder::Graph.new('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
    pr = described_class.new(graph)
    expect(pr.to_s).to eq <<-OUT
app/views/orders/_sidebar.html.erb
  app/views/orders/_popup.html.erb
    app/controllers/orders_controller.rb
  app/views/orders/_popup.html.erb
    app/views/orders/show.html.erb
OUT
  end
end
