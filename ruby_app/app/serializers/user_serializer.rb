class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :about_me, :gender, :profile, :created_at, :updated_at, :image_url

  def attributes(*args)
    hash = super
    hash.except!(:profile)
    hash
  end

  def gender
    if object.gender == 0
      "Male"
    else
      "Female"
    end
  end

  def created_at
    object.created_at.strftime("%d-%m-%y")
  end

  def updated_at
    object.updated_at.strftime("%d-%m-%y")
  end
end