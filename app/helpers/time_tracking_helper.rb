module TimeTrackingHelper
  def format_as_time(length_in_minutes)
    hours = (length_in_minutes / 60).floor
    minutes = length_in_minutes % 60
    "%02d:%02d" % [hours, minutes]
  end
end