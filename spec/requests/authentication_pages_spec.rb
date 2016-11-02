require 'spec_helper'

describe "AuthenticationPages" do

 subject { page }

  describe "signin page" do
   before { visit signin_path }

   it { should have_content('Sign in') }
   it { should have_title('Sign in') }
  end

  describe "signin" do
   before { visit signin_path }

   describe "with invalid information" do
    before { click_button "Sign in" }

    it { should have_title('Sign in') }
    it { should have_error_message('Invalid') }
   end

   describe "with valid information" do
    let(:user) { FactoryGirl.create(:user) }
    before { signin(user) }


    it { should have_title(user.name) }
    it { should have_link('Users', href: users_path) }
    it { should have_link('Profile', href: user_path(user)) }
    it { should have_link('Settings', href: edit_user_path(user)) }
    it { should have_link('Sign out', href: signout_path) }
    it { should_not have_link('Sign in', href: signin_path) }


   describe "followed signout" do
   	before { click_link "Sign out" }
   	it { should have_link('Sign in') }
   end
  end
 end

 describe "authorization" do

 	describe "for non-signed-in users" do
 		let(:user) { FactoryGirl.create(:user) }

 		describe "when attempting to visit protected page" do
 			before do
 				visit edit_user_path(user)
 				signin user
 			end

 			describe "after signing in" do
 				it { should have_title('Edit user') }
 			end
 		end

 		describe "in th users controller" do

 			describe "visiting index page" do
 				before { visit users_path }
 				it { should have_title('Sign in') }
 			end

 			describe "visiting edit page" do
 				before { visit edit_user_path(user) }
 				it { should have_title('Sign in') }
 			end

 			describe "submitting to update action" do
 				before { patch user_path(user)}
 				specify { expect(response).to redirect_to(signin_path)}
 			end

    describe "as wrong user" do
    	let(:user) { FactoryGirl.create(:user) }
    	let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
    	before { signin user, no_capybara: true }

    	describe "submitting a GET request to user#edit action" do
    		before { get edit_user_path(wrong_user) }
    		specify { expect(response.body).not_to match(full_title('Edit user')) }
    		specify { expect(response).to redirect_to(root_url)}
    	end

    	describe "submitting a PATCH request to user#update action" do
    		before { patch user_path(wrong_user) }
    		specify { expect(response).to redirect_to(root_url)}
    	end
				end
 		end
 	end

 	describe "as non_admin user" do
 		let(:user) { FactoryGirl.create(:user) }
 		let(:non_admin) { FactoryGirl.create(:user) }

 		before { signin non_admin, no_capybara: true}

 		describe "submitting a DELETE request to user#destroy action" do
 			before { delete user_path(user)}
 			specify { expect(response).to redirect_to(root_url)}
 		end
 	end

 	describe "as admin user" do
 		let(:admin) { FactoryGirl.create(:admin) }
 		before { signin admin, no_capybara: true }

 		describe "submitting a DELETE request to admin#destroy action" do
 			specify do
 				expect { delete user_path(admin) }.not_to change(User, :count).by(-1)
 			end
 		end
 	end
 end
end
