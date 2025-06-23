class TranscriptionPrinter
  def self.print_starting_message(file_size_mb)
    puts "\n🔄 Starting transcription..."
    puts "📊 File size: #{file_size_mb}MB - Processing..."
  end

  def self.print_basic_result(result)
    if result && result['text']
      puts "\n🎯 Transcription Results:"
      puts "#{'-' * 50}"
      puts "📝 Text: #{result['text']}"
      
      if result['language']
        puts "🌐 Detected language: #{result['language']}"
      end
      puts "#{'-' * 50}"
    else
      puts "❌ No transcription received. Response: #{result.inspect}"
    end
  end

  def self.print_advanced_options
    puts "\n🔧 Advanced options available:"
    puts "  t - Transcribe with timestamps"
    puts "  v - Verbose transcription (with segments)"
    puts "  r - Translate to English"
    puts "  s - Skip advanced options"
    print "Choose option (t/v/r/s): "
  end

  def self.print_timestamps_result(result)
    puts "\n⏰ Transcription with Word-level Timestamps:"
    print_detailed_result(result)
  end

  def self.print_verbose_result(result)
    puts "\n📊 Verbose Transcription with Segments:"
    print_detailed_result(result)
  end

  def self.print_translation_result(result)
    if result && result['text']
      puts "\n🔤 Translation Result:"
      puts "#{'-' * 50}"
      puts "📝 English text: #{result['text']}"
      puts "#{'-' * 50}"
    else
      puts "❌ No translation received"
    end
  end

  def self.print_detailed_result(result)
    puts "#{'-' * 50}"
    
    if result.is_a?(Hash)
      if result['text']
        puts "📝 Text: #{result['text']}"
      end
      
      if result['language']
        puts "🌐 Language: #{result['language']}"
      end
      
      if result['duration']
        puts "⏱️  Duration: #{result['duration']} seconds"
      end
      
      if result['words']
        puts "\n📍 Word-level timestamps:"
        result['words'].each do |word|
          puts "  #{word['start'].round(2)}s - #{word['end'].round(2)}s: #{word['word']}"
        end
      end
      
      if result['segments']
        puts "\n🎯 Segments:"
        result['segments'].each_with_index do |segment, index|
          puts "  Segment #{index + 1} (#{segment['start'].round(2)}s - #{segment['end'].round(2)}s):"
          puts "    #{segment['text']}"
        end
      end
    else
      puts result.inspect
    end
    
    puts "#{'-' * 50}"
  end

  def self.print_error(error_type, message)
    case error_type
    when :file_error
      puts "📁 File Error: #{message}"
    when :api_error
      puts "🔥 API Error: #{message}"
    when :unsupported_format
      puts "❌ Unsupported audio format: #{message}"
    when :file_too_large
      puts "❌ File too large: #{message}MB (max 25MB)"
    when :general_error
      puts "💥 Unexpected error: #{message}"
    else
      puts "❌ Error: #{message}"
    end
  end

  def self.print_option_result(option)
    case option
    when 't'
      puts "\n⏰ Transcribing with word-level timestamps..."
    when 'v'
      puts "\n📊 Getting verbose transcription with segments..."
    when 'r'
      puts "\n🌍 Translating to English..."
    when 's'
      puts "✅ Skipping advanced options"
    else
      puts "❓ Unknown option, skipping..."
    end
  end
end 