def run_tests(tests, callback)
  tests.each do |test|
    puts "#{test[:label]}: #{callback.call(test[:input]) == test[:expected_output]}"
  end
end
