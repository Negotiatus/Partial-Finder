RSpec.describe PartialFinder::Printer do
  it "can stringify a graph" do
    graph = PartialFinder::Graph.from('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
    pr = described_class.new(graph)
    expect(pr.string).to eq <<-OUT
app/views/orders/_sidebar.html.erb
  app/views/orders/_popup.html.erb
    app/controllers/orders_controller.rb
  app/views/orders/_popup.html.erb
    app/views/orders/_main.html.erb
      app/controllers/orders_controller.rb
    app/views/orders/_main.html.erb
      app/views/orders/show.html.erb
app/views/orders/_sidebar.html.erb
  app/views/orders/new.html.erb
OUT
  end

  it "can stringify an assumption graph" do
    graph = PartialFinder::AssumptionGraph.from('app/views/orders/_sidebar.html.erb', 'spec/dummy_app/')
    pr = described_class.new(graph)
    expect(pr.string).to eq <<-OUT
app/views/orders/_sidebar.html.erb
  app/views/orders/_popup.html.erb
    app/controllers/orders_controller.rb
      #{"Rendered by orders#update".colorize(:green)}
        #{"No routes found".colorize(:red)}
  app/views/orders/_popup.html.erb
    app/views/orders/_main.html.erb
      app/controllers/orders_controller.rb
        #{"Rendered by orders#edit".colorize(:green)}
          #{"No routes found".colorize(:red)}
    app/views/orders/_main.html.erb
      app/views/orders/show.html.erb
        #{"Rendered by orders#show".colorize(:green)}
          #{"Could not find route for orders#show".colorize(:red)}
app/views/orders/_sidebar.html.erb
  app/views/orders/new.html.erb
    #{"Rendered by orders#new".colorize(:green)}
      #{"Could not find route for orders#new".colorize(:red)}
OUT
  end
end
