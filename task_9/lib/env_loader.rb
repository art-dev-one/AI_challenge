class EnvLoader
  def self.load(file_path = '.env')
    return unless File.exist?(file_path)
    
    File.readlines(file_path).each do |line|
      line = line.strip
      
      # Skip empty lines and comments
      next if line.empty? || line.start_with?('#')
      
      # Parse KEY=VALUE format
      if line.include?('=')
        key, value = line.split('=', 2)
        key = key.strip
        value = value.strip
        
        # Remove quotes if present
        value = value.gsub(/\A["']|["']\z/, '')
        
        # Set environment variable if not already set
        ENV[key] = value unless ENV[key]
      end
    end
  rescue => e
    # Silently fail if .env file has issues
    puts "Warning: Could not load .env file: #{e.message}" if ENV['DEBUG']
  end
end 