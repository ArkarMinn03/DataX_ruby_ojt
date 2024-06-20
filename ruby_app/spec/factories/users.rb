FactoryBot.define do
  factory :user do
    first_name { "Fafa" }
    last_name { "Tata" }
    email { "fafatata@gmail.com" }
    encrypted_password { "password" }
    about_me { "normal monkey" }
    gender { 1 }
  end
end