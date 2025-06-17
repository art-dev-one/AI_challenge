require_relative 'api_service'
require_relative '../formatters/gpt_mini_report_formatter'

class Gpt4MiniApiService < ApiService
  BASE_URL = 'https://api.openai.com/v1/chat/completions'
  
  def initialize(api_key = nil)
    super()
    @api_key = api_key || ENV['OPENAI_API_KEY']
    @model = 'gpt-4.1-mini'
    @formatter = GptMiniReportFormatter.new
  end

  def call(service_input)
    if @api_key.nil? || @api_key.empty?
      handle_api_error('OpenAI API key not provided', service_input)
      return "Analysis failed. Please check the error message above."
    end

    begin
      prompt = build_analysis_prompt(service_input)
      response = make_gpt_request(prompt)

      if response[:success]
        analysis = extract_analysis_from_response(response[:body])
        @formatter.call(analysis, service_input)
      else
        handle_api_error("GPT API request failed: #{response[:error]}", service_input)
        return "Analysis failed. Please check the error message above."
      end
    rescue => e
      handle_api_error("Unexpected error: #{e.message}", service_input)
      return "Analysis failed. Please check the error message above."
    end
  end

  private

  def build_analysis_prompt(service_input)
    input_type = determine_input_type(service_input)
    
    case input_type
    when :service_name
      build_service_name_prompt(service_input)
    when :service_description
      build_service_description_prompt(service_input)
    end
  end

  def determine_input_type(input)
    # Simple heuristic: if input is short (1-3 words) and doesn't contain descriptive phrases, treat as service name
    # Otherwise, treat as description
    word_count = input.split.length
    descriptive_phrases = [
      'service that', 'platform for', 'application that', 'website that', 'system that',
      'tool for', 'solution for', 'helps', 'allows', 'provides', 'offers', 'enables'
    ]
    
    has_descriptive_phrases = descriptive_phrases.any? { |phrase| input.downcase.include?(phrase) }
    
    if word_count <= 3 && !has_descriptive_phrases
      :service_name
    else
      :service_description
    end
  end

  def build_service_name_prompt(service_name)
    <<~PROMPT
      You are a comprehensive service analyst. Analyze the service "#{service_name}" and provide a detailed report with the following specific sections:

      **Brief History**: Research and provide information about founding year, key milestones, evolution, and important developments in this service's history.

      **Target Audience**: Identify and describe the primary user segments, demographics, and market focus.

      **Core Features**: List and describe the top 2-4 key functionalities that define this service.

      **Unique Selling Points**: Highlight the key differentiators that set this service apart from competitors.

      **Business Model**: Explain how the service generates revenue and its monetization strategy.

      **Tech Stack Insights**: Provide insights about the technologies, architecture, and technical approaches used.

      **Perceived Strengths**: Identify and list the main advantages, positive aspects, and standout features.

      **Perceived Weaknesses**: Analyze potential limitations, drawbacks, and areas for improvement.

      Please provide specific, detailed analysis based on your knowledge of "#{service_name}". Structure your response with clear sections and provide comprehensive analysis for each area.
    PROMPT
  end

  def build_service_description_prompt(service_description)
    <<~PROMPT
      You are a comprehensive service analyst. Based on the following service description, first identify what specific service is being described, then provide a detailed analysis report.

      Service Description: "#{service_description}"

      Please follow these steps:
      1. First, analyze the description and identify the most likely service being described
      2. Then provide a comprehensive analysis report with the following sections:

      **Brief History**: Research and provide information about founding year, key milestones, evolution, and important developments in the identified service's history.

      **Target Audience**: Identify and describe the primary user segments, demographics, and market focus.

      **Core Features**: List and describe the top 2-4 key functionalities that define this service.

      **Unique Selling Points**: Highlight the key differentiators that set this service apart from competitors.

      **Business Model**: Explain how the service generates revenue and its monetization strategy.

      **Tech Stack Insights**: Provide insights about the technologies, architecture, and technical approaches used.

      **Perceived Strengths**: Identify and list the main advantages, positive aspects, and standout features.

      **Perceived Weaknesses**: Analyze potential limitations, drawbacks, and areas for improvement.

      If you cannot identify a specific existing service from the description, analyze it as a generic service concept and provide insights based on the described functionality and similar services in the market.

      Please structure your response with clear sections and provide comprehensive analysis for each area.
    PROMPT
  end

  def make_gpt_request(prompt)
    data = {
      model: @model,
      messages: [
        {
          role: 'system',
          content: 'You are a comprehensive business and technical service analyst with expertise in market research, competitive analysis, technology assessment, and service identification. You have extensive knowledge of popular services and platforms across various industries.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 2500,
      temperature: 0.7
    }

    headers = {
      'Authorization' => "Bearer #{@api_key}"
    }

    response = make_http_request(BASE_URL, data, headers)
    
    if response[:success]
      begin
        response[:body] = JSON.parse(response[:body])
        response
      rescue JSON::ParserError => e
        {
          success: false,
          error: "Invalid JSON response: #{e.message}",
          code: response[:code]
        }
      end
    else
      # Handle HTTP error responses
      error_message = extract_error_message(response)
      {
        success: false,
        error: error_message,
        code: response[:code]
      }
    end
  rescue => e
    {
      success: false,
      error: "Request failed: #{e.message}",
      code: 0
    }
  end

  def extract_error_message(response)
    case response[:code]
    when 401
      "Invalid API key. Please check your OPENAI_API_KEY in the .env file."
    when 429
      "Rate limit exceeded. Please try again later."
    when 400
      if response[:body]
        begin
          error_data = JSON.parse(response[:body])
          error_data.dig('error', 'message') || "Bad request: Invalid request format"
        rescue JSON::ParserError
          "Bad request: Invalid request format"
        end
      else
        "Bad request: Invalid request format"
      end
    when 403
      "Access forbidden. Please check your API key permissions."
    when 404
      "API endpoint not found. The model '#{@model}' may not be available."
    when 500..599
      "OpenAI server error (#{response[:code]}). Please try again later."
    else
      if response[:body] && !response[:body].empty?
        begin
          error_data = JSON.parse(response[:body])
          error_data.dig('error', 'message') || "HTTP #{response[:code]}: #{response[:body][0..200]}"
        rescue JSON::ParserError
          "HTTP #{response[:code]}: #{response[:body][0..200]}"
        end
      else
        response[:error] || "HTTP request failed with status #{response[:code]}"
      end
    end
  end

  def extract_analysis_from_response(response_body)
    if response_body.dig('choices', 0, 'message', 'content')
      response_body['choices'][0]['message']['content'].strip
    else
      'Unable to extract analysis from GPT response'
    end
  end
end 