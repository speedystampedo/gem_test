class Sensor < ActiveRecord::Base
    belongs_to :station
    after_create :create_guid
    before_save :validate_min_max_values
    has_many :sensor_datas, dependent: :destroy
    validates :units, presence: true
    validates :guid, presence: true
    validates :station_id, presence: true
private    
    def create_guid
      if self.guid.present?
      else
        self.guid = SecureRandom.hex(2)
        self.save
      end
    end
    def validate_min_max_values
        if self.max_value.present?
            if self.min_value.present?
                return false unless (self.min_value < self.max_value)
            else
                return true
            end
        else
            return true
        end
    end
end
