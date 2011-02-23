require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  context "GET #new" do
    setup do
      get :new
    end

    should respond_with(:success)
    should render_template(:new)
    should assign_to(:account)
    should assign_to(:categories)
  end

  context "POST #create" do
    context "valid input" do
      setup do
        post :create, {:account => {:first_name => 'Joe', :last_name => 'Plumber', :email => 'joe_the_plumber@example.com', :page_url =>"http://example.com", :category_ids => [Category.first.id]}}
      end

      should respond_with(:success)
      should render_template(:created_pending_confirmation)
      should assign_to(:account)
    end

    context "invalid input" do
      setup do
        # First name missing
        post :create, {:account => {:first_name => '', :last_name => 'Plumber', :email => 'joe@example.com'}}
      end

      should respond_with(:success)
      should render_template(:new) # rerender new template showing errors
      should assign_to(:account)
    end
  end

  context "GET #index" do
    setup do
      get :index
    end

    should respond_with(:success)
    should render_template(:index)
    should assign_to(:accounts)
  end
end
