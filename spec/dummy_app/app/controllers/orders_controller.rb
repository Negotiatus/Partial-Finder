class OrdersController
  def new
  end

  def show
  end

  def edit
    render partial: "orders/popup"
  end

  def update
    render partial: 'orders/popup'
  end
end
