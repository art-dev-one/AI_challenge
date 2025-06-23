require 'net/http'
require 'json'
require 'uri'

class OpenAIClient
  API_BASE_URL = 'https://api.openai.com/v1'
  DEFAULT_MODEL = 'gpt-4.1-mini'

  class OpenAIError < StandardError; end
  class AuthenticationError < OpenAIError; end
  class RateLimitError < OpenAIError; end
  class APIError < OpenAIError; end

  def initialize(api_key: nil, model: DEFAULT_MODEL)
    @api_key = api_key || ENV['OPENAI_API_KEY']
    @model = model
    @base_url = API_BASE_URL

    raise AuthenticationError, "OpenAI API key is required. Set OPENAI_API_KEY environment variable or pass api_key parameter." unless @api_key
  end

  # Main method for chat completions
  def chat_completion(messages, options = {})
    payload = {
      model: options[:model] || @model,
      messages: messages,
      temperature: options[:temperature] || 0.7,
      max_tokens: options[:max_tokens] || 1000,
      top_p: options[:top_p] || 1.0,
      frequency_penalty: options[:frequency_penalty] || 0.0,
      presence_penalty: options[:presence_penalty] || 0.0
    }

    # Add optional parameters if provided
    payload[:functions] = options[:functions] if options[:functions]
    payload[:function_call] = options[:function_call] if options[:function_call]
    payload[:tools] = options[:tools] if options[:tools]
    payload[:tool_choice] = options[:tool_choice] if options[:tool_choice]

    make_request('chat/completions', payload)
  end

  # Method for function calling (legacy support)
  def function_calling(messages, functions, function_call: 'auto', **options)
    chat_completion(messages, {
      functions: functions,
      function_call: function_call
    }.merge(options))
  end

  # Method for tool calling (new approach)
  def tool_calling(messages, tools, tool_choice: 'auto', **options)
    chat_completion(messages, {
      tools: tools,
      tool_choice: tool_choice
    }.merge(options))
  end

  # Simple text completion method
  def complete(prompt, **options)
    messages = [{ role: 'user', content: prompt }]
    response = chat_completion(messages, options)
    extract_content(response)
  end

  # List available models
  def list_models
    make_request('models', method: 'GET')
  end

  # Check if the service is available
  def health_check
    begin
      list_models
      { status: 'healthy', message: 'OpenAI API is accessible' }
    rescue => e
      { status: 'unhealthy', message: e.message }
    end
  end

  private

  def make_request(endpoint, payload = nil, method: 'POST')
    uri = URI("#{@base_url}/#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60
    http.write_timeout = 60

    case method.upcase
    when 'GET'
      request = Net::HTTP::Get.new(uri)
    when 'POST'
      request = Net::HTTP::Post.new(uri)
      request.body = payload.to_json if payload
      request['Content-Type'] = 'application/json'
    else
      raise ArgumentError, "Unsupported HTTP method: #{method}"
    end

    # Set headers
    request['Authorization'] = "Bearer #{@api_key}"
    request['User-Agent'] = 'OpenAIClient/1.0'

    begin
      response = http.request(request)
      handle_response(response)
    rescue Net::TimeoutError => e
      raise APIError, "Request timeout: #{e.message}"
    rescue Net::HTTPError => e
      raise APIError, "HTTP error: #{e.message}"
    rescue => e
      raise APIError, "Request failed: #{e.message}"
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
    when 429
      raise RateLimitError, "Rate limit exceeded. Please retry after some time."
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

  def extract_content(response)
    return nil unless response&.dig('choices')&.first&.dig('message', 'content')
    response['choices'].first['message']['content'].strip
  end

  # Utility method for pretty printing responses
  def self.pretty_print_response(response)
    if response.is_a?(Hash) && response['choices']
      puts "=== OpenAI Response ==="
      response['choices'].each_with_index do |choice, index|
        puts "Choice #{index + 1}:"
        if choice['message']['content']
          puts "Content: #{choice['message']['content']}"
        end
        if choice['message']['function_call']
          puts "Function Call: #{choice['message']['function_call']['name']}"
          puts "Arguments: #{choice['message']['function_call']['arguments']}"
        end
        if choice['message']['tool_calls']
          choice['message']['tool_calls'].each do |tool_call|
            puts "Tool Call: #{tool_call['function']['name']}"
            puts "Arguments: #{tool_call['function']['arguments']}"
          end
        end
        puts "Finish Reason: #{choice['finish_reason']}" if choice['finish_reason']
        puts "---"
      end
      
      if response['usage']
        puts "Token Usage:"
        puts "  Prompt tokens: #{response['usage']['prompt_tokens']}"
        puts "  Completion tokens: #{response['usage']['completion_tokens']}"
        puts "  Total tokens: #{response['usage']['total_tokens']}"
      end
      puts "======================="
    else
      puts response.inspect
    end
  end
end 