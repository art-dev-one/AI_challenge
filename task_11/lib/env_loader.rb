class EnvLoader
  def self.load(file_path = '.env')
    # Get the absolute path relative to the project root
    project_root = File.expand_path('..', __dir__)
    env_file = File.join(project_root, file_path)
    
    return unless File.exist?(env_file)
    
    begin
      File.readlines(env_file).each do |line|
        # Skip empty lines and comments
        line = line.strip
        next if line.empty? || line.start_with?('#')
        
        # Parse key=value pairs
        if line.include?('=')
          key, value = line.split('=', 2)
          key = key.strip
          value = value.strip
          
          # Remove quotes if present
          value = value.gsub(/^['"]|['"]$/, '')
          
          # Only set if not already set in environment
          ENV[key] = value unless ENV.key?(key)
        end
      end
      
      puts "📄 Loaded environment variables from #{file_path}" if ENV['DEBUG']
    rescue => e
      puts "⚠️  Warning: Could not load .env file: #{e.message}" if ENV['DEBUG']
    end
  end
  
  def self.load_with_fallback(*file_paths)
    file_paths.each do |path|
      if File.exist?(File.expand_path('..', __dir__) + '/' + path)
        load(path)
        return true
      end
    end
    false
  end
end 