class User < ActiveRecord::Base
 before_save { self.email = email.downcase}
 before_create :create_remember_token
 validates :name,  presence: true, length: { minimum: 2, maximum: 50 }
 VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
 validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
 	   uniqueness: { case_sensitive: false}
 validates :password, length: { minimum: 6 }, presence: true
 validates :password_confirmation, presence: true
 has_secure_password
 has_attached_file :avatar,
 		   :styles => { :medium => "400x400>", :thumb => "100x100>" },
 		   :default_url => "/images/:style/missing.png"
 #validates :avatar, presence: true
 validates_attachment_content_type :avatar, :content_type => /\Aimage/
 validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/]
 do_not_validate_attachment_file_type :avatar
 validates_attachment_size :avatar, :less_than => 2.megabytes

 def User.new_remember_token
  SecureRandom.urlsafe_base64
 end

 def User.hash(token)
  Digest::SHA1.hexdigest(token.to_s)
 end

 private

  def create_remember_token
   self.remember_token = User.hash(User.new_remember_token)
  end
end
