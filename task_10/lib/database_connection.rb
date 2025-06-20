require 'json'

class DatabaseConnection
  def initialize(data_file = 'dataset.json')
    @data_file = data_file
    @data = load_data
  end

  def all
    @data
  end

  private

  def load_data
    file_path = File.expand_path(@data_file, File.dirname(__FILE__) + '/..')
    
    if File.exist?(file_path)
      JSON.parse(File.read(file_path))
    else
      puts "Warning: #{file_path} not found. Using empty dataset."
      []
    end
  rescue JSON::ParserError => e
    puts "Error parsing JSON file: #{e.message}"
    []
  end
end 