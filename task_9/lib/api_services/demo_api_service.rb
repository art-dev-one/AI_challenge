require_relative 'api_service'
require_relative '../formatters/simple_report_formatter'

class DemoApiService < ApiService
  def initialize
    super()
    @formatter = SimpleReportFormatter.new
  end

  def call(service_input)
    begin
      # Simulate API response for demonstration
      response = simulate_api_response(service_input)
      
      if response[:success]
        @formatter.call(response[:data], service_input)
      else
        handle_api_error(response[:error], service_input)
        return "Analysis failed. Please check the error message above."
      end
    rescue => e
      handle_api_error("API request failed: #{e.message}", service_input)
      return "Analysis failed. Please check the error message above."
    end
  end

  private

  def simulate_api_response(service_input)
    # Simulate different responses based on input
    if service_input.downcase.include?('error')
      { success: false, error: 'Service not found' }
    else
      { 
        success: true, 
        data: generate_comprehensive_data(service_input)
      }
    end
  end

  def generate_comprehensive_data(service_input)
    input_type = determine_input_type(service_input)
    service_context = analyze_service_context(service_input, input_type)
    
    {
      service_name: generate_service_name(service_input, input_type),
      status: 'active',
      uptime: '99.9%',
      last_check: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      brief_history: generate_brief_history(service_context),
      target_audience: generate_target_audience(service_context),
      core_features: generate_core_features(service_context),
      unique_selling_points: generate_unique_selling_points(service_context),
      business_model: generate_business_model(service_context),
      tech_stack_insights: generate_tech_stack_insights(service_context),
      perceived_strengths: generate_perceived_strengths(service_context),
      perceived_weaknesses: generate_perceived_weaknesses(service_context)
    }
  end

  def determine_input_type(input)
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

  def generate_service_name(service_input, input_type)
    case input_type
    when :service_name
      service_input.split.map(&:capitalize).join(' ')
    when :service_description
      # Extract potential service name from description or create a generic one
      if service_input.downcase.include?('music') || service_input.downcase.include?('streaming')
        'Music Streaming Service'
      elsif service_input.downcase.include?('video') || service_input.downcase.include?('movie')
        'Video Platform Service'
      elsif service_input.downcase.include?('social') || service_input.downcase.include?('network')
        'Social Network Service'
      elsif service_input.downcase.include?('e-commerce') || service_input.downcase.include?('shopping')
        'E-commerce Platform'
      elsif service_input.downcase.include?('cloud') || service_input.downcase.include?('storage')
        'Cloud Storage Service'
      else
        'Digital Service Platform'
      end
    end
  end

  def analyze_service_context(service_input, input_type)
    case input_type
    when :service_name
      categorize_by_name(service_input.downcase)
    when :service_description
      categorize_by_description(service_input.downcase)
    end
  end

  def categorize_by_name(service_name)
    case service_name
    when /spotify|apple music|youtube music|pandora|tidal/
      :music_streaming
    when /netflix|hulu|disney|amazon prime|hbo/
      :video_streaming
    when /facebook|twitter|instagram|linkedin|tiktok/
      :social_media
    when /amazon|ebay|shopify|etsy|alibaba/
      :ecommerce
    when /google drive|dropbox|onedrive|icloud/
      :cloud_storage
    when /uber|lyft|airbnb|doordash/
      :marketplace
    when /web|http|server|nginx|apache/
      :web_server
    when /database|db|mysql|postgres|mongodb/
      :database
    when /api|rest|graphql/
      :api_service
    else
      :general_service
    end
  end

  def categorize_by_description(description)
    if description.include?('music') || description.include?('song') || description.include?('streaming') && description.include?('audio')
      :music_streaming
    elsif description.include?('video') || description.include?('movie') || description.include?('tv') || description.include?('streaming')
      :video_streaming
    elsif description.include?('social') || description.include?('network') || description.include?('friends') || description.include?('post')
      :social_media
    elsif description.include?('shop') || description.include?('buy') || description.include?('sell') || description.include?('ecommerce')
      :ecommerce
    elsif description.include?('cloud') || description.include?('storage') || description.include?('file')
      :cloud_storage
    elsif description.include?('ride') || description.include?('delivery') || description.include?('marketplace')
      :marketplace
    elsif description.include?('web') || description.include?('http') || description.include?('server')
      :web_server
    elsif description.include?('database') || description.include?('data') || description.include?('sql')
      :database
    elsif description.include?('api') || description.include?('endpoint') || description.include?('integration')
      :api_service
    else
      :general_service
    end
  end

  def generate_brief_history(service_context)
    case service_context
    when :music_streaming
      "Founded in 2008, this music streaming service revolutionized how people consume music. Key milestones include reaching 1M users in 2009, launching premium subscriptions in 2010, mobile app release in 2011, and achieving 100M+ active users by 2020."
    when :video_streaming
      "Launched in 2012 as a video streaming platform. Major milestones include original content launch (2013), international expansion (2015), 4K streaming introduction (2016), and reaching 200M+ subscribers globally (2021)."
    when :social_media
      "Founded in 2004, started as a university networking platform and expanded globally. Key developments include mobile app launch (2008), business pages introduction (2009), advertising platform launch (2010), and reaching 2B+ monthly active users (2018)."
    when :ecommerce
      "Established in 1999 as an online marketplace. Significant milestones include seller platform launch (2001), mobile commerce introduction (2008), same-day delivery rollout (2012), and achieving $1B+ in annual revenue (2015)."
    when :cloud_storage
      "Founded in 2010 to provide secure cloud storage solutions. Key achievements include enterprise partnerships (2012), mobile sync capabilities (2013), collaboration features (2015), and serving 500M+ users worldwide (2019)."
    when :web_server
      "Established in 2018, this web service started as a simple HTTP server solution and has evolved into a comprehensive web platform with over 50 major releases and serving millions of requests daily."
    when :database
      "Founded in 2015, began as an open-source database project. Key milestones include reaching 1M+ downloads in 2017, enterprise edition launch in 2019, and cloud-native redesign in 2021."
    when :api_service
      "Launched in 2019 as a developer-first API platform. Major milestones include GraphQL support addition (2020), 10M+ API calls milestone (2021), and multi-region deployment (2022)."
    else
      "Founded in 2020, this service has grown steadily with key milestones including initial launch, Series A funding, and expansion to international markets with continuous feature enhancements."
    end
  end

  def generate_target_audience(service_context)
    case service_context
    when :music_streaming
      "Primary audience includes music enthusiasts aged 16-45, podcast listeners, independent artists, and users seeking personalized audio content experiences across mobile and desktop platforms."
    when :video_streaming
      "Target users encompass entertainment seekers, cord-cutters, families, and content creators. Demographics span ages 18-65 with focus on households seeking on-demand video content."
    when :social_media
      "Core audience consists of individuals aged 13-55 seeking social connections, businesses for marketing, content creators, and communities organizing around shared interests."
    when :ecommerce
      "Primary users include online shoppers, small to large businesses, independent sellers, and consumers seeking convenient purchasing experiences with global reach."
    when :cloud_storage
      "Target audience encompasses remote workers, businesses of all sizes, students, creative professionals, and organizations requiring secure file storage and collaboration."
    when :web_server
      "Primary audience includes web developers, DevOps engineers, startups to enterprise companies, and businesses requiring reliable web hosting and server management solutions."
    when :database
      "Target users encompass database administrators, backend developers, data analysts, and organizations from small businesses to large enterprises requiring robust data management."
    when :api_service
      "Core audience consists of API developers, mobile app developers, frontend engineers, and companies building microservices architectures or requiring API-first solutions."
    else
      "Primary users include developers, technical teams, SMBs to enterprise clients, and organizations seeking reliable, scalable technology solutions for their business operations."
    end
  end

  def generate_core_features(service_context)
    case service_context
    when :music_streaming
      ['Personalized playlists and recommendations', 'High-quality audio streaming', 'Offline download capabilities', 'Social sharing and discovery features']
    when :video_streaming
      ['On-demand video library', 'Original content production', 'Multi-device streaming', 'Personalized content recommendations']
    when :social_media
      ['User profiles and networking', 'Content sharing and publishing', 'Real-time messaging and notifications', 'Community groups and events']
    when :ecommerce
      ['Product catalog and search', 'Secure payment processing', 'Order tracking and fulfillment', 'Seller marketplace integration']
    when :cloud_storage
      ['Secure file storage and backup', 'Real-time synchronization', 'Collaborative sharing and editing', 'Cross-platform accessibility']
    when :web_server
      ['High-performance HTTP handling', 'Auto-scaling capabilities', 'SSL/TLS security', 'Load balancing and failover']
    when :database
      ['ACID compliance', 'Real-time synchronization', 'Advanced query optimization', 'Automated backup and recovery']
    when :api_service
      ['RESTful and GraphQL endpoints', 'Rate limiting and throttling', 'Authentication and authorization', 'Real-time API monitoring']
    else
      ['Reliable service delivery', 'Real-time monitoring and alerts', 'Scalable cloud architecture', 'Comprehensive API integration']
    end
  end

  def generate_unique_selling_points(service_context)
    case service_context
    when :music_streaming
      ['AI-powered music discovery', 'Exclusive artist content', 'Cross-platform synchronization', 'High-fidelity audio options']
    when :video_streaming
      ['Award-winning original series', 'Global content library', 'Simultaneous multi-device streaming', 'Download for offline viewing']
    when :social_media
      ['Real-time global connectivity', 'Advanced privacy controls', 'Integrated business tools', 'AI-powered content curation']
    when :ecommerce
      ['Global marketplace reach', 'AI-powered recommendations', 'Same-day delivery options', 'Seller success programs']
    when :cloud_storage
      ['End-to-end encryption', 'Unlimited version history', 'Smart sync technology', 'Enterprise-grade compliance']
    when :web_server
      ['99.99% uptime guarantee', 'Zero-configuration deployment', 'Built-in CDN integration', 'Developer-friendly tools']
    when :database
      ['Multi-model database support', 'Serverless scaling', 'Advanced analytics capabilities', 'Enterprise-grade security']
    when :api_service
      ['Schema-first development', 'Automatic documentation generation', 'Multi-protocol support', 'Edge computing integration']
    else
      ['Industry-leading reliability', 'Intuitive user experience', 'Competitive pricing model', '24/7 expert support']
    end
  end

  def generate_business_model(service_context)
    case service_context
    when :music_streaming
      "Freemium subscription model with ad-supported free tier and premium subscriptions. Revenue from monthly/annual subscriptions, advertising, and artist revenue sharing partnerships."
    when :video_streaming
      "Subscription-based model with multiple tiers. Revenue from monthly subscriptions, premium content, and international licensing deals. Some ad-supported tiers available."
    when :social_media
      "Advertising-based revenue model supplemented by premium subscriptions. Income from targeted advertising, business services, marketplace transactions, and data insights."
    when :ecommerce
      "Commission-based marketplace model. Revenue from seller fees, payment processing, advertising services, premium seller tools, and fulfillment services."
    when :cloud_storage
      "Freemium SaaS model with tiered storage limits. Revenue from individual and business subscriptions, enterprise contracts, and additional feature packages."
    when :web_server
      "Tiered SaaS pricing model based on bandwidth usage, storage, and compute resources. Offers free tier for developers, professional plans for growing businesses, and enterprise solutions with custom pricing."
    when :database
      "Usage-based pricing model charging for storage, compute, and data transfer. Includes free tier with generous limits, pay-as-you-scale middle tier, and enterprise licenses with dedicated support."
    when :api_service
      "API call-based pricing with monthly subscription tiers. Free tier for development, graduated pricing for production use, and enterprise plans with SLA guarantees and premium features."
    else
      "Freemium SaaS model with subscription tiers based on usage limits, features, and support levels. Combines per-user licensing with usage-based components for enterprise customers."
    end
  end

  def generate_tech_stack_insights(service_context)
    case service_context
    when :music_streaming
      ['React/React Native frontend', 'Python/Django backend', 'CDN for audio delivery', 'Machine learning recommendation engine', 'Real-time streaming protocols']
    when :video_streaming
      ['Adaptive bitrate streaming', 'Content delivery network (CDN)', 'Cloud-based transcoding', 'Machine learning for recommendations', 'Mobile-first architecture']
    when :social_media
      ['Scalable microservices architecture', 'Real-time messaging systems', 'Graph databases for connections', 'Machine learning content algorithms', 'Global CDN infrastructure']
    when :ecommerce
      ['React/Vue.js frontend', 'Node.js/Java backend', 'Payment gateway integration', 'Inventory management systems', 'Search and recommendation engines']
    when :cloud_storage
      ['Distributed file system', 'End-to-end encryption', 'Real-time synchronization', 'Cross-platform client applications', 'Redundant backup systems']
    when :web_server
      ['Node.js/Express or Go backend', 'Nginx reverse proxy', 'Docker containerization', 'Kubernetes orchestration', 'Redis caching layer']
    when :database
      ['Distributed architecture (Raft consensus)', 'PostgreSQL-compatible interface', 'RocksDB storage engine', 'gRPC communication', 'Prometheus monitoring']
    when :api_service
      ['GraphQL Apollo Server', 'OpenAPI specification', 'JWT authentication', 'Rate limiting with Redis', 'Microservices architecture']
    else
      ['Cloud-native microservices', 'RESTful API design', 'Container-based deployment', 'Modern web technologies', 'Event-driven architecture']
    end
  end

  def generate_perceived_strengths(service_context)
    case service_context
    when :music_streaming
      ['Excellent music discovery algorithms', 'High-quality audio streaming', 'Extensive music library', 'User-friendly interface', 'Cross-platform availability']
    when :video_streaming
      ['High-quality original content', 'Reliable streaming performance', 'User-friendly interface', 'Multiple device support', 'Competitive pricing']
    when :social_media
      ['Global user base and network effects', 'Real-time communication features', 'Robust privacy and security options', 'Diverse content and communities', 'Mobile-first experience']
    when :ecommerce
      ['Vast product selection', 'Fast and reliable delivery', 'Secure payment processing', 'Easy returns and customer service', 'Competitive pricing']
    when :cloud_storage
      ['Reliable data synchronization', 'Strong security and privacy', 'Generous free storage', 'Excellent collaboration features', 'Cross-platform compatibility']
    when :web_server
      ['Exceptional performance and speed', 'Easy setup and deployment', 'Excellent documentation', 'Strong community support', 'Reliable uptime record']
    when :database
      ['Strong consistency guarantees', 'Excellent query performance', 'Comprehensive backup solutions', 'Active development community', 'Enterprise-ready features']
    when :api_service
      ['Developer-friendly tools', 'Comprehensive API documentation', 'Flexible query capabilities', 'Strong type safety', 'Excellent testing tools']
    else
      ['User-friendly interface', 'Reliable performance', 'Comprehensive feature set', 'Strong customer support', 'Regular updates and improvements']
    end
  end

  def generate_perceived_weaknesses(service_context)
    case service_context
    when :music_streaming
      ['Limited free tier features', 'Artist compensation concerns', 'Regional content restrictions', 'Requires internet connectivity']
    when :video_streaming
      ['Content library varies by region', 'Monthly subscription costs', 'Limited offline viewing options', 'Competing platform exclusives']
    when :social_media
      ['Privacy and data concerns', 'Algorithm-driven content bubbles', 'Misinformation challenges', 'Addictive design patterns']
    when :ecommerce
      ['Counterfeit product risks', 'Complex seller fee structure', 'Increasing competition', 'Customer service response times']
    when :cloud_storage
      ['Limited free storage space', 'Subscription costs for larger storage', 'Internet dependency', 'Data sovereignty concerns']
    when :web_server
      ['Higher cost for high-traffic sites', 'Limited customization in lower tiers', 'Learning curve for advanced features']
    when :database
      ['Complex setup for advanced configurations', 'Limited free tier storage', 'Steep learning curve for optimization']
    when :api_service
      ['Query complexity can impact performance', 'Requires GraphQL knowledge', 'Limited real-time capabilities in basic tier']
    else
      ['Pricing can be expensive for small teams', 'Some features require technical expertise', 'Limited offline capabilities']
    end
  end
end 