module InputsHelper
  def datetimepicker_value(datetime)
    time_format = '%m/%d/%Y %I:%M %p'
    datetime.strftime(time_format).downcase
  end
end

RSpec.configure do |config|
  config.include InputsHelper, type: :feature
end