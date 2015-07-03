class SensorData < ActiveRecord::Base
    belongs_to :sensor
    belongs_to :station
    validates :value, presence: true
    before_validation :validate_min_max_data
    validates :time_stamp, presence: true
    validates :station_id, presence: true
    validates :sensor_id, presence: true
    before_validation :validate_time_stamp
    before_validation :transform_data
    def max_value
        self.sensor.max_value
    end
    def min_value
        self.sensor.min_value
    end
    def transform_data_non_private
        case_value = self.sensor.sensor_type
        case case_value
        when "carbon dioxide"
            self.value = (self.value*0.188 + 321.250)
        when "sulfur dioxide"
            self.value = (self.value*0.150 - 30.000)
        when "ozone"
            self.value = (self.value*0.303 + 27.576)
        when "nitrogen dioxide"
            self.value = (self.value*0.375*(-1) + 55.000)
        when "nitrogen monoxide"
            self.value = (self.value*0.200*(-1) - 7.000)
        else
        end
    end
    def self.validate_parentage(loop_var, check_api_token)
      begin
        station_guid = loop_var[:sensor_id].slice(0..15)
        sensor_guid = loop_var[:sensor_id].slice(16..19)
        step = loop_var[:sensor_id].present? and Station.exists?(:guid => station_guid)
        step = step and Sensor.exists?(:guid => sensor_guid)
        step = step and check_api_token.eql? Station.find_by_guid(station_guid).api_key.token
        step = step and check_api_token.eql? Sensor.find_by_guid(sensor_guid).station.api_key.token
        return  step
      rescue Exception => e
        Rails.logger.debug "#{e.message}"
        return false
      end
    end
    def self.slice_guids(sensor_guid_combined)
        station_guid = sensor_guid_combined.slice(0..15)
        sensor_guid = sensor_guid_combined.slice(16..19)
        station_id = Station.find_by_guid(station_guid).id
        sensor_id = Sensor.find_by_guid(sensor_guid).id
        return station_id, sensor_id
    end
private
    def validate_min_max_data
        if (self.sensor.min_value.present? and (self.value < self.sensor.min_value))
            return false
        elsif (self.sensor.max_value.present? and (self.value > self.sensor.max_value))
            return false
        else
            return true
        end
    end
    def transform_data
        case_value = self.sensor.sensor_type
        puts "====meow"
        case case_value
        when "carbon dioxide"
            self.value = (self.value*0.188 + 321.250)
        when "sulfur dioxide"
            self.value = (self.value*0.150 - 30.000)
        when "ozone"
            self.value = (self.value*0.303 + 27.576)
        when "nitrogen dioxide"
            self.value = (self.value*0.375*(-1) + 55.000)
        when "nitrogen monoxide"
            self.value = (self.value*0.200*(-1) - 7.000)
        else
        end
    end
    def validate_time_stamp
        if Rails.application.config.validate_time
            time_window = Rails.application.config.time_window
            date_time_now_future = DateTime.now
            date_time_now_past = DateTime.now
            date_time_now_future = date_time_now_future.advance(:minutes => time_window)
            date_time_now_past = date_time_now_past.advance(:minutes => time_window*-1)
            last_sensor_data_record = SensorData.where(:sensor_id => self.sensor_id).last
            if ((self.time_stamp > date_time_now_future) or (self.time_stamp < date_time_now_past))
                return false
            elsif last_sensor_data_record.present? 
                if last_sensor_data_record.time_stamp >= self.time_stamp
                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end
    end
end
