# frozen_string_literal: true

require_relative 'validation_error'

# Returns the value from convert_input
# validate must raise ValidationError with custom message or StandardError without message if input is not valid.
#   Raise ValidationError with helpful explanation (message) to prefix original prompt with custom message.
def prompt_until_valid(
  prompt,
  get_input: -> { gets.chomp },
  convert_input: ->(input) { input },
  validate: ->(_value) { nil }
)
  prompt(prompt)
  loop do
    value = convert_input.call(get_input.call)
    validate.call(value)
    break value
  rescue ValidationError => e
    prompt("#{e.message} #{prompt}")
  rescue StandardError
    prompt("#{MESSAGES['input_invalid_message']} #{prompt}")
  end
end
