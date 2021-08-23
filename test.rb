# frozen_string_literal: true

def run_tests(test_group_name, tests, callback)
  puts "#{test_group_name} tests:"

  tests.each do |test|
    puts "#{callback.call(test[:input]) == test[:expected_output] ? 'pass' : 'fail'} | #{test[:label]}"
  rescue StandardError => e
    puts "Error: #{e}"
  end
end
