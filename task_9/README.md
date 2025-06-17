# Service Analyzer

A Ruby console application that analyzes services and provides comprehensive markdown-formatted reports. The application intelligently handles both **service names** (e.g., "Spotify") and **raw service descriptions** (e.g., "A platform that allows users to stream music and discover new artists").

## Dependencies

### System Requirements
- **Ruby**: Version 2.5 or higher
- **Operating System**: Linux, macOS, or Windows
- **Network**: Internet connection for GPT-4.1-mini analysis

### Ruby Standard Libraries
The application uses only Ruby standard libraries:
- `net/http` - For HTTP requests
- `uri` - For URL parsing  
- `json` - For JSON processing
- `time` - For timestamp formatting

### Optional Dependencies
- **OpenAI API Key**: Required only for GPT-4.1-mini AI analysis (Demo analysis works without it)

## Installation

### Step 1: Install Ruby

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install ruby
```

#### On macOS (using Homebrew):
```bash
brew install ruby
```

#### On Windows:
Download Ruby installer from [rubyinstaller.org](https://rubyinstaller.org/)

#### Verify Installation:
```bash
ruby --version
# Should show Ruby 2.5.0 or higher
```

### Step 2: Download the Application

Clone or download the Service Analyzer to your local machine:
```bash
cd /path/to/your/projects
# Copy the task_9 folder to your desired location
```

### Step 3: Configure API Key (Optional)

For GPT-4.1-mini analysis, set up your OpenAI API key:

1. Copy the environment template:
   ```bash
   cd task_9
   cp .env.example .env
   ```

2. Edit the `.env` file and add your actual API key:
   ```bash
   nano .env
   # or use your preferred text editor
   ```
   
   Replace the placeholder with your actual API key:
   ```
   OPENAI_API_KEY=sk-your-actual-api-key-here
   ```

3. Save and close the file

### Step 4: Verify Installation

Test that everything is working:
```bash
cd task_9
ruby service_analyzer.rb
```

You should see the welcome message and service selection prompt.

## Usage Instructions

### Starting the Application

1. Navigate to the application directory:
   ```bash
   cd task_9
   ```

2. Run the application:
   ```bash
   ruby service_analyzer.rb
   ```

### Using the Application

1. **Select Analysis Service**: Choose between two options:
   - **Option 1**: GPT-4.1-mini AI Analysis (requires API key)
   - **Option 2**: Demo Analysis (works without API key)

2. **Enter Service Input**: You can input either:
   - **Service Names**: "Spotify", "Netflix", "GitHub", "Docker"
   - **Service Descriptions**: "A platform where users can stream music and create playlists"

3. **View Reports**: The application will generate and display a comprehensive markdown report

4. **Continue or Exit**: 
   - Enter another service for analysis
   - Type "exit" to close the application

### Input Types Supported

#### Service Names Examples:
```
> Spotify
> Netflix  
> GitHub
> Docker
> PostgreSQL
```

#### Service Descriptions Examples:
```
> A platform that allows users to share photos and connect with friends
> A cloud storage service that syncs files across devices
> An e-commerce website where people buy and sell products
> A video streaming service with original content
```

## Report Format

Each analysis report contains **8 comprehensive sections**:

### 1. **Brief History**
- Founding year and key milestones
- Important developments and evolution
- Company background and growth

### 2. **Target Audience** 
- Primary user segments and demographics
- Market focus and customer base
- User behavior patterns

### 3. **Core Features**
- Top 2-4 key functionalities
- Main capabilities and services
- Primary value propositions

### 4. **Unique Selling Points**
- Key differentiators from competitors
- Competitive advantages
- Standout characteristics

### 5. **Business Model**
- Revenue generation strategy
- Monetization approach
- Pricing structure and tiers

### 6. **Tech Stack Insights**
- Technology architecture overview
- Technical approaches and frameworks
- Infrastructure considerations

### 7. **Perceived Strengths**
- Main advantages and benefits
- Positive aspects and standout features
- Market position strengths

### 8. **Perceived Weaknesses**
- Potential limitations and drawbacks
- Areas for improvement
- Common criticisms or challenges

## Example Usage

### Example 1: Service Name Analysis

```
$ ruby service_analyzer.rb

Welcome to Service analyzer! Provide existing service name or service description and take a markdown-formatted report
Type exit to close the programm

Please select the analysis service:
1. GPT-4.1-mini AI Analysis (requires OpenAI API key)
2. Simple Demo Analysis

Choose option (1 or 2): 2
Selected: Simple Demo Analysis

==================================================

> Spotify
Analyzing service...

