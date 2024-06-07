module Users
  class UserForm < BaseForm
    VirtusMixin = Virtus.model
    include VirtusMixin
    include ActiveModel::Validations

    attribute :first_name, String
    attribute :last_name, String
    attribute :email, String
    attribute :encrypted_password, String
    attribute :about_me, String
    attribute :profile, String
    attribute :gender, Integer

    validates :first_name, presence: { message: "First Name cannot be empty." }
    validates :last_name, presence: { message: "Last Name cannot be empty." }
    validates :email, presence: { message: "Email cannot be empty." }
    validates :encrypted_password, presence: { message: "Password cannot be empty." }
    validates :about_me, presence: { message: "About me cannot be empty." }
    validates :gender, presence: { message: "Please Specify your gender." }
  end
end