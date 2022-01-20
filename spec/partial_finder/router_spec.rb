RSpec.describe PartialFinder::Router do
  # Copy-pasted sample from a `rake routes` output
  before do
    allow(described_class).to receive(:routes).and_return("
                                                                     admin_orders GET      /admin/orders(.:format)                                                                                                                                           admin/orders#index
                                                         claim_admin_orders_modal GET      /admin/orders/modals/:id/claim(.:format)                                                                                                                          admin/orders/modals#claim
                                            edit_client_values_admin_orders_modal GET      /admin/orders/modals/:id/edit_client_values(.:format)                                                                                                             admin/orders/modals#edit_client_values
                                                  edit_history_admin_orders_modal GET      /admin/orders/modals/:id/edit_history(.:format)                                                                                                                   admin/orders/modals#edit_history
                                                status_history_admin_orders_modal GET      /admin/orders/modals/:id/status_history(.:format)                                                                                                                 admin/orders/modals#status_history
                                                   split_order_admin_orders_modal GET      /admin/orders/modals/:id/split_order(.:format)                                                                                                                    admin/orders/modals#split_order
                                                  add_products_admin_orders_modal GET      /admin/orders/modals/:id/add_products(.:format)                                                                                                                   admin/orders/modals#add_products
                                              filter_activity_admin_orders_modals GET      /admin/orders/modals/filter_activity(.:format)                                                                                                                    admin/orders/modals#filter_activity

    ")
  end


  context 'with an existing route' do
    it "can find routes given a controller signature" do
      expect(described_class.routes_from("admin/orders/modals#claim")).to eq(
        ["/admin/orders/modals/:id/claim"]
      )
    end
  end

  context 'with a non-existant route' do
    it 'returns empty' do
      expect(described_class.routes_from("foo/testing#edit")).to eq []
    end
  end
end