# Service Analysis Report: Spotify

**Status:** active  
**Uptime:** 99.9%  
**Last Check:** 2024-06-17 14:30:25  

## Brief History
Founded in 2008, this music streaming service revolutionized how people consume music. Key milestones include reaching 1M users in 2009, launching premium subscriptions in 2010, mobile app release in 2011, and achieving 100M+ active users by 2020.

## Target Audience
Primary audience includes music enthusiasts aged 16-45, podcast listeners, independent artists, and users seeking personalized audio content experiences across mobile and desktop platforms.

## Core Features
- Personalized playlists and recommendations
- High-quality audio streaming
- Offline download capabilities
- Social sharing and discovery features

## Unique Selling Points
- AI-powered music discovery
- Exclusive artist content
- Cross-platform synchronization
- High-fidelity audio options

## Business Model
Freemium subscription model with ad-supported free tier and premium subscriptions. Revenue from monthly/annual subscriptions, advertising, and artist revenue sharing partnerships.

## Tech Stack Insights
- React/React Native frontend
- Python/Django backend
- CDN for audio delivery
- Machine learning recommendation engine
- Real-time streaming protocols

## Perceived Strengths
- Excellent music discovery algorithms
- High-quality audio streaming
- Extensive music library
- User-friendly interface
- Cross-platform availability

## Perceived Weaknesses
- Limited free tier features
- Artist compensation concerns
- Regional content restrictions
- Requires internet connectivity

---
*Report generated at 2024-06-17 14:30:25*

==================================================

> exit
Goodbye!
```

### Example 2: Service Description Analysis

```
> A platform where people can share photos and connect with friends
Analyzing service...

# Service Analysis Report: Social Network Service

**Status:** active  
**Uptime:** 99.9%  
**Last Check:** 2024-06-17 14:32:10  

## Brief History
Founded in 2004, started as a university networking platform and expanded globally. Key developments include mobile app launch (2008), business pages introduction (2009), advertising platform launch (2010), and reaching 2B+ monthly active users (2018).

## Target Audience
Core audience consists of individuals aged 13-55 seeking social connections, businesses for marketing, content creators, and communities organizing around shared interests.

## Core Features
- User profiles and networking
- Content sharing and publishing
- Real-time messaging and notifications
- Community groups and events

## Unique Selling Points
- Real-time global connectivity
- Advanced privacy controls
- Integrated business tools
- AI-powered content curation

## Business Model
Advertising-based revenue model supplemented by premium subscriptions. Income from targeted advertising, business services, marketplace transactions, and data insights.

## Tech Stack Insights
- Scalable microservices architecture
- Real-time messaging systems
- Graph databases for connections
- Machine learning content algorithms
- Global CDN infrastructure

## Perceived Strengths
- Global user base and network effects
- Real-time communication features
- Robust privacy and security options
- Diverse content and communities
- Mobile-first experience

## Perceived Weaknesses
- Privacy and data concerns
- Algorithm-driven content bubbles
- Misinformation challenges
- Addictive design patterns

---
*Report generated at 2024-06-17 14:32:10*

==================================================
```

## Troubleshooting

### Common Issues

1. **Ruby not found**:
   ```bash
   # Install Ruby first (see Installation section)
   ruby --version
   ```

2. **API key not working**:
   ```bash
   # Check your .env file
   cat .env
   # Ensure it contains: OPENAI_API_KEY=sk-your-actual-key
   ```

3. **Permission errors**:
   ```bash
   # Make the script executable
   chmod +x service_analyzer.rb
   ```

### Getting Help

If you encounter issues:
1. Verify Ruby installation: `ruby --version`
2. Check file permissions: `ls -la service_analyzer.rb`
3. For GPT analysis, verify API key in `.env` file
4. Try Demo analysis first to test basic functionality

## Project Structure

```
task_9/
├── service_analyzer.rb              # Main application file
├── .env.example                     # Environment variables template
├── .gitignore                       # Git ignore file (includes .env)
├── lib/
│   ├── env_loader.rb               # Environment variables loader
│   ├── api_services/               # API service implementations
│   │   ├── api_service.rb          # Base/Parent class for all API services
│   │   ├── gpt4_mini_api_service.rb # GPT-4.1-mini AI analysis service
│   │   └── demo_api_service.rb     # Demo analysis service
│   └── formatters/                 # Report formatter implementations
│       ├── report_formatter.rb     # Base/Parent class for all formatters
│       ├── gpt_mini_report_formatter.rb # GPT-mini specific report formatter
│       └── simple_report_formatter.rb  # Simple/demo report formatter
└── README.md                       # This file
```
