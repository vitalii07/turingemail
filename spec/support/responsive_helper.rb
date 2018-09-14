module ResponsiveHelpers

  def resize_window_to_iphone_5_mobile_portrait
    resize_window_by([320, 460])
  end

  def resize_window_to_iphone_5_mobile_landscape
    resize_window_by([568, 212])
  end

  def resize_window_to_tablet
    resize_window_by([960, 640])
  end

  def resize_window_default
    resize_window_by([1024, 768])
  end

  private

  def resize_window_by(size)
    Capybara.current_session.driver.browser.manage.window.resize_to(size[0], size[1]) if Capybara.current_session.driver.browser.respond_to? 'manage'
  end

end

RSpec.configure do |config|
  config.include ResponsiveHelpers, type: :feature
end