require_relative 'report_formatter'

class GptMiniReportFormatter < ReportFormatter
  def call(analysis, original_input)
    # Parse the analysis into structured sections
    sections = parse_analysis_sections(analysis)
    
    <<~MARKDOWN
      # AI-Powered Service Analysis Report

      ## Brief History
      #{sections[:brief_history]}

      ## Target Audience
      #{sections[:target_audience]}

      ## Core Features
      #{sections[:core_features]}

      ## Unique Selling Points
      #{sections[:unique_selling_points]}

      ## Business Model
      #{sections[:business_model]}

      ## Tech Stack Insights
      #{sections[:tech_stack_insights]}

      ## Perceived Strengths
      #{sections[:perceived_strengths]}

      ## Perceived Weaknesses
      #{sections[:perceived_weaknesses]}

      ## Detailed Analysis
      #{analysis}

      ## Original Input
      ```
      #{original_input}
      ```

      ---
      *AI analysis generated at #{format_timestamp}*
    MARKDOWN
  end

  private

  def parse_analysis_sections(analysis)
    # Extract specific sections from the AI analysis if they exist
    # Otherwise provide default structured content
    sections = {}
    
    sections[:brief_history] = extract_section(analysis, /brief history|history|background/i) || 
                              "AI analysis of the service background and historical context."
    
    sections[:target_audience] = extract_section(analysis, /target audience|users|customers/i) || 
                                "Primary users and target market segments identified through AI analysis."
    
    sections[:core_features] = extract_section(analysis, /core features|key features|main features/i) || 
                              "Key functionalities and capabilities identified by AI analysis."
    
    sections[:unique_selling_points] = extract_section(analysis, /unique selling|differentiators|advantages/i) || 
                                     "Distinctive characteristics and competitive advantages."
    
    sections[:business_model] = extract_section(analysis, /business model|revenue|monetization/i) || 
                               "Revenue generation strategy and business approach."
    
    sections[:tech_stack_insights] = extract_section(analysis, /tech stack|technology|technical/i) || 
                                   "Technology insights and technical architecture considerations."
    
    sections[:perceived_strengths] = extract_section(analysis, /strengths|advantages|benefits/i) || 
                                   "Identified strengths and positive aspects of the service."
    
    sections[:perceived_weaknesses] = extract_section(analysis, /weaknesses|limitations|drawbacks/i) || 
                                    "Potential limitations and areas for improvement."
    
    sections
  end

  def extract_section(text, pattern)
    # Simple extraction - look for paragraphs that mention the pattern
    lines = text.split("\n")
    relevant_lines = []
    
    lines.each_with_index do |line, index|
      if line.match(pattern)
        # Include the matching line and a few following lines
        relevant_lines << line
        (1..3).each do |offset|
          next_line = lines[index + offset]
          break if next_line.nil? || next_line.strip.empty?
          relevant_lines << next_line
        end
        break
      end
    end
    
    return nil if relevant_lines.empty?
    relevant_lines.join("\n").strip
  end
end 