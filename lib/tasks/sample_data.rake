namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		admin = User.create!(name: "Emir G",
																							email: "emirg@example.com",
																							password: "foobar",
																							password_confirmation: "foobar",
																							admin: true)
		99.times do |n|
		 name = Faker::Name.name
		 email = "emirg-#{n+1}@example.com"
		 password = "password"
		 User.create!(name: name,
		 													email: email,
		 													password: password,
		 													password_confirmation: password)
		end
	end
end
