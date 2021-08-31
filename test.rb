# frozen_string_literal: true

def print_test_result(test_label, result, expected_output, output)
  puts "#{result ? 'pass' : 'fail'} | #{test_label}" \
  "#{result ? '' : "\n  - Expected<#{expected_output}>\n  - Actual<#{output}>\n"}"
end

def run_tests(test_group_name, tests, callback)
  puts "#{test_group_name} tests:"

  tests.each do |test|
    test_label = test[:label] || "Input: #{test[:input]}"
    output = callback.call(test[:input])
    print_test_result(test_label, output == test[:expected_output], test[:expected_output], output)
  rescue StandardError => e
    puts "Error: #{e}"
  end
end

# run_tests('pass', [{ label: 'Labeled', input: 1, expected_output: 1 },
#                    { input: 2, expected_output: 2 }], ->(input) { input })
# run_tests('fail', [{ label: 'Labeled', input: 1, expected_output: 1 },
#                    { input: 2, expected_output: 2 }], ->(input) { input + 1 })
