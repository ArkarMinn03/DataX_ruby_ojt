module Users
  class UserService
    def initialize(params)
      @params = params
    end

    def create
      user = User.new(@params)
      if user.save
        return { user: user, status: :created }
      else
        return { user: user, status: :unprocessable_entity }
      end
    end

    def update(updated_user)
      user = User.new(@params)
      if updated_user.update(@params)
        return { user: updated_user, status: :updated}
      else
        return { user: user, status: :unprocessable_entity}
      end
    end

    def destroy(deleted_user)
      user = User.find(deleted_user[:id])
      if user.destroy
        return true
      else
        return false
      end
    end

  end
end