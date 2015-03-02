class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :workshops, dependent: :destroy
  has_many :machines, through: :workshops

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [ :facebook ]


  has_attached_file :picture,
    styles: { medium: "300x300>", little: "200x200>", thumb: "100x100>" }

  validates_attachment_content_type :picture,
    content_type: /\Aimage\/.*\z/

  # validation email
  validates :email, presence: true, uniqueness: true



  def self.find_for_facebook_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.name = auth.info.name
      user.picture = auth.info.image
      user.token = auth.credentials.token
      user.token_expiry = Time.at(auth.credentials.expires_at)
    end
  end

  def owner_of
    array = []
    machines.each do |machine|
      array << machine.machine_model.name
    end
    array.join(', ')
  end

  def self.process_uri(uri)
   avatar_url = URI.parse(uri)
   avatar_url.scheme = 'https'
   avatar_url.to_s
  end

end


