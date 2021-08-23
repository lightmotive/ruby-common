# frozen_string_literal: true

def run_tests(tests, callback)
  tests.each do |test|
    puts "#{callback.call(test[:input]) == test[:expected_output] ? 'pass' : 'fail'} | #{test[:label]}"
  rescue StandardError => e
    puts "Error: #{e}"
  end
end
