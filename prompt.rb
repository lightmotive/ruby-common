# frozen_string_literal: true

require_relative 'validation_error'

# NOTE: prompt_until_valid should be a class. Will learn Ruby OOP and refactor later.

# Returns the value from options[:convert_input]
# options[:validate]: if input is invalid, raise ValidationError with custom message or StandardError without message.
#   Raise ValidationError with helpful explanation (message) to prefix original.
def prompt_until_valid_apply_default_options!(options)
  options[:prompt_with_format] ||= ->(msg) { puts "-> #{msg}" }
  options[:input_invalid_default_message] ||= 'Invalid input.'
  options[:get_input] ||= -> { gets.chomp }
  options[:convert_input] ||= ->(input) { input }
  options[:validate] ||= ->(_input_converted) { nil }
end

def _prompt_until_valid_loop(message, options)
  loop do
    value = options[:convert_input].call(options[:get_input].call)
    options[:validate]&.call(value)
    break value
  rescue ValidationError => e
    options[:prompt_with_format].call("#{e.message} #{message}")
  rescue StandardError
    options[:prompt_with_format].call("#{options[:input_invalid_default_message]} #{message}")
  end
end

def prompt_until_valid(
  message,
  options = {
    prompt_with_format: nil,
    input_invalid_default_message: nil,
    get_input: nil,
    convert_input: nil,
    validate: nil
  }
)
  prompt_until_valid_apply_default_options!(options)

  options[:prompt_with_format].call(message)
  _prompt_until_valid_loop(message, options)
end
