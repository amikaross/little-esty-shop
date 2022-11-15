require "./app/poros/holiday"
require "./app/services/holiday_service"

class HolidaySearch
  def holidays
    service.upcoming_holidays[0..2].map do |data|
      Holiday.new(data)
    end
  end

  def service
    HolidayService.new
  end
end