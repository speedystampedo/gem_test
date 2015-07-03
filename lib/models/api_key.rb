class ApiKey < ActiveRecord::Base
    belongs_to :station

    before_create :generate_token
    validates :station_id, presence: true
    private

    def generate_token
      begin
        self.token = SecureRandom.hex.to_s
      end while self.class.exists?(token: token)
    end
end
