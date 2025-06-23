#!/usr/bin/env ruby

require_relative '../api_clients/whisper_client'
require_relative '../env_loader'
require_relative '../transcription_printer'

# Audio transcription service using OpenAI Whisper API
class WhisperTranscriptor
  def initialize
    # Initialize the client (API key should be set in OPENAI_API_KEY environment variable)
    @client = WhisperClient.new
    @demo_file = File.join(File.dirname(__FILE__), '..', '..', 'demo.mp3')
  end

  def run_examples
    puts "🎙️  Whisper Audio Transcription Service"
    puts "======================================="
    puts

    # Check if demo file exists
    unless File.exist?(@demo_file)
      puts "❌ Demo file not found: #{@demo_file}"
      puts "💡 Make sure demo.mp3 exists in the task_11 directory"
      return
    end

    # Example 1: File information
    file_info_example

    puts "\n" + "="*50 + "\n"

    # Example 2: Basic transcription
    basic_transcription_example

    puts "\n" + "="*50 + "\n"

    # Example 3: Transcription with timestamps
    timestamp_transcription_example

    puts "\n" + "="*50 + "\n"

    # Example 4: Verbose transcription
    verbose_transcription_example

    puts "\n" + "="*50 + "\n"

    # Example 5: Translation (if not English)
    translation_example

  rescue WhisperClient::AuthenticationError => e
    puts "❌ Authentication Error: #{e.message}"
    puts "💡 Create a .env file with OPENAI_API_KEY=your_api_key"
    puts "   (Copy env.example to .env and add your key)"
  rescue WhisperClient::FileError => e
    puts "📁 File Error: #{e.message}"
  rescue WhisperClient::APIError => e
    puts "🔥 API Error: #{e.message}"
  rescue => e
    puts "💥 Unexpected Error: #{e.message}"
  end

  private

  def file_info_example
    puts "📋 Example 1: File Information"
    puts "------------------------------"
    
    info = @client.file_info(@demo_file)
    
    puts "📁 File: #{File.basename(info[:path])}"
    puts "📏 Size: #{info[:size_mb]} MB"
    puts "🏷️  Extension: #{info[:extension]}"
    puts "✅ Supported: #{info[:supported] ? 'Yes' : 'No'}"
    puts "📊 Within size limit: #{info[:within_size_limit] ? 'Yes' : 'No'}"
  end

  def basic_transcription_example
    puts "🎯 Example 2: Basic Transcription"
    puts "--------------------------------"
    
    puts "🔄 Transcribing audio file..."
    result = @client.transcribe(@demo_file)
    
    if result['text']
      puts "📝 Transcribed text:"
      puts "\"#{result['text']}\""
    else
      puts "❌ No transcription text received"
      puts "Response: #{result.inspect}"
    end
  end

  def timestamp_transcription_example
    puts "⏰ Example 3: Transcription with Word Timestamps"
    puts "----------------------------------------------"
    
    puts "🔄 Transcribing with word-level timestamps..."
    result = @client.transcribe_with_timestamps(@demo_file)
    
    TranscriptionPrinter.print_timestamps_result(result)
  end

  def verbose_transcription_example
    puts "📊 Example 4: Verbose Transcription"
    puts "----------------------------------"
    
    puts "🔄 Getting detailed transcription data..."
    result = @client.transcribe_verbose(@demo_file)
    
    TranscriptionPrinter.print_verbose_result(result)
  end

  def translation_example
    puts "🌍 Example 5: Translation to English"
    puts "-----------------------------------"
    
    puts "🔄 Translating audio to English..."
    result = @client.translate(@demo_file)
    
    if result['text']
      puts "🔤 Translated text:"
      puts "\"#{result['text']}\""
    else
      puts "❌ No translation text received"
      puts "Response: #{result.inspect}"
    end
  end
end

# Interactive transcription service for processing different audio files
class WhisperInteractiveTranscriptor
  def initialize
    @client = WhisperClient.new
  end

  def run
    puts "🎙️  Interactive Audio Transcription Service"
    puts "==========================================="
    puts "Enter audio file paths to transcribe (or 'quit' to exit)"
    puts

    loop do
      print "🎵 Audio file path: "
      input = gets.chomp.strip

      case input.downcase
      when 'quit', 'exit', 'q'
        puts "👋 Goodbye!"
        break
      when ''
        puts "❌ Please enter a file path"
        next
      else
        process_audio_file(input)
      end

      puts
    end
  end

  private

  def process_audio_file(file_path)
    # Handle quoted paths and expand home directory
    file_path = file_path.gsub(/^['"]|['"]$/, '')
    file_path = File.expand_path(file_path)

    begin
      # Show file info first
      info = @client.file_info(file_path)
      puts "\n📋 File Info:"
      puts "  Size: #{info[:size_mb]} MB"
      puts "  Format: #{info[:extension]}"
      puts "  Supported: #{info[:supported] ? '✅' : '❌'}"

      return unless info[:supported] && info[:within_size_limit]

      puts "\n🔄 Transcribing..."
      result = @client.transcribe(file_path)

      puts "\n📝 Result:"
      puts "\"#{result['text']}\""

    rescue WhisperClient::WhisperError => e
      puts "❌ Error: #{e.message}"
    rescue => e
      puts "💥 Unexpected error: #{e.message}"
    end
  end
end

# Main execution
if __FILE__ == $0
  puts "Choose transcription mode:"
  puts "1. Demo transcription with demo.mp3"
  puts "2. Interactive transcription mode"
  print "Enter choice (1 or 2): "
  
  choice = gets.chomp

  case choice
     when '1'
     puts "\n🚀 Starting Demo Transcription Service..."
     puts "⚠️  Note: Make sure you have set up your .env file with OPENAI_API_KEY"
     puts

     transcriptor = WhisperTranscriptor.new
     transcriptor.run_examples
   when '2'
     puts "\n🚀 Starting Interactive Transcription Service..."
     puts "⚠️  Note: Make sure you have set up your .env file with OPENAI_API_KEY"
     puts

    interactive = WhisperInteractiveTranscriptor.new
    interactive.run
  else
    puts "Invalid choice. Please run again and choose 1 or 2."
  end
end 