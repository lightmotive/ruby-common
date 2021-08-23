# frozen_string_literal: true

def run_tests(test_group_name, tests, callback)
  puts "#{test_group_name} tests:"

  tests.each do |test|
    test_label = test[:label] || "Input: #{test[:input]}"
    puts "#{callback.call(test[:input]) == test[:expected_output] ? 'pass' : 'fail'} | #{test_label}"
  rescue StandardError => e
    puts "Error: #{e}"
  end
end

run_tests('name', [{ label: 'Labeled', input: 1, expected_output: 1 },
                   { input: 2, expected_output: 2 }], ->(input) { input })
