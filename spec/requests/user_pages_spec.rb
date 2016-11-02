require 'spec_helper'

describe "UserPages" do

 subject { page }

 describe "index page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before(:each) do
 		 signin user
  	 visit users_path
   end

   it { should have_content("All users") }
   it { should have_title("All users") }

   describe "pagination" do
  	 before(:all) { 30.times { FactoryGirl.create(:user) } }
  	 after(:all) { User.delete_all }

  	 it { should have_selector('div.pagination') }

    it "shoud list each user" do
  	  User.paginate(page: 1, per_page: 10).each do |user|
  		  expect(page).to have_selector('li', text: user.name)
  	  end
    end
   end


  describe "delete links" do
  	it { should_not have_link('delete') }

  	describe "as an admin user" do
  		let(:admin) { FactoryGirl.create(:admin) }

  		before do
  			signin admin
  			visit users_path
  		end

  		it { should have_link('delete', href: user_path(User.first)) }
  		it "should be able to delete another user" do
  			expect do
  				click_link('delete', match: :first)
  			end.to change(User, :count).by(-1)
  		end
  		it { should_not have_link('delete', href: user_path(admin))}
  	end
  end
 end

 describe "profile page" do
  let(:user) { FactoryGirl.create(:user) }
  before { visit user_path(user) }

   it { should have_content(user.name) }
   it { should have_title(user.name) }
 end

 describe "signup page" do
  before { visit signup_path }

   it { should have_content('Sign up') }
   it { should have_title('Sign up') }
  end

  describe "signup" do
   before { visit signup_path }

   let(:submit) { "Create my account" }

   describe "with invalid information" do
    it "should not create user account" do
     expect{click_button submit}.not_to change(User,:count)
    end

    describe "after submission" do
     before { click_button submit }

     it { should have_title('Sign up') }
     it { should have_content('error') }
    end
   end

   describe "with valid information" do
    before do
     fill_in "Name",         with: "Emir G"
     fill_in "Email",        with: "emirg@example.com"
     fill_in "Password",     with: "foobar"
     fill_in "Confirmation", with: "foobar"
    end

    it "should create user account" do
     expect{ click_button submit }.to change(User,:count).by(1)
    end

    describe "after saving the user" do
     before { click_button submit }
     let(:user) { User.find_by(email: 'emirg@example.com') }

     it { should have_title(user.name) }
     it { should have_link('Sign out') }
     it { should have_selector('div.alert.alert-success', text: 'Welcome') }
    end
   end
  end


  describe "edit page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before do
  	signin user
  	visit edit_user_path(user)
   end

  	describe "page" do
  		it { should have_content("Update your profile") }
    it { should have_title("Edit user") }
    it { should have_field("Change") }
  	end

   describe "with invalid information" do
   	before { click_button "Save changes"}

   	it { should have_content("error")}
   end

   describe "with valid information" do
    let(:new_name)  { "New name" }
    let(:new_email) { "new_email@example.com" }
    before do
     fill_in "Name",         with: new_name
     fill_in "Email",        with: new_email
     fill_in "Password",     with: user.password
     fill_in "Confirmation", with: user.password
     click_button "Save changes"
    end

    it { should have_title(new_name) }
    it { should have_link('Sign out', href: signout_path) }
    it { should have_selector('div.alert.alert-success') }
    specify { expect(user.reload.name).to eq new_name }
				specify { expect(user.reload.email).to eq new_email }
			end
  end
 end