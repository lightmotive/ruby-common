# frozen_string_literal: true

# Run all tests and return boolean indicating whether all tests passed.
def run_tests(test_group_name, tests, callback)
  puts "#{test_group_name} tests:"
  TestRunner.new(tests, callback).run
end

# Evaluate tests and output results.
class TestRunner
  def initialize(tests, callback)
    @tests = tests
    @callback = callback
  end

  def run
    @tests.each do |test|
      unless run_test_and_print(test)
        puts 'Skipped remaining tests due to last failure.'
        return false
      end
    rescue StandardError => e
      output_error(e)
      return false
    end

    true
  end

  private

  def label_for_output(test)
    input_for_label = test[:input]
    if input_for_label.length > 50
      input_for_label = "#{
        input_for_label.slice(0, 50)}... (length: #{input_for_label.length})"
    end
    test[:label] || "Input: #{input_for_label}"
  end

  def print_result(test, result, expected_output, output)
    puts "#{result ? 'pass' : 'fail'} | #{label_for_output(test)}" \
    "#{result ? '' : "\n  - Expected<#{expected_output}>\n  - Actual<#{output}>\n"}"
  end

  # Return boolean indicating test result
  def run_test_and_print(test)
    output = @callback.call(test[:input])
    result = (output == test[:expected_output])
    print_result(test, result, test[:expected_output], output)
    result
  end

  def output_error(error)
    puts "Error: #{error}"
    puts 'Skipped remaining tests due to last error.'
  end
end

# run_tests('pass', [{ label: 'Labeled', input: 1, expected_output: 1 },
#                    { input: 2, expected_output: 2 }], ->(input) { input })
# run_tests('fail', [{ label: 'Labeled', input: 1, expected_output: 1 },
#                    { input: 2, expected_output: 2 }], ->(input) { input + 1 })
