module EmailScheduling
  def delayed_email_selector(de)
    ".tm_email-schedule[data-uid='#{de.uid}']"
  end
end

RSpec.configure do |config|
  config.include EmailScheduling, type: :feature
end