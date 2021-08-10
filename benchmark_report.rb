# frozen_string_literal: true

# Refactor this file into a module with a class that hides private functionality.
# Public module method: benchmark_report

require 'benchmark'

def benchmark_implementation(benchmark, iterations_per_count, test_data, implementation)
  implementation.default = 0.0
  implementation[:total_seconds] += benchmark.report(implementation[:label]) do
    iterations_per_count.times do
      test_data.each do |_, data|
        implementation[:method].call(data[:input])
      end
    end
  end.total
end

def benchmark_implementations(iterations_per_count, test_data, implementations)
  labels = implementations.map { |implementation| implementation.fetch(:label) }
  Benchmark.bm(labels.max { |a, b| a.length <=> b.length }.length) do |benchmark|
    implementations.each do |implementation|
      benchmark_implementation(benchmark, iterations_per_count, test_data, implementation)
    end
  end
end

def build_details(implementation, count)
  details = { label: implementation[:label], total_seconds: 0.0, average_seconds: 0.0 }

  details[:total_seconds] = implementation[:total_seconds]
  details[:average_seconds] = implementation[:total_seconds] / count.to_f

  details
end

def calculate_speed_difference(faster_details, slower_details)
  faster_average = faster_details[:average_seconds]
  slower_average = slower_details[:average_seconds]

  (slower_average - faster_average) / slower_average
end

def report_top_two(implementations, count)
  sorted_by_total = implementations.sort_by { |implementation| implementation[:total_seconds] }
  first = build_details(sorted_by_total[0], count)
  second = build_details(sorted_by_total[1], count)

  puts format('%<faster_label>s was faster than %<slower_label>s by about %<speed_difference>.0f%% ' \
              '(average %<first_time>.4fs vs %<second_time>.4fs).',
              faster_label: first[:label],
              slower_label: second[:label],
              first_time: first[:average_seconds],
              second_time: second[:average_seconds],
              speed_difference: calculate_speed_difference(first, second) * 100)
end

# test_data structure: { label: { input: ..., expected_output: ... }, ... }
# implementations structure: [ { label: 'Implementation label...', method: ->(input) { expected_output } }, ... ]
def benchmark_report(count, iterations_per_count, test_data, implementations)
  puts "\nWhich one is faster with #{iterations_per_count} iterations?\n\n"

  count.times do
    benchmark_implementations(iterations_per_count, test_data, implementations)
  end

  puts
  report_top_two(implementations, count)
end
