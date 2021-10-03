# frozen_string_literal: true

def messages_bordered_display(messages, border_char, header: '')
  messages = [messages] unless messages.is_a?(Array)

  max_length = messages.max_by(&:length).length
  max_length = header.length + 4 if header.length >= max_length

  border = border_char.ljust(max_length, border_char)

  puts(header.empty? ? border : header.center(max_length, border_char))
  messages.each { |message| puts message }
  puts border
end
