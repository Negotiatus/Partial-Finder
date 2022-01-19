class OrdersController
  def new
  end

  def show
  end

  def edit
    render partial: "orders/main"
  end

  def update
    render partial: 'orders/popup'
  end
end
