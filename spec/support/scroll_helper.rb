module ScrollHelper

  def scroll_to_the_bottom_of_the_page
    page.execute_script <<-JS
      window.scrollBy(0,10000);
    JS
  end

end

RSpec.configure do |config|
  config.include ScrollHelper, type: :feature
end



