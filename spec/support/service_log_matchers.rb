# frozen_string_literal: true

module ServiceLogMatchers
  extend RSpec::Matchers::DSL

  matcher :include_log_message do |expected_message|
    match do |actual_logs|
      actual_logs.include?(expected_message)
    end

    failure_message do |actual_logs|
      <<~MSG
        expected logs to include:
          #{expected_message.inspect}
        but got:
          #{actual_logs.join("\n")}
      MSG
    end

    failure_message_when_negated do |_actual_logs|
      <<~MSG
        expected logs not to include:
          #{expected_message.inspect}
        but it was found.
      MSG
    end

    description do
      "include log message: #{expected_message}"
    end
  end
end
