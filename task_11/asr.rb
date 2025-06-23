#!/usr/bin/env ruby

require 'pathname'
require_relative 'lib/env_loader'
require_relative 'lib/api_clients/whisper_client'
require_relative 'lib/file_info_printer'
require_relative 'lib/transcription_printer'

class ASRApplication
  def initialize
    puts "🎙️  ASR - Automatic Speech Recognition"
    puts "======================================"
    puts "Powered by OpenAI Whisper-1 Model"
    puts
    
    # Load environment variables from .env file
    EnvLoader.load_with_fallback('.env', '.env.local')
    
    begin
      @whisper_client = WhisperClient.new
      @whisper_available = true
      puts "✅ OpenAI API key loaded successfully"
    rescue WhisperClient::AuthenticationError => e
      puts "⚠️  Whisper API not available: #{e.message}"
      puts "💡 Create a .env file with OPENAI_API_KEY=your_api_key"
      puts "   (See env.example for a template)"
      @whisper_available = false
    end
  end

  def run
    if ARGV.length > 0
      # If file path is provided as command line argument
      process_file(ARGV[0])
    else
      # Interactive mode
      interactive_mode
    end
  end

  private

  def interactive_mode
    loop do
      show_menu
      print "> "
      
      input = gets.chomp.strip
      
      case input.downcase
      when 'quit', 'exit', 'q'
        puts "👋 Goodbye!"
        break
      when ''
        puts "❌ Please enter a file path or command"
        next
      when 'help', 'h'
        show_help
      when 'demo'
        process_demo_file
      else
        process_file(input)
      end
      
      puts
    end
  end

  def show_menu
    puts "📂 Enter audio file path to transcribe"
    puts "   (or 'demo' to use demo.mp3, 'help' for more options, 'quit' to exit):"
  end

  def show_help
    puts "\n🔧 Available Commands:"
    puts "  • Enter file path    - Show file info and transcribe if audio"
    puts "  • demo              - Process demo.mp3 file"
    puts "  • help (h)          - Show this help"
    puts "  • quit (q)          - Exit the application"
    puts "\n📋 Supported audio formats:"
    puts "  #{WhisperClient::SUPPORTED_FORMATS.join(', ')}"
    puts "\n⚙️  Features:"
    puts "  • File path analysis and validation"
    puts "  • Audio transcription (requires OpenAI API key)"
    puts "  • Automatic format detection"
    puts "  • File size validation (max 25MB)"
    puts "\n🔑 Setup:"
    puts "  • Copy env.example to .env"
    puts "  • Add your OPENAI_API_KEY to .env file"
    puts "  • API key status: #{@whisper_available ? '✅ Loaded' : '❌ Missing'}"
  end

  def process_demo_file
    demo_path = File.join(File.dirname(__FILE__), 'demo.mp3')
    
    unless File.exist?(demo_path)
      puts "❌ Demo file not found: demo.mp3"
      puts "💡 Make sure demo.mp3 exists in the task_11 directory"
      return
    end
    
    puts "🎵 Processing demo file..."
    process_file(demo_path)
  end

  def process_file(file_path)
    # Handle quoted paths
    file_path = file_path.gsub(/^['"]|['"]$/, '')
    
    # Expand tilde (~) for home directory
    expanded_path = File.expand_path(file_path)
    
    # Create Pathname object for better path handling
    pathname = Pathname.new(expanded_path)
    
    if pathname.exist?
      FileInfoPrinter.print(pathname)
      
      # Check if it's an audio file and transcribe
      if pathname.file? && is_audio_file?(pathname)
        transcribe_audio_file(expanded_path)
      end
    else
      similar_files = find_similar_files(pathname)
      FileInfoPrinter.print_not_found(file_path, expanded_path, similar_files)
    end
  end



  def is_audio_file?(pathname)
    return false unless @whisper_available
    
    extension = pathname.extname.downcase
    WhisperClient::SUPPORTED_FORMATS.include?(extension)
  end

  def transcribe_audio_file(file_path)
    return unless @whisper_available
    
    begin
      # Get file info first
      info = @whisper_client.file_info(file_path)
      
      unless info[:supported]
        TranscriptionPrinter.print_error(:unsupported_format, info[:extension])
        return
      end
      
      unless info[:within_size_limit]
        TranscriptionPrinter.print_error(:file_too_large, info[:size_mb])
        return
      end
      
      TranscriptionPrinter.print_starting_message(info[:size_mb])
      
      # Perform transcription
      result = @whisper_client.transcribe(file_path)
      
      TranscriptionPrinter.print_basic_result(result)
      
      if result && result['text']
        # Offer additional options
        offer_advanced_options(file_path)
      end
      
    rescue WhisperClient::FileError => e
      TranscriptionPrinter.print_error(:file_error, e.message)
    rescue WhisperClient::APIError => e
      TranscriptionPrinter.print_error(:api_error, e.message)
    rescue => e
      TranscriptionPrinter.print_error(:general_error, e.message)
    end
  end

  def offer_advanced_options(file_path)
    TranscriptionPrinter.print_advanced_options
    
    option = gets.chomp.downcase
    
    TranscriptionPrinter.print_option_result(option)
    
    case option
    when 't'
      transcribe_with_timestamps(file_path)
    when 'v'
      transcribe_verbose(file_path)
    when 'r'
      translate_to_english(file_path)
    when 's'
      # Skip message already printed by TranscriptionPrinter
    else
      # Unknown option message already printed by TranscriptionPrinter
    end
  end

  def transcribe_with_timestamps(file_path)
    begin
      result = @whisper_client.transcribe_with_timestamps(file_path)
      TranscriptionPrinter.print_timestamps_result(result)
    rescue => e
      TranscriptionPrinter.print_error(:general_error, e.message)
    end
  end

  def transcribe_verbose(file_path)
    begin
      result = @whisper_client.transcribe_verbose(file_path)
      TranscriptionPrinter.print_verbose_result(result)
    rescue => e
      TranscriptionPrinter.print_error(:general_error, e.message)
    end
  end

  def translate_to_english(file_path)
    begin
      result = @whisper_client.translate(file_path)
      TranscriptionPrinter.print_translation_result(result)
    rescue => e
      TranscriptionPrinter.print_error(:general_error, e.message)
    end
  end

  def find_similar_files(pathname)
    parent_dir = pathname.dirname
    similar_files = []
    
    if parent_dir.exist? && parent_dir.directory?
      filename = pathname.basename.to_s
      
      begin
        parent_dir.children.each do |child|
          child_name = child.basename.to_s
          if child_name.downcase.include?(filename.downcase) || 
             filename.downcase.include?(child_name.downcase)
            audio_indicator = is_audio_file?(child) ? " 🎵" : ""
            similar_files << "#{child}#{audio_indicator}"
          end
        end
      rescue Errno::EACCES
        # Cannot access parent directory
      end
    end
    
    similar_files
  end


end

# Main execution
if __FILE__ == $0
  begin
    app = ASRApplication.new
    app.run
  rescue Interrupt
    puts "\n👋 Interrupted by user. Goodbye!"
    exit(0)
  rescue => e
    puts "❌ An error occurred: #{e.message}"
    puts "Please check the file path and try again."
    exit(1)
  end
end
