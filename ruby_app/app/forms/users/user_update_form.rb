module Users
  class UserUpdateForm < BaseForm
    VirtusMixin = Virtus.model
    include VirtusMixin
    include ActiveModel::Validations

    attribute :first_name, String
    attribute :last_name, String
    attribute :email, String
    attribute :about_me, String
    attribute :gender, Integer, :default => 0

    validates :first_name, presence: { message: "First Name cannot be empty." }
    validates :last_name, presence: { message: "Last Name cannot be empty." }
    validates :email, presence: { message: "Email cannot be empty." }
    validates :about_me, presence: { message: "About me cannot be empty." }
    validates :gender, presence: { message: "Please Specify your gender." }
  end
end