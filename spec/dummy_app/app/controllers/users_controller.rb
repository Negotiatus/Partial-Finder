class UsersController
  def index
    @users = ["one", "two"]
  end

  def new
    if true
      render partial: 'users/main_menu'
    else
      render partial: 'users/main_menu'
    end
  end

  def show
    render partial: 'users/main_menu'
  end

  def destroy
    @user&.destroy
  end
end
