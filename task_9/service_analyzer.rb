#!/usr/bin/env ruby

# Load environment variables from .env file
require_relative 'lib/env_loader'
EnvLoader.load

require_relative 'lib/api_services/gpt4_mini_api_service'
require_relative 'lib/api_services/demo_api_service'

class ServiceAnalyzer
  def initialize
    @running = true
    @api_service = nil
  end

  def start
    display_welcome_message
    select_api_service
    main_loop
  end

  private

  def display_welcome_message
    puts "Welcome to Service analyzer! Provide existing service name or service description and take a markdown-formatted report"
    puts "Type exit to close the programm"
    puts
  end

  def select_api_service
    puts "Please select the analysis service:"
    puts "1. GPT-4.1-mini AI Analysis (requires OpenAI API key)"
    puts "2. Simple Demo Analysis"
    puts

    loop do
      print "Choose option (1 or 2): "
      choice = gets.chomp

      case choice
      when '1'
        @api_service = Gpt4MiniApiService.new
        puts "Selected: GPT-4.1-mini AI Analysis"
        if ENV['OPENAI_API_KEY'].nil? || ENV['OPENAI_API_KEY'].empty? || ENV['OPENAI_API_KEY'] == 'your-openai-api-key-here'
          puts "Note: OpenAI API key not found or not configured. Please set OPENAI_API_KEY in .env file or environment variable."
        else
          puts "OpenAI API key loaded successfully."
        end
        break
      when '2'
        @api_service = DemoApiService.new
        puts "Selected: Simple Demo Analysis"
        break
      else
        puts "Invalid choice. Please enter 1 or 2."
      end
    end
    puts "\n" + "="*50 + "\n"
  end

  def main_loop
    while @running
      print "> "
      user_input = gets.chomp
      
      if user_input.downcase == "exit"
        @running = false
        puts "Goodbye!"
      elsif user_input.strip.empty?
        puts "Please provide a service name or description."
      else
        puts "\nAnalyzing service...\n\n"
        report = @api_service.call(user_input)
        puts report
        puts "\n" + "="*50 + "\n"
      end
    end
  end
end

# Start the application
if __FILE__ == $0
  service_analyzer = ServiceAnalyzer.new
  service_analyzer.start
end 