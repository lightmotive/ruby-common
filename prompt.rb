# frozen_string_literal: true

require_relative 'validation_error'

# Returns the value from options[:convert_input]
# options[:validate]: if input is invalid, raise ValidationError with custom message or StandardError without message.
#   Raise ValidationError with helpful explanation (message) to prefix original.
def prompt_until_valid(
  message,
  options: {
    prompt_with_format: ->(msg) { puts "-> #{msg}" },
    input_invalid_default_message: 'Invalid input.',
    get_input: -> { gets.chomp },
    convert_input: ->(input) { input },
    validate: ->(_input_converted) { nil }
  }
)
  options[:prompt_with_format].call(message)
  loop do
    value = options[:convert_input].call(options[:get_input].call)
    options[:validate].call(value)
    break value
  rescue ValidationError => e
    options[:prompt_with_format].call("#{e.message} #{message}")
  rescue StandardError
    options[:prompt_with_format].call("#{options[:input_invalid_default_message]} #{message}")
  end
end
