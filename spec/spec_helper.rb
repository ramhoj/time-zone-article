ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.around(:each, frozen: /.+/) do |scenario|
    frozen_at = scenario.metadata[:frozen]

    if frozen_at
      Timecop.freeze(frozen_at) { scenario.run }
    else
      scenario.run
    end
  end

  config.around(:each, travel_to: /.+/) do |scenario|
    travel_to = example.metadata[:travel_to]

    if travel_to
      Timecop.travel(travel_to) { scenario.run }
    else
      scenario.run
    end
  end

  config.around(:each, frozen: true) do |scenario|
    Timecop.freeze { scenario.run }
  end

  config.after do
    Timecop.return
  end
end
