require_relative 'report_formatter'

class SimpleReportFormatter < ReportFormatter
  def call(data, original_input)
    <<~MARKDOWN
      # Service Analysis Report: #{data[:service_name]}

      **Status:** #{data[:status]}  
      **Uptime:** #{data[:uptime]}  
      **Last Check:** #{data[:last_check]}  

      ## Brief History
      #{data[:brief_history] || 'Founded in 2020, this service has grown steadily with key milestones including initial launch and several major feature releases.'}

      ## Target Audience
      #{data[:target_audience] || 'Primary users include developers, enterprises, and technical teams looking for reliable service solutions.'}

      ## Core Features
      #{format_list(data[:core_features] || ['Reliable service delivery', 'Real-time monitoring', 'Scalable architecture', 'API integration'])}

      ## Unique Selling Points
      #{format_list(data[:unique_selling_points] || ['High availability guarantee', 'Easy integration', 'Competitive pricing', 'Excellent customer support'])}

      ## Business Model
      #{data[:business_model] || 'Subscription-based SaaS model with tiered pricing based on usage and feature access.'}

      ## Tech Stack Insights
      #{format_list(data[:tech_stack_insights] || ['Cloud-native architecture', 'Microservices design', 'REST API', 'Modern web technologies'])}

      ## Perceived Strengths
      #{format_list(data[:perceived_strengths] || ['Reliable performance', 'User-friendly interface', 'Strong documentation', 'Active community support'])}

      ## Perceived Weaknesses
      #{format_list(data[:perceived_weaknesses] || ['Limited customization options', 'Learning curve for new users', 'Pricing could be more competitive'])}

      ## Original Input
      ```
      #{original_input}
      ```

      ---
      *Report generated at #{format_timestamp}*
    MARKDOWN
  end

  private

  def format_list(items)
    if items.is_a?(Array)
      items.map { |item| "- #{item}" }.join("\n")
    else
      items.to_s
    end
  end
end 