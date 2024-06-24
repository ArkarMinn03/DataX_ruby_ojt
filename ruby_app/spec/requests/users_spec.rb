require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user_id) { 1 }

  describe "GET /users" do
    before { get '/users' }

    it " returns all users" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id" do
    before { get "/users/#{user_id}" }

    context "when there is a user with specified id" do
      it "return user details which is related to specified id" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when there is no user with specified id" do
      let(:user_id) { 10 }

      it "return error message" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /users" do
    let(:valid_attributes) {
      {
        user: {
          first_name: "FAFA",
          last_name: "TATA",
          email: "fafatata@gmail.com",
          encrypted_password: "password",
          about_me: "normal monkey",
          gender: 1
        }
      }
    }

    let(:inputs_without_first_name) {
      {
        user: {
          first_name: "",
          last_name: "TATA",
          email: "fafatata@gmail.com",
          encrypted_password: "password",
          about_me: "normal monkey",
          gender: 1
        }
      }
    }

    let(:inputs_without_email) {
      {
        user: {
          first_name: "FAFA",
          last_name: "TATA",
          email: "",
          encrypted_password: "password",
          about_me: "normal monkey",
          gender: 1
        }
      }
    }

    context "when creating user with valid inputs" do
      it "create new user." do
        expect{
          post users_path, params: valid_attributes
         }.to change(User, :count).by(1)
      end

      context "after posting" do
        before { post "/users", params: valid_attributes }

        it "redirects to users index" do
          expect(response).to redirect_to(users_path)
          expect(response).to have_http_status(:found)
        end

        it "set the flash notice" do
          follow_redirect!
          expect(response.body).to include(I18n.t('messages.common.create_success', data: "User"))
        end
      end
    end

    context "when creating user without first name" do
      it "does not increase user count and new user not created" do
        expect{
          post users_path, params: inputs_without_first_name
        }.not_to change(User, :count)
      end

      context "after posting" do
        before { post users_path, params: inputs_without_first_name }

        it "render back to the user create form" do
          expect(response.body).to include("form")
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "set flash errors" do
          expect(flash[:errors]).not_to be_nil
        end
      end
    end
  end

  describe "PATCH /users/:id" do
    let(:valid_attributes) {
      {
        first_name: "FAFA",
        last_name: "TATA",
        email: "fafatata@gmail.com",
        encrypted_password: "password",
        about_me: "normal monkey",
        gender: 1
      }
    }

    let(:user) { User.create(valid_attributes) }

    let(:update_first_name) {
      {
        user: {
          first_name: "NAFARA",
          last_name: "TATA",
          email: "fafatata@gmail.com",
          encrypted_password: "password",
          about_me: "normal monkey",
          gender: 1
        }
      }
    }

    let(:update_multiple_data) {
      {
        user: {
          first_name: "GuGu",
          last_name: "GaGa",
          email: "gugugaga@gmail.com",
          encrypted_password: "password",
          about_me: "normal monkey",
          gender: 1
        }
      }
    }

    let(:update_with_missing_inputs) {
      {
        user: {
          first_name: "GuGu",
          last_name: "GaGa",
          encrypted_password: "password",
          gender: 1
        }
      }
    }

    context "when updating first_name" do
      it "updates the first name " do
        patch user_path(user), params: update_first_name
        expect(response).to have_http_status(:found)
        user.reload
        expect(user.first_name).to eq("NAFARA")
      end
    end

    context "when updating multiple data" do
      it "updates all the changes data " do
        patch user_path(user), params: update_multiple_data
        expect(response).to have_http_status(:found)
        user.reload
        expect(user.first_name).to eq("GuGu")
        expect(user.last_name).to eq("GaGa")
        expect(user.email).to eq("gugugaga@gmail.com")
      end
    end

    context "when updating with missing input values " do
      it "does not update user and return error status" do
        patch user_path(user), params: update_with_missing_inputs
        expect(response).to have_http_status(:unprocessable_entity)
        user.reload
        expect(user.first_name).not_to eq("GuGu")
        expect(user.last_name).not_to eq("GaGa")
      end
    end
  end

  describe "DELETE /users/:id" do
    let(:valid_attributes) {
      {
        first_name: "FAFA",
        last_name: "TATA",
        email: "fafatata@gmail.com",
        encrypted_password: "password",
        about_me: "normal monkey",
        gender: 1
      }
    }

    let(:user) { User.create(valid_attributes) }

    context "when the user get deleted, " do
      before { delete user_path(user) }

      it "delete the specific user from database" do
        expect{ user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "redirect to users index page" do
        expect(response).to redirect_to(users_path)
        expect(response).to have_http_status(:found)
      end

      it "set the notice message." do
        follow_redirect!
        expect(response.body).to include(I18n.t('messages.common.destroy_success', data: "User"))
      end
    end
  end
end