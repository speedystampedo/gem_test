class Station < ActiveRecord::Base
    has_many :sensors, dependent: :destroy
    has_many :sensor_datas, dependent: :destroy
    has_one :api_key, dependent: :destroy
    after_create :create_api_key
    after_create :create_guid
    before_save :validate_geo_location
    def getMapImage
        string1 = "http://maps.google.com/maps/api/staticmap?center="
        string2 = "&zoom=18&size=150x150&format=jpeg&maptype=hybrid&sensor=false&"
       
        returnVar = string1 + self.lat.to_s + "," + self.long.to_s + string2
        return returnVar
    end
    private
    def create_api_key
      ApiKey.create :station => self
    end
    def create_guid
      if self.guid.present?
      else
        self.guid = SecureRandom.hex(8)
        self.save
      end
    end
    def validate_geo_location
      if self.lat > 90 or self.lat < -90
        return false
      elsif self.long > 180 or self.long < -180
        return false
      else
        return true
      end
    end
end
