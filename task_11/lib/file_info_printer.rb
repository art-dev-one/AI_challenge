class FileInfoPrinter
  def self.print(pathname)
    puts "✅ File found!"
    puts "📍 Absolute path: #{pathname.realpath}"
    puts "📄 Filename: #{pathname.basename}"
    
    if pathname.file?
      puts "📏 Size: #{format_file_size(pathname.size)}"
    elsif pathname.directory?
      puts "📂 Type: Directory"
    else
      puts "🔗 Type: #{pathname.ftype.capitalize}"
    end
  end

  def self.print_not_found(file_path, expanded_path, similar_files = [])
    puts "❌ File not found: #{file_path}"
    puts "   Expanded path: #{expanded_path}"
    
    if similar_files.any?
      puts "💡 Did you mean one of these?"
      similar_files.first(5).each do |file|
        puts "   - #{file}"
      end
    end
  end

  private

  def self.format_file_size(size)
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    unit = 0
    
    while size >= 1024 && unit < units.length - 1
      size /= 1024.0
      unit += 1
    end
    
    if unit == 0
      "#{size} #{units[unit]}"
    else
      "#{size.round(2)} #{units[unit]}"
    end
  end
end 