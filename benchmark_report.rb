# frozen_string_literal: true

# TODO: Refactor this file into a module with a class that hides private functionality.
#   Public module method: benchmark_report

require 'benchmark'

def benchmark_implementation(benchmark, iterations_per_run, tests, implementation)
  implementation.default = 0.0
  implementation[:total_seconds] += benchmark.report(implementation[:label]) do
    iterations_per_run.times do
      tests.each do |test|
        implementation[:method].call(test[:input])
      end
    end
  end.real
end

def benchmark_implementations(iterations_per_run, tests, implementations)
  labels = implementations.map { |implementation| implementation.fetch(:label) }
  Benchmark.bm(labels.max { |a, b| a.length <=> b.length }.length) do |benchmark|
    implementations.each do |implementation|
      benchmark_implementation(benchmark, iterations_per_run, tests, implementation)
    end
  end
end

def build_details(implementation, runs)
  details = { label: implementation[:label], total_seconds: 0.0, average_seconds: 0.0 }

  details[:total_seconds] = implementation[:total_seconds]
  details[:average_seconds] = implementation[:total_seconds] / runs.to_f

  details
end

# Calculate how many runs would execute in the same time of the next-fastest run.
def calculate_speed_ratio(faster_details, slower_details)
  faster_average = faster_details[:average_seconds]
  slower_average = slower_details[:average_seconds]

  slower_average / faster_average
end

def report_format_single(detail)
  format('%<label>s completed in %<time>.6fs.',
         label: detail[:label],
         time: detail[:average_seconds])
end

def report_format_fastest(detail_fastest, detail_next_fastest)
  format('"%<fastest_label>s" ran the fastest at %<speed_difference>.3fx the speed of "%<next_fastest_label>s".',
         fastest_label: detail_fastest[:label],
         next_fastest_label: detail_next_fastest[:label],
         speed_difference: calculate_speed_ratio(detail_fastest, detail_next_fastest))
end

def report_format_comparison(detail_faster, detail_slower)
  format('"%<faster_label>s" ran %<speed_difference>.3fx the speed of "%<slower_label>s" ' \
         '(average %<first_time>.6fs vs %<second_time>.6fs).',
         faster_label: detail_faster[:label],
         speed_difference: calculate_speed_ratio(detail_faster, detail_slower),
         slower_label: detail_slower[:label],
         first_time: detail_faster[:average_seconds],
         second_time: detail_slower[:average_seconds])
end

def print_fastest(details)
  if details.size > 1
    puts "#{report_format_fastest(details[0], details[1])}\n\n"
  else
    puts report_format_single(details[0])
  end
end

def print_comparison_overview(details)
  puts '-- Comparison Overview --'
  details.each_with_index do |detail, idx|
    break if details[idx + 1].nil?

    puts report_format_comparison(detail, details[idx + 1])
  end
end

def print_fastest_slowest_comparison(details)
  puts '-- Fastest : Slowest --'
  puts report_format_comparison(details[0], details[-1])
end

def report_comparison(implementations, runs)
  implementations = implementations.sort_by { |implementation| implementation[:total_seconds] }
  details = implementations.map { |implementation| build_details(implementation, runs) }

  print_fastest(details) unless details.size.zero?
  if details.size > 1
    print_comparison_overview(details)
    print_fastest_slowest_comparison(details)
  end
end

# tests structure: [ { label: 'Test label', input: ..., expected_output: ... }, ... ]
# implementations structure: [ { label: 'Implementation label...', method: ->(input) { expected_output } }, ... ]
def benchmark_report(runs, iterations_per_run, tests, implementations)
  puts "\nBenchmark comparison of #{runs} runs of #{iterations_per_run} test data iterations, averaged by runs...\n\n"

  runs.times do
    benchmark_implementations(iterations_per_run, tests, implementations)
  end

  puts
  report_comparison(implementations, runs)
end

def benchmark_report_test_data(runs, iterations_per_run, tests, method)
  implementations = tests.map.with_index do |_, idx|
    { label: tests[idx][:label], method: ->(test_data) { method.call(test_data[idx][:input]) } }
  end
  tests_for_method = [label: 'TESTS passthrough', input: tests, expected_output: 'N/A']

  benchmark_report(runs, iterations_per_run, tests_for_method, implementations)
end
