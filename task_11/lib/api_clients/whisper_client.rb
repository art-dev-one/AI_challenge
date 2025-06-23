require 'net/http'
require 'json'
require 'uri'
require_relative '../env_loader'

class WhisperClient
  API_BASE_URL = 'https://api.openai.com/v1'
  WHISPER_MODEL = 'whisper-1'
  MAX_FILE_SIZE = 25 * 1024 * 1024 # 25MB limit for Whisper API
  
  SUPPORTED_FORMATS = %w[
    .mp3 .mp4 .mpeg .mpga .m4a .wav .webm
    .flac .ogg .aac .amr .3gp .opus
  ].freeze

  class WhisperError < StandardError; end
  class AuthenticationError < WhisperError; end
  class FileError < WhisperError; end
  class APIError < WhisperError; end

  def initialize(api_key: nil)
    # Load environment variables from .env file
    EnvLoader.load_with_fallback('.env', '.env.local')
    
    @api_key = api_key || ENV['OPENAI_API_KEY']
    @base_url = API_BASE_URL

    raise AuthenticationError, "OpenAI API key is required. Set OPENAI_API_KEY in .env file or environment variable, or pass api_key parameter." unless @api_key
  end

  # Main transcription method
  def transcribe(audio_file_path, options = {})
    validate_audio_file(audio_file_path)
    
    endpoint = 'audio/transcriptions'
    payload = build_transcription_payload(audio_file_path, options)
    
    make_multipart_request(endpoint, payload)
  end

  # Translation method (translates to English)
  def translate(audio_file_path, options = {})
    validate_audio_file(audio_file_path)
    
    endpoint = 'audio/translations'
    payload = build_translation_payload(audio_file_path, options)
    
    make_multipart_request(endpoint, payload)
  end

  # Transcribe with timestamps
  def transcribe_with_timestamps(audio_file_path, options = {})
    transcribe(audio_file_path, options.merge(timestamp_granularities: ['word']))
  end

  # Transcribe and return structured data
  def transcribe_verbose(audio_file_path, options = {})
    transcribe(audio_file_path, options.merge(response_format: 'verbose_json'))
  end

  # Check if file is supported
  def supported_format?(file_path)
    extension = File.extname(file_path.downcase)
    SUPPORTED_FORMATS.include?(extension)
  end

  # Get file info
  def file_info(file_path)
    unless File.exist?(file_path)
      raise FileError, "File not found: #{file_path}"
    end

    {
      path: File.expand_path(file_path),
      size: File.size(file_path),
      size_mb: (File.size(file_path) / (1024.0 * 1024)).round(2),
      extension: File.extname(file_path).downcase,
      supported: supported_format?(file_path),
      within_size_limit: File.size(file_path) <= MAX_FILE_SIZE
    }
  end

  private

  def validate_audio_file(file_path)
    unless File.exist?(file_path)
      raise FileError, "Audio file not found: #{file_path}"
    end

    unless File.readable?(file_path)
      raise FileError, "Audio file is not readable: #{file_path}"
    end

    file_size = File.size(file_path)
    if file_size > MAX_FILE_SIZE
      raise FileError, "File size (#{(file_size / (1024.0 * 1024)).round(2)}MB) exceeds the 25MB limit"
    end

    unless supported_format?(file_path)
      raise FileError, "Unsupported file format. Supported formats: #{SUPPORTED_FORMATS.join(', ')}"
    end
  end

  def build_transcription_payload(audio_file_path, options)
    payload = {
      'file' => File.open(audio_file_path, 'rb'),
      'model' => WHISPER_MODEL
    }

    # Add optional parameters
    payload['language'] = options[:language] if options[:language]
    payload['prompt'] = options[:prompt] if options[:prompt]
    payload['response_format'] = options[:response_format] || 'json'
    payload['temperature'] = options[:temperature] if options[:temperature]
    
    # Handle timestamp granularities (array parameter)
    if options[:timestamp_granularities]
      options[:timestamp_granularities].each_with_index do |granularity, index|
        payload["timestamp_granularities[#{index}]"] = granularity
      end
    end

    payload
  end

  def build_translation_payload(audio_file_path, options)
    payload = {
      'file' => File.open(audio_file_path, 'rb'),
      'model' => WHISPER_MODEL
    }

    # Add optional parameters (translation has fewer options than transcription)
    payload['prompt'] = options[:prompt] if options[:prompt]
    payload['response_format'] = options[:response_format] || 'json'
    payload['temperature'] = options[:temperature] if options[:temperature]

    payload
  end

  def make_multipart_request(endpoint, payload)
    uri = URI("#{@base_url}/#{endpoint}")
    
    begin
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{@api_key}"
        request['User-Agent'] = 'WhisperClient/1.0'
        
        # Create multipart form data
        boundary = "----WebKitFormBoundary#{Random.hex(16)}"
        request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
        
        body = build_multipart_body(payload, boundary)
        request.body = body
        
        http.request(request)
      end
      
      handle_response(response)
      
    ensure
      # Always close file handles
      payload.each_value do |value|
        value.close if value.respond_to?(:close) && !value.closed?
      end
    end
  end

  def build_multipart_body(payload, boundary)
    body = []
    
    payload.each do |key, value|
      body << "--#{boundary}\r\n"
      
      if value.respond_to?(:read) # File object
        filename = File.basename(value.path)
        mime_type = get_mime_type(filename)
        
        body << "Content-Disposition: form-data; name=\"#{key}\"; filename=\"#{filename}\"\r\n"
        body << "Content-Type: #{mime_type}\r\n\r\n"
        body << value.read
        body << "\r\n"
      else # Regular form field
        body << "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n"
        body << value.to_s
        body << "\r\n"
      end
    end
    
    body << "--#{boundary}--\r\n"
    body.join
  end

  def get_mime_type(filename)
    extension = File.extname(filename).downcase
    
    case extension
    when '.mp3'
      'audio/mpeg'
    when '.mp4'
      'audio/mp4'
    when '.wav'
      'audio/wav'
    when '.m4a'
      'audio/mp4'
    when '.flac'
      'audio/flac'
    when '.ogg'
      'audio/ogg'
    when '.webm'
      'audio/webm'
    when '.aac'
      'audio/aac'
    when '.opus'
      'audio/opus'
    when '.amr'
      'audio/amr'
    when '.3gp'
      'audio/3gpp'
    when '.mpeg', '.mpga'
      'audio/mpeg'
    else
      'audio/mpeg' # Default to audio/mpeg for unknown audio formats
    end
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise APIError, "Invalid JSON response: #{e.message}"
      end
    when 401
      raise AuthenticationError, "Invalid API key or unauthorized access"
    when 413
      raise FileError, "File too large. Maximum size is 25MB"
    when 400..499
      error_body = JSON.parse(response.body) rescue { 'error' => { 'message' => 'Unknown client error' } }
      raise APIError, "Client error (#{response.code}): #{error_body.dig('error', 'message') || 'Unknown error'}"
    when 500..599
      error_body = JSON.parse(response.body) rescue { 'error' => { 'message' => 'Unknown server error' } }
      raise APIError, "Server error (#{response.code}): #{error_body.dig('error', 'message') || 'Unknown error'}"
    else
      raise APIError, "Unexpected response code: #{response.code}"
    end
  end


end 